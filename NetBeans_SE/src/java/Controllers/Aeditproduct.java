package Controllers;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.google.gson.Gson;

public class Aeditproduct extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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

        try {
            updateItemsInDatabase(items);
            response.setStatus(HttpServletResponse.SC_OK);
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void updateItemsInDatabase(Item[] items) throws SQLException {
        String updateItemsSql = "UPDATE items SET item_name = ?, item_category = ?, pet_category = ?, critical_condition = ? WHERE item_code = ?";

        // Branch tables to update
        String[] branches = {
            "malabon", "bacolod", "cebu", "marquee", "olongapo",
            "subic", "tacloban", "tagaytay", "urdaneta"
        };
        String updateBranchSqlTemplate = "UPDATE %s SET item_name = ? WHERE item_code = ?";

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement updateItemsStmt = connection.prepareStatement(updateItemsSql)) {

            for (Item item : items) {
                // Update in items table
                updateItemsStmt.setString(1, item.getItemName());
                updateItemsStmt.setString(2, item.getItemCategory());
                updateItemsStmt.setString(3, item.getPetCategory());
                updateItemsStmt.setInt(4, item.getCriticalCondition());
                updateItemsStmt.setString(5, item.getItemCode());
                updateItemsStmt.addBatch();

                // Update item_name in all branch tables
                for (String branch : branches) {
                    String updateBranchSql = String.format(updateBranchSqlTemplate, branch);
                    try (PreparedStatement updateBranchStmt = connection.prepareStatement(updateBranchSql)) {
                        updateBranchStmt.setString(1, item.getItemName());
                        updateBranchStmt.setString(2, item.getItemCode());
                        updateBranchStmt.executeUpdate();
                    }
                }
            }

            updateItemsStmt.executeBatch(); // Execute all batched item updates
        }
    }

    private static class Item {
        private String itemCode;
        private String itemName;
        private String itemCategory;
        private String petCategory;
        private int criticalCondition;

        // Getters and Setters
        public String getItemCode() { return itemCode; }
        public void setItemCode(String itemCode) { this.itemCode = itemCode; }
        public String getItemName() { return itemName; }
        public void setItemName(String itemName) { this.itemName = itemName; }
        public String getItemCategory() { return itemCategory; }
        public void setItemCategory(String itemCategory) { this.itemCategory = itemCategory; }
        public String getPetCategory() { return petCategory; }
        public void setPetCategory(String petCategory) { this.petCategory = petCategory; }
        public int getCriticalCondition() { return criticalCondition; }
        public void setCriticalCondition(int criticalCondition) { this.criticalCondition = criticalCondition; }
    }
}
