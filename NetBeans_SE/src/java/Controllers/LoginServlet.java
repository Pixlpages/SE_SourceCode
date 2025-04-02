package Controllers;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class LoginServlet extends HttpServlet {
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
    // Get username and password from form submission
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    
    System.out.println("Username: " + username);
    System.out.println("Password: " + password);
    
    HttpSession session = request.getSession();  // Create session
    
    UserDao userDAO = new UserDao();
    DBManager user = userDAO.getUser (username, password); // Fetch user from DB
    
    if (user != null) {
        session.setAttribute("username", user.getUsername());
        session.setAttribute("role", user.getRole());
        session.setAttribute("LoggedIn", true);
        
        if ("admin".equals(user.getRole())) {
            response.sendRedirect("Ahome.jsp");  // Redirect Admin
        } else if ("staff".equals(user.getRole())) {
            response.sendRedirect("Bhome.jsp");  // Redirect Staff
        }
    } else {
        System.out.println("Login failed for user: " + username);
        response.sendRedirect("error_credentials.jsp");  // Redirect back with error
    }
}
    
    
}