package Controllers;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class AdminActionsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("increasequantity".equals(action)) {
            // Handle adding items logic
            response.sendRedirect("Aincreasequantity.jsp");
        } else if ("newproduct".equals(action)) {
            // Handle including in inventory logic
            response.sendRedirect("Anewproduct.jsp");
        } else if ("edit".equals(action)) {
            // Handle editing item information logic
            response.sendRedirect("Aeditproduct.jsp"); 
        } else if ("receive".equals(action)) {
            // Handle editing item information logic
            response.sendRedirect("Areceive.jsp"); 
        } else if ("distribute".equals(action)) {
            // Handle editing item information logic
            response.sendRedirect("Adistribute.jsp");
        } else if ("view".equals(action)) {
            // Handle editing item information logic
            response.sendRedirect("Aview.jsp"); 
        } else if ("manage".equals(action)) {
            // Handle editing item information logic
            response.sendRedirect("Amanagedefective.jsp"); 
        } else {
            response.sendRedirect("error.jsp"); // Redirect to an error page if action is unknown
        }
    }
}
