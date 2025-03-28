package Controllers;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseUtil {
    private static final String URL = "jdbc:mysql://localhost:3306/simple_db?useSSL=FALSE"; // Replace with your actual database name
    private static final String USER = "root"; // Replace with your actual MySQL username
    private static final String PASSWORD = "admin"; // Replace with your actual MySQL password

    public static Connection getConnection() throws SQLException {
        try {
            // Load the MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL JDBC Driver not found.");
            e.printStackTrace();
            throw new SQLException("Could not load MySQL JDBC Driver.");
        }
        
        // Establish and return the connection
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}