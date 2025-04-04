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

@WebServlet("/Aeditproduct")
public class Aeditproduct extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String itemCode = request.getParameter("itemCode");
        String itemName = request.getParameter("itemName");
        String itemCategory = request.getParameter("itemCategory");

        try {
            updateItemInDatabase(itemCode, itemName, itemCategory);
            response.setStatus(HttpServletResponse.SC_OK);
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void updateItemInDatabase(String itemCode, String itemName, String itemCategory) throws SQLException {
        String sql = "UPDATE products_test SET item_name = ?, item_category = ? WHERE item_code = ?";

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setString(1, itemName);
            preparedStatement.setString(2, itemCategory);
            preparedStatement.setString(3, itemCode);
            preparedStatement.executeUpdate();
        }
    }
}