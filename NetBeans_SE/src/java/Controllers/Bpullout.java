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

        String PoCode = generateNextPullOutCode();

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

    private String generateNextPullOutCode() {
        String nextPOCode = "PO-0001"; // Default value
        String query = "SELECT MAX(pullout_code) FROM pullout_receipt";

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(query);
             ResultSet resultSet = statement.executeQuery()) {

            if (resultSet.next()) {
                String maxPOCode = resultSet.getString(1);
                if (maxPOCode != null) {
                    // Extract the numeric part and increment it
                    String numericPart = maxPOCode.substring(3); // Get the part after "PO-"
                    int nextNumber = Integer.parseInt(numericPart) + 1;
                    nextPOCode = String.format("PO-%04d", nextNumber); // Format to PO-0001, PO-0002, etc.
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
        // Check if the item is critically low in the malabon table
        String checkQuantitySql = "SELECT total_quantity FROM malabon WHERE item_code = ?";
        try (PreparedStatement checkStmt = connection.prepareStatement(checkQuantitySql)) {
            checkStmt.setString(1, item.getItemCode());
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next()) {
                int totalQuantity = rs.getInt("total_quantity");

                // If total_quantity is less than or equal to 100, add item to criticallyLowItems list
                if (totalQuantity <= 100) {
                    criticallyLowItems.add(item.getItemName());
                }

                // Update critically_low flag in the malabon table
                String updateCriticallyLowSql = "UPDATE malabon SET critically_low = ? WHERE item_code = ?";
                try (PreparedStatement updateCriticallyLowStmt = connection.prepareStatement(updateCriticallyLowSql)) {
                    updateCriticallyLowStmt.setInt(1, totalQuantity <= 100 ? 1 : 0);
                    updateCriticallyLowStmt.setString(2, item.getItemCode());
                    updateCriticallyLowStmt.executeUpdate();
                }
            }
        }
    }

    private void subtractFromBranchTable(Connection connection, Item item, String branch, List<String> criticallyLowItems) throws SQLException {
        String updateBranchSql = "UPDATE " + branch + " SET total_quantity = total_quantity - ? WHERE item_code = ?";
        try (PreparedStatement preparedStatement = connection.prepareStatement(updateBranchSql)) {
            preparedStatement.setInt(1, Integer.parseInt(item.getQuantity()));
            preparedStatement.setString(2, item.getItemCode());
            preparedStatement.executeUpdate();
        }

        // Check if the item is critically low in the branch table
        String checkQuantitySql = "SELECT total_quantity FROM " + branch + " WHERE item_code = ?";
        try (PreparedStatement checkStmt = connection.prepareStatement(checkQuantitySql)) {
            checkStmt.setString(1, item.getItemCode());
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next()) {
                int totalQuantity = rs.getInt("total_quantity");

                // If total_quantity is less than or equal to 100, add item to criticallyLowItems list
                if (totalQuantity <= 100) {
                    criticallyLowItems.add(item.getItemName());
                }

                // Update critically_low flag in the branch table
                String updateCriticallyLowSql = "UPDATE " + branch + " SET critically_low = ? WHERE item_code = ?";
                try (PreparedStatement updateCriticallyLowStmt = connection.prepareStatement(updateCriticallyLowSql)) {
                    updateCriticallyLowStmt.setInt(1, totalQuantity <= 100 ? 1 : 0);
                    updateCriticallyLowStmt.setString(2, item.getItemCode());
                    int affectedRows = updateCriticallyLowStmt.executeUpdate();
                    if (affectedRows > 0 && totalQuantity <= 100) {
                        criticallyLowItems.add(item.getItemName()); // Add item name to the list
                    }
                }
            }
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