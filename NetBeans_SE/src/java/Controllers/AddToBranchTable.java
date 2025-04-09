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

@WebServlet("/AddToBranchTable")
public class AddToBranchTable extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Read JSON input from the request
        StringBuilder jsonString = new StringBuilder();
        String line;
        while ((line = request.getReader().readLine()) != null) {
            jsonString.append(line);
        }

        // Parse the JSON string into an object
        Gson gson = new Gson();
        ReceiptData data = gson.fromJson(jsonString.toString(), ReceiptData.class);

        // Log the parsed data for debugging
        System.out.println("Parsed data: " + jsonString.toString());

        // Get the branch from session
        String branch = (String) request.getSession().getAttribute("username");

        // Handle adding/updating the branch table
        String result = addOrUpdateItemInBranch(branch, data.getItemCode(), data.getQuantity(), data.getItemName());

        // Prepare response
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        out.print("{\"status\":\"" + result + "\"}");
        out.flush();
    }

    private String addOrUpdateItemInBranch(String branch, String itemCode, int quantity, String itemName) {
        // Check if itemName is null or empty
        if (itemName == null || itemName.isEmpty()) {
            return "error: item_name cannot be null or empty";
        }

        // Formulate SQL query to update or insert the item in the branch table
        String tableName = branch;  // The branch table name is based on the branch username
        String query = "INSERT INTO " + tableName + " (item_code, item_name, total_quantity, critically_low) "
                     + "VALUES (?, ?, ?, ?) "
                     + "ON DUPLICATE KEY UPDATE total_quantity = total_quantity + ?, item_name = VALUES(item_name), critically_low = 0";

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {

            // Set the values for the query
            statement.setString(1, itemCode);
            statement.setString(2, itemName);  // Insert the item name
            statement.setInt(3, quantity);
            statement.setInt(4, 0); // Set critically_low to 0 when item is inserted
            statement.setInt(5, quantity); // Increment total_quantity by the quantity

            int rowsAffected = statement.executeUpdate();

            if (rowsAffected > 0) {
                return "success";
            } else {
                return "error";
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return "error";
        }
    }

    // Helper class to map the incoming JSON data
    private static class ReceiptData {
        private String drCode;
        private String itemCode;
        private int quantity;
        private String branch;
        private String deliveryDate;
        private String itemName; 

        // Getters and Setters
        public String getDrCode() { return drCode; }
        public void setDrCode(String drCode) { this.drCode = drCode; }
        public String getItemCode() { return itemCode; }
        public void setItemCode(String itemCode) { this.itemCode = itemCode; }
        public int getQuantity() { return quantity; }
        public void setQuantity(int quantity) { this.quantity = quantity; }
        public String getBranch() { return branch; }
        public void setBranch(String branch) { this.branch = branch; }
        public String getDeliveryDate() { return deliveryDate; }
        public void setDeliveryDate(String deliveryDate) { this.deliveryDate = deliveryDate; }
        public String getItemName() { return itemName; } // Getter for item_name
        public void setItemName(String itemName) { this.itemName = itemName; } // Setter for item_name
    }
}