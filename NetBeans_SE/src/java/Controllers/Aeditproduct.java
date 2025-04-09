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

        // Call the method to update items
        try {
            updateItemsInDatabase(items);
            response.setStatus(HttpServletResponse.SC_OK);
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    // Method to update items in the database
    private void updateItemsInDatabase(Item[] items) throws SQLException {
        String sql = "UPDATE items SET item_name = ?, item_category = ?, pet_category = ? WHERE item_code = ?";

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            for (Item item : items) {
                preparedStatement.setString(1, item.getItemName());
                preparedStatement.setString(2, item.getItemCategory());
                preparedStatement.setString(3, item.getPetCategory());
                preparedStatement.setString(4, item.getItemCode());
                preparedStatement.addBatch(); // Add to batch
            }
            preparedStatement.executeBatch(); // Execute batch update
        }
    }

    private static class Item {
        private String itemCode;
        private String itemName; // Add itemName property
        private String itemCategory; // Add itemCategory property
        private String petCategory; // Add petCategory property

        // Getters and Setters
        public String getItemCode() { return itemCode; }
        public void setItemCode(String itemCode) { this.itemCode = itemCode; }
        public String getItemName() { return itemName; }
        public void setItemName(String itemName) { this.itemName = itemName; }
        public String getItemCategory() { return itemCategory; }
        public void setItemCategory(String itemCategory) { this.itemCategory = itemCategory; }
        public String getPetCategory() { return petCategory; }
        public void setPetCategory(String petCategory) { this.petCategory = petCategory; }
    }
}