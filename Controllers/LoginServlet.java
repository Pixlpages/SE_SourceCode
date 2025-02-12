package Controllers;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/LoginServlet")  // URL pattern to call this servlet
public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Get username and password from form submission
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        

        // Hardcoded credentials (Replace with database check in production)
        if ("admin".equals(username) && "adminpass".equals(password)) {
            response.sendRedirect("Admin.html");  // Redirect Admin
        } else if ("staff".equals(username) && "staffpass".equals(password)) {
            response.sendRedirect("Staff.html");  // Redirect Staff
        } else {
            response.sendRedirect("login.html?error=1");  // Redirect back with error
        }
    }
}
