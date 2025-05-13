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

                int currentQty;
                int criticalLevel;

               // Step 1: Get current total quantity from malabon and critical condition from items
String selectSql = "SELECT m.total_quantity, i.critical_condition " +
                   "FROM malabon m JOIN items i ON m.item_code = i.item_code " +
                   "WHERE m.item_code = ?";
try (PreparedStatement selectStmt = connection.prepareStatement(selectSql)) {
    selectStmt.setString(1, itemCode);
    ResultSet rs = selectStmt.executeQuery();

    if (!rs.next()) {
        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        return;
    }

    currentQty = rs.getInt("total_quantity");
    criticalLevel = rs.getInt("critical_condition");

    if (quantity > currentQty) {
        response.setStatus(HttpServletResponse.SC_CONFLICT); // Not enough stock
        return;
    }
}


                // Step 2: Insert into defective
                String insertSql = "INSERT INTO defective (defect_code, item_code, cause, quantity) VALUES (?, ?, ?, ?)";
                String defectCode = generateNextDefectCode(connection);
                try (PreparedStatement insertStmt = connection.prepareStatement(insertSql)) {
                    insertStmt.setString(1, defectCode);
                    insertStmt.setString(2, itemCode);
                    insertStmt.setString(3, cause);
                    insertStmt.setInt(4, quantity);
                    insertStmt.executeUpdate();
                }

                // Step 3: Update malabon table (subtract quantity)
                String updateSql = "UPDATE malabon SET total_quantity = total_quantity - ? WHERE item_code = ?";
                try (PreparedStatement updateStmt = connection.prepareStatement(updateSql)) {
                    updateStmt.setInt(1, quantity);
                    updateStmt.setString(2, itemCode);
                    updateStmt.executeUpdate();
                }

                // Step 4: Check updated quantity and update critical flag if needed
                String checkQtySql = "SELECT total_quantity FROM malabon WHERE item_code = ?";
                try (PreparedStatement checkStmt = connection.prepareStatement(checkQtySql)) {
                    checkStmt.setString(1, itemCode);
                    ResultSet rs = checkStmt.executeQuery();
                    if (rs.next()) {
                        int newQty = rs.getInt("total_quantity");
                        int criticallyLow = newQty <= criticalLevel ? 1 : 0;

                        String updateCriticalSql = "UPDATE malabon SET critically_low = ? WHERE item_code = ?";
                        try (PreparedStatement updateCriticalStmt = connection.prepareStatement(updateCriticalSql)) {
                            updateCriticalStmt.setInt(1, criticallyLow);
                            updateCriticalStmt.setString(2, itemCode);
                            updateCriticalStmt.executeUpdate();
                        }
                    }
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

    private String generateNextDefectCode(Connection connection) throws SQLException {
        String nextCode = "DEF-0001";
        String query = "SELECT MAX(defect_code) FROM defective";

        try (PreparedStatement stmt = connection.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                String maxCode = rs.getString(1);
                if (maxCode != null) {
                    int number = Integer.parseInt(maxCode.substring(4)) + 1;
                    nextCode = String.format("DEF-%04d", number);
                }
            }
        }

        return nextCode;
    }
}
