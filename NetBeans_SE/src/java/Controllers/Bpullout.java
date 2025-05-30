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

    // Get the current quantity in the branch table
    try (PreparedStatement quantityStmt = connection.prepareStatement(getQuantitySql)) {
        quantityStmt.setString(1, item.getItemCode());
        ResultSet rs = quantityStmt.executeQuery();
        if (rs.next()) {
            totalQuantity = rs.getInt("total_quantity");
        }
    }

    // Check if the total quantity is greater than 0 and if there's enough stock for the pullout
    if (totalQuantity <= 0) {
        System.out.println("Cannot pull out item " + item.getItemCode() + " because its total_quantity is 0 or less.");
        return; // Prevent pullout if quantity is 0 or less
    }

    if (totalQuantity < quantityToSubtract) {
        System.out.println("Not enough stock to pull out item " + item.getItemCode());
        return; // Prevent pullout if not enough stock
    }

    // Update the quantity in the branch table
    try (PreparedStatement updateStmt = connection.prepareStatement(updateQuantitySql)) {
        updateStmt.setInt(1, quantityToSubtract);
        updateStmt.setString(2, item.getItemCode());
        updateStmt.executeUpdate();
    }

    // Get updated quantity in the branch table
    try (PreparedStatement quantityStmt = connection.prepareStatement(getQuantitySql)) {
        quantityStmt.setString(1, item.getItemCode());
        ResultSet rs = quantityStmt.executeQuery();
        if (rs.next()) {
            totalQuantity = rs.getInt("total_quantity");
        }
    }

    // Get the critical condition from the items table
    try (PreparedStatement criticalStmt = connection.prepareStatement(getCriticalSql)) {
        criticalStmt.setString(1, item.getItemCode());
        ResultSet rs = criticalStmt.executeQuery();
        if (rs.next()) {
            criticalCondition = rs.getInt("critical_condition");
        }
    }

    // Check if the item is critically low and update the branch table
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
        String insertReceiptSql = "INSERT INTO pullout_receipt (pullout_code, item_code, item_name, quantity, branch, reason) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement preparedStatement = connection.prepareStatement(insertReceiptSql)) {
            preparedStatement.setString(1, PoCode);
            preparedStatement.setString(2, item.getItemCode());
            preparedStatement.setString(3, item.getItemName());
            preparedStatement.setInt(4, Integer.parseInt(item.getQuantity()));
            preparedStatement.setString(5, branch);
            preparedStatement.setString(6, item.getReason());
            preparedStatement.executeUpdate();
        }
    }

    // Inner class to represent the item structure
    public static class Item {
        private String itemCode;
        private String itemName;
        private String quantity;
        private String reason;

        // Getters and Setters
        public String getItemCode() { return itemCode; }
        public void setItemCode(String itemCode) { this.itemCode = itemCode; }
        public String getItemName() { return itemName; }
        public void setItemName(String itemName) { this.itemName = itemName; }
        public String getQuantity() { return quantity; }
        public void setQuantity(String quantity) { this.quantity = quantity; }
        public String getReason() { return reason; }
        public void setReason(String reason) { this.reason = reason; }
    }
}