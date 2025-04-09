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
import javax.servlet.http.HttpSession;
import com.google.gson.Gson;

@WebServlet("/Bgetproducts")
public class Bgetproducts extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        DBManager dbManager = new DBManager();
        HttpSession session = request.getSession();
        
        // Assuming the branch name is stored in the session after login
        String branch = (String) session.getAttribute("branch"); // Get the branch from session

        if (branch != null) {
            fetchProductsFromDatabase(dbManager, branch); // Populate the DBManager with products from the branch
            List<DBManager.Item> products = dbManager.getItemList(); // Get the populated item list
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            Gson gson = new Gson();
            String json = gson.toJson(products);
            out.print(json);
            out.flush();
        } else {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "User  not logged in or branch not found.");
        }
    }

    // Method to fetch products from the branch database and populate the DBManager's item list
    private void fetchProductsFromDatabase(DBManager dbManager, String branch) {
        // Construct the SQL query to fetch products from the specific branch table
        String sql = "SELECT item_code, item_name, total_quantity, critically_low FROM " + branch;

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql);
             ResultSet resultSet = preparedStatement.executeQuery()) {

            while (resultSet.next()) {
                DBManager.Item item = new DBManager.Item();
                item.setItemCode(resultSet.getString("item_code"));
                item.setItemName(resultSet.getString("item_name"));
                item.setTotalQuantity(resultSet.getInt("total_quantity"));
                item.setCriticallyLow(resultSet.getInt("critically_low")); // Assuming you have this method in your Item class
                dbManager.addItem(item); // Add item to DBManager's list
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}