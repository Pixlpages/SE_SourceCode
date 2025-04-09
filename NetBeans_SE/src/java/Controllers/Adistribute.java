package Controllers;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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

        // Call the method to distribute items and save delivery receipt
        distributeItems(items, drCode);
        response.setStatus(HttpServletResponse.SC_OK);
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

    private void distributeItems(Item[] items, String drCode) {
        String updateSql = "UPDATE malabon SET total_quantity = total_quantity - ? WHERE item_code = ?";
        String insertReceiptSql = "INSERT INTO delivery_receipt (dr_code, item_code, quantity, branch) VALUES (?, ?, ?, ?)";

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement updateStatement = connection.prepareStatement(updateSql);
             PreparedStatement insertReceiptStatement = connection.prepareStatement(insertReceiptSql)) {

            for (Item item : items) {
                // Update the quantity in malabon
                updateStatement.setInt(1, Integer.parseInt(item.getQuantity()));
                updateStatement.setString(2, item.getItemCode());
                int rowsUpdated = updateStatement.executeUpdate();

                if (rowsUpdated > 0) {
                    // Insert into delivery_receipt for each item
                    insertReceiptStatement.setString(1, drCode); // Use the same DR code for all items
                    insertReceiptStatement.setString(2, item.getItemCode());
                    insertReceiptStatement.setInt(3, Integer.parseInt(item.getQuantity()));
                    insertReceiptStatement.setString(4, item.getBranch());
                    insertReceiptStatement.executeUpdate();
                } else {
                    System.out.println("No rows updated for item code: " + item.getItemCode());
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
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
