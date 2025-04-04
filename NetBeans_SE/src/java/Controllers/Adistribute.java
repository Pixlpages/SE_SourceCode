package Controllers;

import java.io.IOException;
import java.io.PrintWriter;
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
        String sql = "UPDATE products_test SET total_quantity = total_quantity - ? WHERE item_code = ? AND branch = ?";
        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            for (Item item : items) {
                preparedStatement.setInt(1, Integer.parseInt(item.getQuantity()));
                preparedStatement.setString(2, item.getItemCode());
                preparedStatement.setString(3, item.getBranch()); // Include the branch in the update
                preparedStatement.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private static class Item {
        private String itemCode;
        private String quantity;
        private String branch; // Add branch property

        // Getters and Setters
        public String getItemCode() { return itemCode; }
        public void setItemCode(String itemCode) { this.itemCode = itemCode; }
        public String getQuantity() { return quantity; }
        public void setQuantity(String quantity) { this.quantity = quantity; }
        public String getBranch() { return branch; }
        public void setBranch(String branch) { this.branch = branch; }
    }
}