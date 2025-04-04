package Controllers;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.google.gson.Gson;

@WebServlet("/Agetproducts")
public class Agetproducts extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        DBManager dbManager = new DBManager();
        fetchProductsFromDatabase(dbManager); // Populate the DBManager with products
        List<DBManager.Item> products = dbManager.getItemList(); // Get the populated item list
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();
        String json = gson.toJson(products);
        out.print(json);
        out.flush();
    }

    // Method to fetch products from the database and populate the DBManager's item list
    private void fetchProductsFromDatabase(DBManager dbManager) {
        String sql = "SELECT item_code, item_name, item_category, pet_category, total_quantity FROM products_test";

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql);
             ResultSet resultSet = preparedStatement.executeQuery()) {

            while (resultSet.next()) {
                DBManager.Item item = new DBManager.Item();
                item.setItemCode(resultSet.getString("item_code"));
                item.setItemName(resultSet.getString("item_name"));
                item.setItemCategory(resultSet.getString("item_category"));
                item.setPetCategory(resultSet.getString("pet_category"));
                item.setTotalQuantity(resultSet.getInt("total_quantity"));
                dbManager.addItem(item); // Add item to DBManager's list
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}