package Controllers;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException; // Import SQLException
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
        DBManager.DeliveryReceipt receipt = gson.fromJson(sb.toString(), DBManager.DeliveryReceipt.class);

        // Get the logged-in user's branch from the session
        String userBranch = (String) request.getSession().getAttribute("username");
        System.out.println("User 's branch: " + userBranch); // Log user's branch
        System.out.println("Receipt's branch: " + receipt.getBranch()); // Log receipt's branch

        // Check if the branch in the receipt matches the logged-in user's branch
        if (!receipt.getBranch().equals(userBranch)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You do not have permission to add items to this branch.");
            return;
        }

        // Use DBManager to add the delivery receipt
        DBManager dbManager = new DBManager();
        try {
            dbManager.addDeliveryReceipt(receipt); // Add the receipt to the DBManager
        } catch (SQLException e) {
            e.printStackTrace(); // Log the exception
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error occurred.");
            return;
        }

        // Send a success response
        response.setStatus(HttpServletResponse.SC_OK);
        PrintWriter out = response.getWriter();
        out.print("{\"message\": \"Items added successfully.\"}");
        out.flush();
    }
}