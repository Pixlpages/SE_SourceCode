package Controllers;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;

import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.mail.PasswordAuthentication;

@WebServlet("/ForgotPassword")
public class ForgotPassword extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");

        // Retrieve user's password from database
        String userPassword = getUserPassword(username);

        if (userPassword != null) {
            // Since your table doesn't have email, using a fixed email for testing
            String userEmail = "jobell.rome@gmail.com"; // Replace with your email for testing or implement logic to get user email

            boolean emailSent = sendEmail(userEmail, userPassword);
            if (emailSent) {
                response.getWriter().write("An email has been sent with your password.");
            } else {
                response.getWriter().write("Failed to send email. Please try again later.");
            }
        } else {
            response.getWriter().write("Username not found.");
        }
    }

    private String getUserPassword(String username) {
        String password = null;
        String query = "SELECT password FROM users WHERE username = ?";

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(query)) {

            preparedStatement.setString(1, username);
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    password = resultSet.getString("password");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return password;
    }

    private boolean sendEmail(String to, String password) {
        String from = "jobell.rome@gmail.com"; // your email address, the sender
        String host = "smtp.gmail.com";       // your SMTP host

        Properties properties = System.getProperties();
        properties.setProperty("mail.smtp.host", host);
        properties.setProperty("mail.smtp.port", "587");
        properties.setProperty("mail.smtp.auth", "true");
        properties.setProperty("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(properties, new javax.mail.Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication("jobell.rome@gmail.com", "mfez vesa bnpe wwlr"); //app password sa google
            }
        });

        try {
            MimeMessage message = new MimeMessage(session);

            message.setFrom(new InternetAddress(from));
            message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
            message.setSubject("Your Password");
            message.setText("Your password is: " + password);

            Transport.send(message);
            System.out.println("Email sent successfully.");
            return true;

        } catch (MessagingException mex) {
            mex.printStackTrace();
            return false;
        }
    }
}

