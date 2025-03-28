package Controllers;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDao {
    public User getUser (String username, String password) {
    User user = null;
    String query = "SELECT * FROM users WHERE username = ?";

    try (Connection connection = DatabaseUtil.getConnection();
         PreparedStatement statement = connection.prepareStatement(query)) {
         
        statement.setString(1, username);
        ResultSet resultSet = statement.executeQuery();
        
        
        if (resultSet.next()) {
            String storedPassword = resultSet.getString("password");
            System.out.println("Stored Password: " + storedPassword);
            
            // Check if the provided password matches the stored password
            if (password.equals(storedPassword)) { // Replace with BCrypt.checkpw if using hashing
                user = new User();
                user.setUsername(resultSet.getString("username"));
                user.setRole(resultSet.getString("role"));
            }
        } else {
            System.out.println("No user found with username: " + username);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return user;
}
}