package Controllers;

import java.io.IOException;
import java.sql.*;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class Amanagedefective extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String itemCode = request.getParameter("itemCode");
        String cause = request.getParameter("cause");
        String quantityStr = request.getParameter("quantity");

        if (itemCode == null || cause == null || quantityStr == null ||
            itemCode.isEmpty() || cause.isEmpty() || quantityStr.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            int quantity = Integer.parseInt(quantityStr);

            try (Connection connection = DatabaseUtil.getConnection()) {
                connection.setAutoCommit(false); // Start transaction

                // Step 1: Get current total quantity from malabon
                String selectSql = "SELECT total_quantity FROM malabon WHERE item_code = ?";
                try (PreparedStatement selectStmt = connection.prepareStatement(selectSql)) {
                    selectStmt.setString(1, itemCode);
                    ResultSet rs = selectStmt.executeQuery();

                    if (!rs.next()) {
                        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        return;
                    }

                    int currentQty = rs.getInt("total_quantity");
                    if (quantity > currentQty) {
                        response.setStatus(HttpServletResponse.SC_CONFLICT); // Not enough stock
                        return;
                    }
                }

                // Step 2: Insert into defective
                String insertSql = "INSERT INTO defective (item_code, cause, quantity) VALUES (?, ?, ?)";
                try (PreparedStatement insertStmt = connection.prepareStatement(insertSql)) {
                    insertStmt.setString(1, itemCode);
                    insertStmt.setString(2, cause);
                    insertStmt.setInt(3, quantity);
                    insertStmt.executeUpdate();
                }

                // Step 3: Update malabon table (subtract quantity)
                String updateSql = "UPDATE malabon SET total_quantity = total_quantity - ? WHERE item_code = ?";
                try (PreparedStatement updateStmt = connection.prepareStatement(updateSql)) {
                    updateStmt.setInt(1, quantity);
                    updateStmt.setString(2, itemCode);
                    updateStmt.executeUpdate();
                }

                connection.commit(); // Commit transaction
                response.setStatus(HttpServletResponse.SC_OK);

            } catch (SQLException e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
}
