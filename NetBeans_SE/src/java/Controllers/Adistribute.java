package Controllers;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.http.*;
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

        Gson gson = new Gson();
        Item[] items = gson.fromJson(jsonData, Item[].class);

        String drCode = generateNextDRCode();

        List<String> criticallyLowItems = new ArrayList<>();

        distributeItems(items, drCode, criticallyLowItems);

        response.setContentType("application/json");
        response.getWriter().write(new Gson().toJson(criticallyLowItems));
    }

    private String generateNextDRCode() {
        String nextDRCode = "DR-0001";
        String query = "SELECT MAX(dr_code) FROM delivery_receipt";

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(query);
             ResultSet resultSet = statement.executeQuery()) {

            if (resultSet.next()) {
                String maxDRCode = resultSet.getString(1);
                if (maxDRCode != null) {
                    String numericPart = maxDRCode.substring(3);
                    int nextNumber = Integer.parseInt(numericPart) + 1;
                    nextDRCode = String.format("DR-%04d", nextNumber);
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

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement updateStatement = connection.prepareStatement(updateSql);
             PreparedStatement insertReceiptStatement = connection.prepareStatement(insertReceiptSql)) {

            for (Item item : items) {
                int quantity = Integer.parseInt(item.getQuantity());

                // Get critical level from items table
                int criticalLevel = getCriticalCondition(connection, item.getItemCode());

                // Update malabon inventory
                updateStatement.setInt(1, quantity);
                updateStatement.setString(2, item.getItemCode());
                int rowsUpdated = updateStatement.executeUpdate();

                if (rowsUpdated > 0) {
                    // Insert into delivery_receipt
                    insertReceiptStatement.setString(1, drCode);
                    insertReceiptStatement.setString(2, item.getItemCode());
                    insertReceiptStatement.setString(3, item.getItemName());
                    insertReceiptStatement.setInt(4, quantity);
                    insertReceiptStatement.setString(5, item.getBranch());
                    insertReceiptStatement.executeUpdate();

                    // Check and update malabon critically_low
                    String malabonQtySql = "SELECT total_quantity FROM malabon WHERE item_code = ?";
                    try (PreparedStatement malabonQtyStmt = connection.prepareStatement(malabonQtySql)) {
                        malabonQtyStmt.setString(1, item.getItemCode());
                        ResultSet malabonQtyRs = malabonQtyStmt.executeQuery();
                        if (malabonQtyRs.next()) {
                            int malabonQty = malabonQtyRs.getInt("total_quantity");
                            boolean isCriticallyLow = malabonQty <= criticalLevel;

                            String updateCritSql = "UPDATE malabon SET critically_low = ? WHERE item_code = ?";
                            try (PreparedStatement updateCritStmt = connection.prepareStatement(updateCritSql)) {
                                updateCritStmt.setBoolean(1, isCriticallyLow);
                                updateCritStmt.setString(2, item.getItemCode());
                                updateCritStmt.executeUpdate();
                            }

                            if (isCriticallyLow) {
                                criticallyLowItems.add(item.getItemName());
                            }
                        }
                    }

                    // Insert into branch table
                    String branchTable = getBranchTable(item.getBranch());
                    try (PreparedStatement insertBranchStatement = connection.prepareStatement(String.format(insertBranchSql, branchTable))) {
                        insertBranchStatement.setString(1, item.getItemCode());
                        insertBranchStatement.setString(2, item.getItemName());
                        insertBranchStatement.setInt(3, quantity);
                        insertBranchStatement.setInt(4, quantity);
                        insertBranchStatement.executeUpdate();
                    }

                    // Check branch inventory critical level
                    String branchQtySql = "SELECT total_quantity FROM " + branchTable + " WHERE item_code = ?";
                    try (PreparedStatement branchQtyStmt = connection.prepareStatement(branchQtySql)) {
                        branchQtyStmt.setString(1, item.getItemCode());
                        ResultSet branchQtyRs = branchQtyStmt.executeQuery();
                        if (branchQtyRs.next()) {
                            int branchQty = branchQtyRs.getInt("total_quantity");
                            boolean branchIsCritical = branchQty <= criticalLevel;

                            String updateBranchCritSql = "UPDATE " + branchTable + " SET critically_low = ? WHERE item_code = ?";
                            try (PreparedStatement updateBranchCritStmt = connection.prepareStatement(updateBranchCritSql)) {
                                updateBranchCritStmt.setBoolean(1, branchIsCritical);
                                updateBranchCritStmt.setString(2, item.getItemCode());
                                updateBranchCritStmt.executeUpdate();
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

    private int getCriticalCondition(Connection connection, String itemCode) throws SQLException {
        String sql = "SELECT critical_condition FROM items WHERE item_code = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, itemCode);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("critical_condition");
                } else {
                    throw new SQLException("Critical Condition not found for item_code: " + itemCode);
                }
            }
        }
    }

    private String getBranchTable(String branch) {
        switch (branch) {
            case "bacolod": return "bacolod";
            case "cebu": return "cebu";
            case "marquee": return "marquee";
            case "olongapo": return "olongapo";
            case "subic": return "subic";
            case "tacloban": return "tacloban";
            case "tagaytay": return "tagaytay";
            case "urdaneta": return "urdaneta";
            default: throw new IllegalArgumentException("Invalid branch: " + branch);
        }
    }

    private static class Item {
        private String itemCode;
        private String itemName;
        private String quantity;
        private String branch;

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
