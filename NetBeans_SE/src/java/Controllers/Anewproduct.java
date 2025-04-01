package Controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
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
        String action = request.getParameter("action");

        // Retrieve the DBManager from the session
        DBManager DBManager = (DBManager) request.getSession().getAttribute("DBManager");

        if ("addItem".equals(action)) {
            // Handle adding a single item to the list
            String itemCode = request.getParameter("item_code");
            String itemName = request.getParameter("item_name");
            String itemCategory = request.getParameter("item_category");
            String petCategory = request.getParameter("pet_category");
            int totalQuantity = Integer.parseInt(request.getParameter("total_quantity"));

            // Create a new item
            DBManager.Item newItem = new DBManager.Item(itemCode, itemName, itemCategory, petCategory, totalQuantity);

            // Store items in the session's item list
            List<DBManager.Item> itemList = (List<DBManager.Item>) request.getSession().getAttribute("itemList");
            if (itemList == null) {
                itemList = new ArrayList<>();
            }
            itemList.add(newItem);
            request.getSession().setAttribute("itemList", itemList);

            request.setAttribute("message", "Item added to list!");
            request.setAttribute("messageType", "success");
        } else if ("addAllItems".equals(action)) {
            // Handle adding all items to the database
            List<DBManager.Item> itemList = (List<DBManager.Item>) request.getSession().getAttribute("itemList");

            if (itemList != null && !itemList.isEmpty()) {
                try {
                    addAllItemsToDatabase(itemList);
                    request.setAttribute("message", "All items added successfully!");
                    request.setAttribute("messageType", "success");
                    // Clear the item list after adding to the database
                    request.getSession().removeAttribute("itemList");
                } catch (SQLException e) {
                    e.printStackTrace();
                    request.setAttribute("message", "Error adding items: " + e.getMessage());
                    request.setAttribute("messageType", "error");
                }
            } else {
                request.setAttribute("message", "No items to add.");
                request.setAttribute("messageType", "error");
            }
        }

        // Forward back to the JSP page
        request.getRequestDispatcher("Anewproduct.jsp").forward(request, response);
    }

    private void addAllItemsToDatabase(List<DBManager.Item> itemList) throws SQLException {
        String sql = "INSERT INTO products_test (item_code, item_name, item_category, pet_category, total_quantity) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
             
            for (DBManager.Item item : itemList) {
                preparedStatement.setString(1, item.getItemCode());
                preparedStatement.setString(2, item.getItemName());
                preparedStatement.setString(3, item.getItemCategory());
                preparedStatement.setString(4, item.getPetCategory());
                preparedStatement.setInt(5, item.getTotalQuantity());
                preparedStatement.addBatch(); // Add to batch
            }
            preparedStatement.executeBatch(); // Execute batch insert
        }
    }
}