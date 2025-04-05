package Controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.google.gson.Gson;

@WebServlet("/Adistribute")
public class Adistribute extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("distributeItems".equals(action)) {
            String itemsData = request.getParameter("itemsToDistribute");
            Gson gson = new Gson();
            Item[] items = gson.fromJson(itemsData, Item[].class);
            distributeItems(items);
            response.setStatus(HttpServletResponse.SC_OK);
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    private void distributeItems(Item[] items) {
        String updateSql = "UPDATE items SET total_quantity = total_quantity - ? WHERE item_code = ?";
        String insertSql = "INSERT INTO %s (item_code, total_quantity) VALUES (?, ?) ON DUPLICATE KEY UPDATE total_quantity = total_quantity + ?";

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement updateStatement = connection.prepareStatement(updateSql)) {

            for (Item item : items) {
                // Update the quantity in products_test
                updateStatement.setInt(1, Integer.parseInt(item.getQuantity()));
                updateStatement.setString(2, item.getItemCode());
                int rowsUpdated = updateStatement.executeUpdate();

                if (rowsUpdated > 0) {
                    // Only insert into the branch table if the update was successful
                    String branchTable = getBranchTable(item.getBranch());
                    String formattedInsertSql = String.format(insertSql, branchTable);
                    try (PreparedStatement insertStatement = connection.prepareStatement(formattedInsertSql)) {
                        insertStatement.setString(1, item.getItemCode());
                        insertStatement.setInt(2, Integer.parseInt(item.getQuantity())); // Insert quantity
                        insertStatement.setInt(3, Integer.parseInt(item.getQuantity())); // For ON DUPLICATE KEY UPDATE
                        insertStatement.executeUpdate();
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
            case "Branch1":
                return "malabon"; // Ensure this matches your actual branch table name
            case "Branch2":
                return "branch2";
            case "Branch3":
                return "branch3";
            // Add more branches as needed
            default:
                throw new IllegalArgumentException("Invalid branch: " + branch);
        }
    }

    private static class Item {
        private String itemCode;
        private String quantity;
        private String branch;

        // Getters and Setters
        public String getItemCode() { return itemCode; }
        public void setItemCode(String itemCode) { this.itemCode = itemCode; }
        public String getQuantity() { return quantity; }
        public void setQuantity(String quantity) { this.quantity = quantity; }
        public String getBranch() { return branch; }
        public void setBranch(String branch) { this.branch = branch; }
    }
}