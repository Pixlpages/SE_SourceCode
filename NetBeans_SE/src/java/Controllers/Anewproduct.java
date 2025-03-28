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

@WebServlet("/AddItemServlet")
public class Anewproduct extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String itemCode = request.getParameter("item_code");
        String itemName = request.getParameter("item_name");
        String itemCategory = request.getParameter("item_category");
        String petCategory = request.getParameter("pet_category");
        int totalQuantity = Integer.parseInt(request.getParameter("total_quantity"));

        // Call method to add item to the database
        try {
            addItemToDatabase(itemCode, itemName, itemCategory, petCategory, totalQuantity);
            response.sendRedirect("success.jsp"); // Redirect to a success page
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp"); // Redirect to an error page
        }
    }

    private void addItemToDatabase(String itemCode, String itemName, String itemCategory, String petCategory, int totalQuantity) throws SQLException {
        String sql = "INSERT INTO product_inventory (item_code, item_name, item_category, pet_category, total_quantity) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
             
            preparedStatement.setString(1, itemCode);
            preparedStatement.setString(2, itemName);
            preparedStatement.setString(3, itemCategory);
            preparedStatement.setString(4, petCategory);
            preparedStatement.setInt(5, totalQuantity);
            preparedStatement.executeUpdate();
        }
    }
}