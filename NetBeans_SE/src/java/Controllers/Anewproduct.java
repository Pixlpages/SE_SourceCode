package Controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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
            int criticalCondition = Integer.parseInt(request.getParameter("critical_condition"));
            String itemDescription = request.getParameter("item_description");

            // Create a new item without critically_low
            DBManager.Item newItem = new DBManager.Item(itemCode, itemName, itemCategory, petCategory, totalQuantity, criticalCondition, itemDescription);

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
        } else if ("removeItem".equals(action)) {
            String itemCodeToRemove = request.getParameter("item_code");

            List<DBManager.Item> itemList = (List<DBManager.Item>) request.getSession().getAttribute("itemList");
            if (itemList != null) {
                itemList.removeIf(item -> item.getItemCode().equals(itemCodeToRemove));
                request.getSession().setAttribute("itemList", itemList);
                request.setAttribute("message", "Item removed from list.");
                request.setAttribute("messageType", "success");
            } else {
                request.setAttribute("message", "Item list is empty.");
                request.setAttribute("messageType", "error");
            }
        }

        // Forward back to the JSP page
        request.getRequestDispatcher("Anewproduct.jsp").forward(request, response);
    }

    private void addAllItemsToDatabase(List<DBManager.Item> itemList) throws SQLException {
        String insertItemsSql = "INSERT INTO items (item_code, item_name, item_category, pet_category, total_quantity, critical_condition, item_description) VALUES (?, ?, ?, ?, ?, ?, ?)";
        String insertMalabonSql = "INSERT INTO malabon (item_code, item_name, total_quantity, critically_low, item_description) VALUES (?, ?, ?, ?, ?)";

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement insertItemsStatement = connection.prepareStatement(insertItemsSql);
             PreparedStatement insertMalabonStatement = connection.prepareStatement(insertMalabonSql)) {

            for (DBManager.Item item : itemList) {
                // Insert into items table (without critically_low)
                insertItemsStatement.setString(1, item.getItemCode());
                insertItemsStatement.setString(2, item.getItemName());
                insertItemsStatement.setString(3, item.getItemCategory());
                insertItemsStatement.setString(4, item.getPetCategory());
                insertItemsStatement.setInt(5, item.getTotalQuantity());
                insertItemsStatement.setInt(6, item.getCriticalCondition());
                insertItemsStatement.setString(7, item.getItemDescription());
                insertItemsStatement.addBatch(); // Add to batch for items

                // Insert into malabon table with critically_low
                boolean criticallyLow = item.getTotalQuantity() < 100; // Set critically_low based on total_quantity
                insertMalabonStatement.setString(1, item.getItemCode());
                insertMalabonStatement.setString(2, item.getItemName());
                insertMalabonStatement.setInt(3, item.getTotalQuantity());
                insertMalabonStatement.setBoolean(4, criticallyLow); // Insert critically_low value
                insertMalabonStatement.setString(5, item.getItemDescription());
                insertMalabonStatement.addBatch(); // Add to batch for malabon
            }

            // Execute batch inserts
            insertItemsStatement.executeBatch();
            insertMalabonStatement.executeBatch();
        }
    }
}
