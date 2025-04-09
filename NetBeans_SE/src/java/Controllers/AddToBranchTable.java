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
        // Read the JSON data from the request
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = request.getReader().readLine()) != null) {
            sb.append(line);
        }

        // Parse the JSON data
        Gson gson = new Gson();
        DBManager.Item item = gson.fromJson(sb.toString(), DBManager.Item.class); // Assuming you are sending item data

        // Get the logged-in user's branch from the session
        String userBranch = (String) request.getSession().getAttribute("username");
        System.out.println("User 's branch: " + userBranch); // Log user's branch

        // Check if the branch in the item matches the logged-in user's branch
        if (!userBranch.equals(item.getItemCode())) { // Adjust this check as needed
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You do not have permission to add items to this branch.");
            return;
        }

        // Use the method to add the item to the branch table
        try {
            addToBranchTable(userBranch, item.getItemCode(), item.getItemName(), item.getTotalQuantity(), item.getCriticallyLow());
        } catch (SQLException e) {
            e.printStackTrace(); // Log the exception
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error occurred: " + e.getMessage());
            return;
        }

        // Send a success response
        response.setStatus(HttpServletResponse.SC_OK);
        PrintWriter out = response.getWriter();
        out.print("{\"message\": \"Items added successfully to the branch.\"}");
        out.flush();
    }

    private void addToBranchTable(String branchName, String itemCode, String itemName, int totalQuantity, int criticallyLow) throws SQLException {
        // Construct the SQL statement dynamically based on the branch name
        String sql = "INSERT INTO " + branchName + " (item_code, item_name, total_quantity, critically_low) VALUES (?, ?, ?, ?)";
        
        // Log the SQL statement for debugging
        System.out.println("Executing SQL: " + sql);
        
        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setString(1, itemCode);
            preparedStatement.setString(2, itemName);
            preparedStatement.setInt(3, totalQuantity);
            preparedStatement.setInt(4, criticallyLow);
            
            int rowsAffected = preparedStatement.executeUpdate(); // This line actually updates the database
            
            // Log the number of rows affected
            System.out.println("Rows affected: " + rowsAffected);
            
            if (rowsAffected == 0) {
                System.out.println("No rows were inserted. Check if the item already exists or if there are constraints.");
            }
        } catch (SQLException e) {
            // Log the exception message
            System.err.println("SQL Exception: " + e.getMessage());
            throw e; // Rethrow the exception for further handling
        }
    }
}