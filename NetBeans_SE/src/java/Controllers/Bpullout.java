package Controllers;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.google.gson.Gson;

public class Bpullout extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String branch = (String) session.getAttribute("username");

        if (branch == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "User  not logged in or branch not found.");
            return;
        }

        // Read the JSON data from the request
        StringBuilder jsonBuffer = new StringBuilder();
        String line;
        BufferedReader reader = request.getReader();
        while ((line = reader.readLine()) != null) {
            jsonBuffer.append(line);
        }

        String PoCode = generateNextPullOutCode(branch);

        // Parse the JSON data into a list of items
        Gson gson = new Gson();
        Item[] itemsToPullout = gson.fromJson(jsonBuffer.toString(), Item[].class);

        // Create a list to hold critically low items
        List<String> criticallyLowItems = new ArrayList<>();

        // Process the pullout items
        try (Connection connection = DatabaseUtil.getConnection()) {
            connection.setAutoCommit(false); // Start transaction

            for (Item item : itemsToPullout) {
                // Transfer items to malabon table
                transferToMalabon(connection, item);

                // Check if malabon is critically low after transfer
                checkMalabonCriticalCondition(connection, item, criticallyLowItems);

                // Log the pullout in the pullout_receipt table
                logPulloutReceipt(connection, item, PoCode, branch);

                // Subtract the quantity from the branch table and check for critically low items
                subtractFromBranchTable(connection, item, branch, criticallyLowItems);
            }

            connection.commit(); // Commit transaction
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().print(new Gson().toJson(criticallyLowItems)); // Return critically low items
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error pulling out items.");
        }
    }

    private String generateNextPullOutCode(String branch) {
    String prefix = "PO-" + branch + "-";
    String nextPOCode = prefix + "0001"; // Default value
    String query = "SELECT MAX(pullout_code) FROM pullout_receipt WHERE pullout_code LIKE ?";

    try (Connection connection = DatabaseUtil.getConnection();
         PreparedStatement statement = connection.prepareStatement(query)) {

        statement.setString(1, prefix + "%");
        ResultSet resultSet = statement.executeQuery();

        if (resultSet.next()) {
            String maxPOCode = resultSet.getString(1);
            if (maxPOCode != null) {
                // Extract the numeric part (after "PO-branch-") and increment it
                String numericPart = maxPOCode.substring(prefix.length());
                int nextNumber = Integer.parseInt(numericPart) + 1;
                nextPOCode = prefix + String.format("%04d", nextNumber);
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }

    return nextPOCode;
}


    private void transferToMalabon(Connection connection, Item item) throws SQLException {
        // Update the malabon table with the item being transferred
        String transferSql = "INSERT INTO malabon (item_code, item_name, total_quantity) " +
                             "VALUES (?, ?, ?) " +
                             "ON DUPLICATE KEY UPDATE total_quantity = total_quantity + ?";

        try (PreparedStatement preparedStatement = connection.prepareStatement(transferSql)) {
            preparedStatement.setString(1, item.getItemCode());
            preparedStatement.setString(2, item.getItemName());
            preparedStatement.setInt(3, Integer.parseInt(item.getQuantity()));
            preparedStatement.setInt(4, Integer.parseInt(item.getQuantity())); // For ON DUPLICATE KEY UPDATE
            preparedStatement.executeUpdate();
        }
    }

private void checkMalabonCriticalCondition(Connection connection, Item item, List<String> criticallyLowItems) throws SQLException {
    String getQuantitySql = "SELECT total_quantity FROM malabon WHERE item_code = ?";
    String getCriticalSql = "SELECT critical_condition FROM items WHERE item_code = ?";
    String updateCriticallyLowSql = "UPDATE malabon SET critically_low = ? WHERE item_code = ?";

    int totalQuantity = 0;
    int criticalCondition = 0;

    // Get current total quantity from malabon
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

    // Compare and update
    boolean isCritical = totalQuantity <= criticalCondition;
    try (PreparedStatement updateStmt = connection.prepareStatement(updateCriticallyLowSql)) {
        updateStmt.setBoolean(1, isCritical);
        updateStmt.setString(2, item.getItemCode());
        updateStmt.executeUpdate();
    }

    if (isCritical) {
        criticallyLowItems.add(item.getItemName());
    }
}


private void subtractFromBranchTable(Connection connection, Item item, String branch, List<String> criticallyLowItems) throws SQLException {
    String updateQuantitySql = "UPDATE " + branch + " SET total_quantity = total_quantity - ? WHERE item_code = ?";
    String getQuantitySql = "SELECT total_quantity FROM " + branch + " WHERE item_code = ?";
    String getCriticalSql = "SELECT critical_condition FROM items WHERE item_code = ?";
    String updateCriticallyLowSql = "UPDATE " + branch + " SET critically_low = ? WHERE item_code = ?";

    int quantityToSubtract = Integer.parseInt(item.getQuantity());
    int totalQuantity = 0;
    int criticalCondition = 0;

    // Update quantity in branch
    try (PreparedStatement updateStmt = connection.prepareStatement(updateQuantitySql)) {
        updateStmt.setInt(1, quantityToSubtract);
        updateStmt.setString(2, item.getItemCode());
        updateStmt.executeUpdate();
    }

    // Get updated quantity
    try (PreparedStatement quantityStmt = connection.prepareStatement(getQuantitySql)) {
        quantityStmt.setString(1, item.getItemCode());
        ResultSet rs = quantityStmt.executeQuery();
        if (rs.next()) {
            totalQuantity = rs.getInt("total_quantity");
        }
    }

    // Get critical condition
    try (PreparedStatement criticalStmt = connection.prepareStatement(getCriticalSql)) {
        criticalStmt.setString(1, item.getItemCode());
        ResultSet rs = criticalStmt.executeQuery();
        if (rs.next()) {
            criticalCondition = rs.getInt("critical_condition");
        }
    }

    // Update critically low
    boolean isCritical = totalQuantity <= criticalCondition;
    try (PreparedStatement updateCriticalStmt = connection.prepareStatement(updateCriticallyLowSql)) {
        updateCriticalStmt.setBoolean(1, isCritical);
        updateCriticalStmt.setString(2, item.getItemCode());
        updateCriticalStmt.executeUpdate();
    }

    if (isCritical) {
        criticallyLowItems.add(item.getItemName());
    }
}


    private void logPulloutReceipt(Connection connection, Item item, String PoCode, String branch) throws SQLException {
        // Insert into pullout_receipt for each item pulled out
        String insertReceiptSql = "INSERT INTO pullout_receipt (pullout_code, item_code, item_name, quantity, branch) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement preparedStatement = connection.prepareStatement(insertReceiptSql)) {
            preparedStatement.setString(1, PoCode);
            preparedStatement.setString(2, item.getItemCode());
            preparedStatement.setString(3, item.getItemName());
            preparedStatement.setInt(4, Integer.parseInt(item.getQuantity()));
            preparedStatement.setString(5, branch);
            preparedStatement.executeUpdate();
        }
    }

    // Inner class to represent the item structure
    public static class Item {
        private String itemCode;
        private String itemName;
        private String quantity;

        // Getters and Setters
        public String getItemCode() { return itemCode; }
        public void setItemCode(String itemCode) { this.itemCode = itemCode; }
        public String getItemName() { return itemName; }
        public void setItemName(String itemName) { this.itemName = itemName; }
        public String getQuantity() { return quantity; }
        public void setQuantity(String quantity) { this.quantity = quantity; }
    }
}