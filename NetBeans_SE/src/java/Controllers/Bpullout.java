package Controllers;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.google.gson.Gson;

@WebServlet("/Bpullout")
public class Bpullout extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        HttpSession session = request.getSession();
        String branch = (String) session.getAttribute("username"); // Get the branch from session

        if (branch == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "User  not logged in or branch not found.");
            return;
        }

        // Read the JSON data from the request
        StringBuilder jsonBuffer = new StringBuilder();
        String line;
        while ((line = request.getReader().readLine()) != null) {
            jsonBuffer.append(line);
        }
        
        // Parse the JSON data into a list of items
        Gson gson = new Gson();
        Item[] itemsToPullout = gson.fromJson(jsonBuffer.toString(), Item[].class);

        // Pull out the items
        try (Connection connection = DatabaseUtil.getConnection()) {
            connection.setAutoCommit(false); // Start transaction

            // Update quantities in the branch table and log in delivery receipt
            for (Item item : itemsToPullout) {
                updateBranchTable(connection, branch, item);
                logDeliveryReceipt(connection, item, branch);
            }

            connection.commit(); // Commit transaction
            response.setStatus(HttpServletResponse.SC_OK);
            PrintWriter out = response.getWriter();
            out.print("{\"message\": \"Items pulled out successfully!\"}");
            out.flush();
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error pulling out items.");
        }
    }

    private void updateBranchTable(Connection connection, String branch, Item item) throws SQLException {
        String updateSql = "UPDATE " + branch + " SET total_quantity = total_quantity - ? WHERE item_code = ?";
        try (PreparedStatement preparedStatement = connection.prepareStatement(updateSql)) {
            preparedStatement.setInt(1, Integer.parseInt(item.getQuantity()));
            preparedStatement.setString(2, item.getItemCode());
            int rowsUpdated = preparedStatement.executeUpdate();
            if (rowsUpdated == 0) {
                throw new SQLException("No rows updated for item code: " + item.getItemCode());
            }
        }
    }

    private void logDeliveryReceipt(Connection connection, Item item, String branch) throws SQLException {
        String insertReceiptSql = "INSERT INTO delivery_receipt (dr_code, item_code, quantity, branch) VALUES (?, ?, ?, ?)";
        String drCode = generateDRCode(); // Generate a new DR code

        try (PreparedStatement preparedStatement = connection.prepareStatement(insertReceiptSql)) {
            preparedStatement.setString(1, drCode);
            preparedStatement.setString(2, item.getItemCode());
            preparedStatement.setInt(3, Integer.parseInt(item.getQuantity()));
            preparedStatement.setString(4, branch);
            preparedStatement.executeUpdate();
        }
    }

    private String generateDRCode() {
        // Implement your logic to generate a unique DR code
        return "DR-" + System.currentTimeMillis(); // Simple example using current time
    }

    // Inner class to represent the item structure
    public static class Item {
        private String itemCode;
        private String quantity; // Quantity as a string to match the input type

        // Getters and Setters
        public String getItemCode() { return itemCode; }
        public void setItemCode(String itemCode) { this.itemCode = itemCode; }
        public String getQuantity() { return quantity; }
        public void setQuantity(String quantity) { this.quantity = quantity; }
    }
}