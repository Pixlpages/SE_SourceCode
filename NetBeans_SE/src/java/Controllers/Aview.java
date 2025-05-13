package Controllers;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class Aview extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String[] BRANCH_TABLES = {
        "malabon", "tagaytay", "cebu", "olongapo", "marquee", "subic", "urdaneta", "bacolod", "tacloban"
    };

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Optional query param: ?branch=cebu
        String branch = request.getParameter("branch");

        response.setContentType("application/pdf");

        try (Connection connection = DatabaseUtil.getConnection()) {
            Document document = new Document();
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();

            Font titleFont = new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD);
            Paragraph title;

            PdfPTable table;

            if (branch != null && isValidBranch(branch)) {
                java.util.Date now = new java.util.Date();
                // Define the desired format
                SimpleDateFormat formatter = new SimpleDateFormat("EEEE, MMMM d, yyyy 'at' h:mm a", Locale.ENGLISH);
                // Format the current date and time
                String formattedDate = formatter.format(now);
                Font dateFont = new Font(Font.FontFamily.HELVETICA, 8, Font.NORMAL);
                Paragraph dateGen = new Paragraph("Date generated: " + formattedDate, dateFont);
                // Generate report for specific branch table
                title = new Paragraph("Branch Report: " + capitalize(branch), titleFont);
                title.setAlignment(Element.ALIGN_CENTER);
                document.add(dateGen);
                document.add(title);
                document.add(Chunk.NEWLINE);

                table = new PdfPTable(4); // Branch has 4 columns
                table.setWidthPercentage(100);
                Font headerFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD);
                BaseColor headerColor = new BaseColor(220, 220, 220); // light gray

                String[] headers = {"Item Code", "Item Name", "Critically Low", "Total Quantity"};
                for (String col : headers) {
                    PdfPCell cell = new PdfPCell(new Phrase(col, headerFont));
                    cell.setBackgroundColor(headerColor);
                    table.addCell(cell);
                }

                String query = "SELECT * FROM " + branch;
                try (Statement stmt = connection.createStatement();
                        ResultSet rs = stmt.executeQuery(query)) {

                    while (rs.next()) {
                        table.addCell(rs.getString("item_code"));
                        table.addCell(rs.getString("item_name"));
                        table.addCell(String.valueOf(rs.getBoolean("critically_low")));
                        table.addCell(String.valueOf(rs.getInt("total_quantity")));
                    }
                }

            } else {
                // Default: recalculate total and show master items table
                recalculateTotalQuantities();
                // Generate report for the selected branch with critically low items
                java.util.Date now = new java.util.Date();
                // Define the desired format
                SimpleDateFormat formatter = new SimpleDateFormat("EEEE, MMMM d, yyyy 'at' h:mm a", Locale.ENGLISH);
                // Format the current date and time
                String formattedDate = formatter.format(now);
                Font dateFont = new Font(Font.FontFamily.HELVETICA, 8, Font.NORMAL);
                Paragraph dateGen = new Paragraph("Date generated: " + formattedDate, dateFont);
                document.add(dateGen);
                title = new Paragraph("Master Item Report", titleFont);
                title.setAlignment(Element.ALIGN_CENTER);
                document.add(title);
                document.add(Chunk.NEWLINE);

                table = new PdfPTable(5); // Items table
                table.setWidthPercentage(100);
                Font headerFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD);
                BaseColor headerColor = new BaseColor(220, 220, 220);

                String[] headers = {"Item Code", "Item Name", "Item Category", "Pet Category", "Total Quantity"};
                for (String col : headers) {
                    PdfPCell cell = new PdfPCell(new Phrase(col, headerFont));
                    cell.setBackgroundColor(headerColor);
                    table.addCell(cell);
                }

                String query = "SELECT * FROM items";
                try (Statement stmt = connection.createStatement();
                        ResultSet rs = stmt.executeQuery(query)) {

                    while (rs.next()) {
                        table.addCell(rs.getString("item_code"));
                        table.addCell(rs.getString("item_name"));
                        table.addCell(rs.getString("item_category"));
                        table.addCell(rs.getString("pet_category"));
                        table.addCell(String.valueOf(rs.getInt("total_quantity")));
                    }
                }
            }

            document.add(table);
            document.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void recalculateTotalQuantities() {
        try (Connection conn = DatabaseUtil.getConnection()) {
            String selectItemsSql = "SELECT item_code FROM items";
            PreparedStatement selectStmt = conn.prepareStatement(selectItemsSql);
            ResultSet rs = selectStmt.executeQuery();

            while (rs.next()) {
                String itemCode = rs.getString("item_code");
                int totalQuantity = 0;

                for (String branch : BRANCH_TABLES) {
                    String branchSql = "SELECT total_quantity FROM " + branch + " WHERE item_code = ?";
                    try (PreparedStatement branchStmt = conn.prepareStatement(branchSql)) {
                        branchStmt.setString(1, itemCode);
                        ResultSet branchRs = branchStmt.executeQuery();
                        if (branchRs.next()) {
                            totalQuantity += branchRs.getInt("total_quantity");
                        }
                    }
                }

                String updateSql = "UPDATE items SET total_quantity = ? WHERE item_code = ?";
                try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                    updateStmt.setInt(1, totalQuantity);
                    updateStmt.setString(2, itemCode);
                    updateStmt.executeUpdate();
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private boolean isValidBranch(String branch) {
        for (String b : BRANCH_TABLES) {
            if (b.equalsIgnoreCase(branch)) {
                return true;
            }
        }
        return false;
    }

    private String capitalize(String input) {
        if (input == null || input.isEmpty()) {
            return input;
        }
        return input.substring(0, 1).toUpperCase() + input.substring(1).toLowerCase();
    }
}
