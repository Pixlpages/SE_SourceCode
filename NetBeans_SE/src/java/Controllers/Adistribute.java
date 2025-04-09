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
import com.google.gson.Gson;

public class Adistribute extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        StringBuilder jsonBuffer = new StringBuilder();
        String line;
        BufferedReader reader = request.getReader();
        while ((line = reader.readLine()) != null) {
            jsonBuffer.append(line);
        }
        String jsonData = jsonBuffer.toString();

        // Parse the JSON data
        Gson gson = new Gson();
        Item[] items = gson.fromJson(jsonData, Item[].class);

        // Generate the next DR code
        String drCode = generateNextDRCode();

        // Create a list to hold critically low items
        List<String> criticallyLowItems = new ArrayList<>();

        // Call the method to distribute items and save delivery receipt
        distributeItems(items, drCode, criticallyLowItems);

        // Return the critically low items as JSON
        response.setContentType("application/json");
        response.getWriter().write(new Gson().toJson(criticallyLowItems));
    }

    private String generateNextDRCode() {
        String nextDRCode = "DR-0001"; // Default value
        String query = "SELECT MAX(dr_code) FROM delivery_receipt";

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(query);
             ResultSet resultSet = statement.executeQuery()) {

            if (resultSet.next()) {
                String maxDRCode = resultSet.getString(1);
                if (maxDRCode != null) {
                    // Extract the numeric part and increment it
                    String numericPart = maxDRCode.substring(3); // Get the part after "DR-"
                    int nextNumber = Integer.parseInt(numericPart) + 1;
                    nextDRCode = String.format("DR-%04d", nextNumber); // Format to DR-0001, DR-0002, etc.
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return nextDRCode;
    }

    private void distributeItems(Item[] items, String drCode, List<String> criticallyLowItems) {
        String updateSql = "UPDATE malabon SET total_quantity = total_quantity - ? WHERE item_code = ?";
        String insertReceiptSql = "INSERT INTO delivery_receipt (dr_code, item_code, item_name, quantity, branch) VALUES (?, ?, ?, ?, ?)";
        String insertBranchSql = "INSERT INTO %s (item_code, item_name, total_quantity) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE total_quantity = total_quantity + ?";
        String updateCriticalLowSql = "UPDATE malabon SET critically_low = 1 WHERE item_code = ? AND total_quantity <= 100";

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement updateStatement = connection.prepareStatement(updateSql);
             PreparedStatement insertReceiptStatement = connection.prepareStatement(insertReceiptSql);
             PreparedStatement updateCriticalLowStatement = connection.prepareStatement(updateCriticalLowSql)) {

            for (Item item : items) {
                // Update the quantity in malabon
                updateStatement.setInt(1, Integer.parseInt(item.getQuantity()));
                updateStatement.setString(2, item.getItemCode());
                int rowsUpdated = updateStatement.executeUpdate();

                if (rowsUpdated > 0) {
                    // Insert into delivery_receipt for each item
                    insertReceiptStatement.setString(1, drCode); // Use the same DR code for all items
                    insertReceiptStatement.setString(2, item.getItemCode());
                    insertReceiptStatement.setString(3, item.getItemName());
                    insertReceiptStatement.setInt(4, Integer.parseInt(item.getQuantity()));
                    insertReceiptStatement.setString(5, item.getBranch());
                    insertReceiptStatement.executeUpdate();

                    // Check if the item is critically low in the malabon table
                    updateCriticalLowStatement.setString(1, item.getItemCode());
                    int affectedRows = updateCriticalLowStatement.executeUpdate();
                    if (affectedRows > 0) {
                        criticallyLowItems.add(item.getItemName()); // Add item name to the list
                    }

                    // Insert into the appropriate branch table (staff table)
                    String branchTable = getBranchTable(item.getBranch());
                    try (PreparedStatement insertBranchStatement = connection.prepareStatement(String.format(insertBranchSql, branchTable))) {
                        insertBranchStatement.setString(1, item.getItemCode());
                        insertBranchStatement.setString(2, item.getItemName());
                        insertBranchStatement.setInt(3, Integer.parseInt(item.getQuantity()));
                        insertBranchStatement.setInt(4, Integer.parseInt(item.getQuantity())); // For ON DUPLICATE KEY UPDATE
                        insertBranchStatement.executeUpdate();

                        // After inserting into the branch table, check if the quantity is below or above 100
                        String checkQuantitySql = "SELECT total_quantity FROM " + branchTable + " WHERE item_code = ?";
                        try (PreparedStatement checkStmt = connection.prepareStatement(checkQuantitySql)) {
                            checkStmt.setString(1, item.getItemCode());
                            ResultSet rs = checkStmt.executeQuery();

                            if (rs.next()) {
                                int totalQuantity = rs.getInt("total_quantity");

                                // If total_quantity is less than or equal to 100, set critically_low to true
                                if (totalQuantity <= 100) {
                                    String updateCriticallyLowSql = "UPDATE " + branchTable + " SET critically_low = 1 WHERE item_code = ?";
                                    try (PreparedStatement updateCriticallyLowStmt = connection.prepareStatement(updateCriticallyLowSql)) {
                                        updateCriticallyLowStmt.setString(1, item.getItemCode());
                                        updateCriticallyLowStmt.executeUpdate();
                                    }
                                } else {
                                    // If total_quantity is above 100, set critically_low to false
                                    String updateCriticallyLowSql = "UPDATE " + branchTable + " SET critically_low = 0 WHERE item_code = ?";
                                    try (PreparedStatement updateCriticallyLowStmt = connection.prepareStatement(updateCriticallyLowSql)) {
                                        updateCriticallyLowStmt.setString(1, item.getItemCode());
                                        updateCriticallyLowStmt.executeUpdate();
                                    }
                                }
                            }
                        }
                    }
                } else {
                    System.out.println("No rows updated for item code: " + item.getItemCode());
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private String getBranchTable(String branch) {
        // Map branch names to table names
        switch (branch) {
            case "bacolod":
                return "bacolod"; // Ensure this matches your actual branch table name
            case "cebu":
                return "cebu";
            case "marquee":
                return "marquee";
            case "olongapo":
                return "olongapo";
            case "subic":
                return "subic";
            case "tacloban":
                return "tacloban";
            case "tagaytay":
                return "tagaytay";
            case "urdaneta":
                return "urdaneta";
            // Add more branches as needed
            default:
                throw new IllegalArgumentException("Invalid branch: " + branch);
        }
    }

    private static class Item {
        private String itemCode;
        private String itemName; // Add itemName property
        private String quantity;
        private String branch; // Add branch property

        // Getters and Setters
        public String getItemCode() { return itemCode; }
        public void setItemCode(String itemCode) { this.itemCode = itemCode; }
        public String getItemName() { return itemName; }
        public void setItemName(String itemName) { this.itemName = itemName; }
        public String getQuantity() { return quantity; }
        public void setQuantity(String quantity) { this.quantity = quantity; }
        public String getBranch() { return branch; }
        public void setBranch(String branch) { this.branch = branch; }
    }
}
