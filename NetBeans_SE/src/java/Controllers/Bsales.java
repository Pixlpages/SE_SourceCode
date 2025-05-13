package Controllers;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.google.gson.Gson;
import java.util.ArrayList;
import java.util.List;

public class Bsales extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String branch = (String) session.getAttribute("username"); // Get the branch from session

        if (branch == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "User not logged in or branch not found.");
            return;
        }

        // Read the JSON data from the request
        StringBuilder jsonBuffer = new StringBuilder();
        String line;
        while ((line = request.getReader().readLine()) != null) {
            jsonBuffer.append(line);
        }

        // Parse the JSON data into a list of items
        Gson gson = new Gson();
        Item[] itemsToPullout = gson.fromJson(jsonBuffer.toString(), Item[].class);

        List<String> criticallyLowItems = new ArrayList<>(); // List to store critically low items

        // Pull out the items (Update the inventory)
        try (Connection connection = DatabaseUtil.getConnection()) {
            connection.setAutoCommit(false); // Start transaction

            // Generate a new sales_code
            String salesCode = generateNextSalesCode();

            // Insert items into the sales table before updating the inventory
            for (Item item : itemsToPullout) {
                insertIntoSalesTable(connection, salesCode, branch, item);
                updateBranchTable(connection, branch, item);
                String criticallyLowItem = checkCriticallyLowCondition(connection, branch, item);
                if (criticallyLowItem != null) {
                    criticallyLowItems.add(criticallyLowItem); // Add to the list of critically low items
                }
            }

            connection.commit(); // Commit transaction

            // Send the response
            response.setStatus(HttpServletResponse.SC_OK);
            PrintWriter out = response.getWriter();
            out.print("{\"message\": \"Items removed from inventory successfully!\", \"criticallyLowItems\": "
                    + new Gson().toJson(criticallyLowItems) + "}");
            out.flush();
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error removing items from inventory.");
        }
    }

    private String generateNextSalesCode() {
        String nextSalesCode = "S-0001"; // Default value
        String query = "SELECT MAX(sales_code) FROM sales";

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(query);
             ResultSet resultSet = statement.executeQuery()) {

            if (resultSet.next()) {
                String maxDRCode = resultSet.getString(1);
                if (maxDRCode != null) {
                    // Extract the numeric part and increment it
                    String numericPart = maxDRCode.substring(3); // Get the part after "DR-"
                    int nextNumber = Integer.parseInt(numericPart) + 1;
                    nextSalesCode = String.format("S-%04d", nextNumber); // Format to DR-0001, DR-0002, etc.
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return nextSalesCode;
    }

    private void insertIntoSalesTable(Connection connection, String salesCode, String branch, Item item) throws SQLException {
        String insertSql = "INSERT INTO sales (sales_code, item_code, item_name, quantity, branch, delivery_date) VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";
        try (PreparedStatement preparedStatement = connection.prepareStatement(insertSql)) {
            preparedStatement.setString(1, salesCode);
            preparedStatement.setString(2, item.getItemCode());
            preparedStatement.setString(3, item.getItemName());
            preparedStatement.setInt(4, Integer.parseInt(item.getQuantity()));
            preparedStatement.setString(5, branch);
            int rowsInserted = preparedStatement.executeUpdate();
            if (rowsInserted == 0) {
                throw new SQLException("Failed to insert item into sales table for item code: " + item.getItemCode());
            }
        }
    }

    private void updateBranchTable(Connection connection, String branch, Item item) throws SQLException {
        String updateSql = "UPDATE " + branch + " SET total_quantity = total_quantity - ? WHERE item_code = ?";
        try (PreparedStatement preparedStatement = connection.prepareStatement(updateSql)) {
            preparedStatement.setInt(1, Integer.parseInt(item.getQuantity()));
            preparedStatement.setString(2, item.getItemCode());
            int rowsUpdated = preparedStatement.executeUpdate();
            if (rowsUpdated == 0) {
                throw new SQLException("No rows updated for item code: " + item.getItemCode());
            }
        }
    }

private String checkCriticallyLowCondition(Connection connection, String branch, Item item) throws SQLException {
    String getQuantitySql = "SELECT total_quantity FROM " + branch + " WHERE item_code = ?";
    String getCriticalSql = "SELECT critical_condition FROM items WHERE item_code = ?";
    String updateCriticallyLowSql = "UPDATE " + branch + " SET critically_low = ? WHERE item_code = ?";

    int totalQuantity = 0;
    int criticalCondition = 0;

    // Get current total quantity from branch
    try (PreparedStatement checkStmt = connection.prepareStatement(getQuantitySql)) {
        checkStmt.setString(1, item.getItemCode());
        ResultSet rs = checkStmt.executeQuery();
        if (rs.next()) {
            totalQuantity = rs.getInt("total_quantity");
        }
    }

    // Get critical condition from items table
    try (PreparedStatement criticalStmt = connection.prepareStatement(getCriticalSql)) {
        criticalStmt.setString(1, item.getItemCode());
        ResultSet rs = criticalStmt.executeQuery();
        if (rs.next()) {
            criticalCondition = rs.getInt("critical_condition");
        }
    }

    // Compare and update critically low status
    boolean isCritical = totalQuantity <= criticalCondition;
    try (PreparedStatement updateStmt = connection.prepareStatement(updateCriticallyLowSql)) {
        updateStmt.setBoolean(1, isCritical);
        updateStmt.setString(2, item.getItemCode());
        updateStmt.executeUpdate();
    }

    if (isCritical) {
        return item.getItemName();
    }

    return null;
}



    // Inner class to represent the item structure
    public static class Item {
        private String itemCode;
        private String quantity; // Quantity as a string to match the input type
        private String itemName;

        // Getters and Setters
        public String getItemCode() {
            return itemCode;
        }

        public void setItemCode(String itemCode) {
            this.itemCode = itemCode;
        }

        public String getQuantity() {
            return quantity;
        }

        public void setQuantity(String quantity) {
            this.quantity = quantity;
        }
        
        public String getItemName() { return itemName; }
        public void setItemName(String itemName) { this.itemName = itemName; }
    }
}
