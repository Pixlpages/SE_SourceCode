package Controllers;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

@WebServlet("/Aincreasequantity")
public class Aincreasequantity extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        System.out.println("Action: " + action); // Log the action

        if ("updateQuantity".equals(action)) {
            String itemsToUpdateJson = request.getParameter("itemsToUpdate");
            System.out.println("Items to Update JSON: " + itemsToUpdateJson); // Log the JSON data

            // Check if itemsToUpdateJson is null or empty
            if (itemsToUpdateJson == null || itemsToUpdateJson.isEmpty()) {
                System.out.println("No items to update.");
                return; // Exit if there's nothing to update
            }

            // Parse the JSON and update quantities
            Gson gson = new Gson();
            JsonArray itemsArray = gson.fromJson(itemsToUpdateJson, JsonArray.class);

            for (int i = 0; i < itemsArray.size(); i++) {
                JsonObject item = itemsArray.get(i).getAsJsonObject();
                String itemCode = item.get("itemCode").getAsString();
                int quantity = item.get("quantity").getAsInt(); // This line can throw NumberFormatException if quantity is null

                // Check if quantity is valid
                if (quantity > 0) {
                    try {
                        // Call your method to update the quantity
                        increaseItemQuantity(itemCode, quantity);
                    } catch (SQLException e) {
                        System.out.println("Error updating quantity for item: " + itemCode);
                        e.printStackTrace(); // Log the exception for debugging
                    }
                } else {
                    System.out.println("Invalid quantity for item: " + itemCode);
                }
            }

            // Return a success response
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"success\": true}");
            out.flush();
        }
    }

    private boolean increaseItemQuantity(String itemCode, int quantity) throws SQLException {
        String sql = "UPDATE products_test SET total_quantity = total_quantity + ? WHERE item_code = ?";

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setInt(1, quantity);
            preparedStatement.setString(2, itemCode);
            int rowsUpdated = preparedStatement.executeUpdate();
            return rowsUpdated > 0; // Return true if the update was successful
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<DBManager.Item> items = fetchItems(); // Fetch all items from the database

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        // Create a response object for DataTables
        JsonObject jsonResponse = new JsonObject();
        jsonResponse.addProperty("sEcho", request.getParameter("sEcho"));
        jsonResponse.addProperty("iTotalRecords", items.size());
        jsonResponse.addProperty("iTotalDisplayRecords", items.size());

        JsonArray dataArray = new JsonArray();
        for (DBManager.Item item : items) {
            JsonArray row = new JsonArray();
            row.add(item.getItemCode());
            row.add(item.getItemName());
            row.add(item.getTotalQuantity());
            dataArray.add(row);
        }
        jsonResponse.add("aaData", dataArray);

        // Send JSON response
        out.print(jsonResponse.toString());
        out.flush();
    }

    private List<DBManager.Item> fetchItems() {
        List<DBManager.Item> items = new ArrayList<>();
        String sql = "SELECT item_code, item_name, total_quantity FROM products_test"; // Adjust the query as needed

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql);
             ResultSet resultSet = preparedStatement.executeQuery()) {

            while (resultSet.next()) {
                DBManager.Item item = new DBManager.Item();
                item.setItemCode(resultSet.getString("item_code"));
                item.setItemName(resultSet.getString("item_name"));
                item.setTotalQuantity(resultSet.getInt("total_quantity"));
                items.add(item);
            }
        } catch (SQLException e) {
            e.printStackTrace(); // Log the exception for debugging
        }
        return items;
    }
}