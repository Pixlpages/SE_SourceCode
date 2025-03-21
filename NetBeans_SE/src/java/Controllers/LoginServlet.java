package Controllers;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/Login")  // URL pattern to call this servlet
public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Get username and password from form submission
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        HttpSession session = request.getSession();  // Create session
        
        // Hardcoded credentials (Replace with database check in production)
        if ("admin".equals(username) && "123".equals(password)) {
            session.setAttribute("username", username);
            session.setAttribute("role", "admin");  // Store role in session
            session.setAttribute("LoggedIn", true);
            response.sendRedirect("Ahome.jsp");  // Redirect Admin
        } else if ("staff".equals(username) && "123".equals(password)) {
            session.setAttribute("username", username);
            session.setAttribute("role", "staff");
            session.setAttribute("LoggedIn", true);
            response.sendRedirect("Bhome.jsp");  // Redirect Staff
        } else {
            response.sendRedirect("error_credentials.jsp");  // Redirect back with error
        }
    }
}
