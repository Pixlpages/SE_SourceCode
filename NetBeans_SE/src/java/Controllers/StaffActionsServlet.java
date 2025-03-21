package Controllers;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class StaffActionsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("receive".equals(action)) {
            // Handle adding items logic
            response.sendRedirect("Breceive.jsp");
        } else if ("pull".equals(action)) {
            // Handle editing item information logic
            response.sendRedirect("Bpullout.jsp");
        } else if ("view".equals(action)) {
            // Handle editing item information logic
            response.sendRedirect("Bview.jsp");
        } else if ("manage".equals(action)) {
            // Handle editing item information logic
            response.sendRedirect("Bmanagedefective.jsp");
        } else {
            response.sendRedirect("error.jsp"); // Redirect to an error page if action is unknown
        }
    }
}
