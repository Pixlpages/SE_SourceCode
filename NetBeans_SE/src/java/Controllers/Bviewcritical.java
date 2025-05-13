package Controllers;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import java.text.SimpleDateFormat;
import java.util.Locale;

public class Bviewcritical extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String[] BRANCH_TABLES = {
        "malabon", "tagaytay", "cebu", "olongapo", "marquee", "subic", "urdaneta", "bacolod", "tacloban"
    };

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get the branch from session attribute "username"
        HttpSession session = request.getSession();
        String branch = (String) session.getAttribute("username");

        response.setContentType("application/pdf");

        try (Connection connection = DatabaseUtil.getConnection()) {
            Document document = new Document();
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();
            java.util.Date now = new java.util.Date();
            // Define the desired format
            SimpleDateFormat formatter = new SimpleDateFormat("EEEE, MMMM d, yyyy 'at' h:mm a", Locale.ENGLISH);
            // Format the current date and time
            String formattedDate = formatter.format(now);
            Font dateFont = new Font(Font.FontFamily.HELVETICA, 8, Font.NORMAL);
            Paragraph dateGen = new Paragraph("Date generated: " + formattedDate, dateFont);
            document.add(dateGen);
            Font titleFont = new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD);
            Paragraph title;

            PdfPTable table;

            if (branch != null && isValidBranch(branch)) {
                // Generate report for the selected branch with critically low items
                title = new Paragraph("Critical Items Report for: " + capitalize(branch), titleFont);
                title.setAlignment(Element.ALIGN_CENTER);
                document.add(title);
                document.add(Chunk.NEWLINE);

                table = new PdfPTable(4); // Branch table has 4 columns
                table.setWidthPercentage(100);
                Font headerFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD);
                BaseColor headerColor = new BaseColor(220, 220, 220); // light gray

                String[] headers = {"Item Code", "Item Name", "Critically Low", "Total Quantity"};
                for (String col : headers) {
                    PdfPCell cell = new PdfPCell(new Phrase(col, headerFont));
                    cell.setBackgroundColor(headerColor);
                    table.addCell(cell);
                }

                String query = "SELECT * FROM " + branch + " WHERE critically_low = true";
                try (Statement stmt = connection.createStatement();
                        ResultSet rs = stmt.executeQuery(query)) {

                    while (rs.next()) {
                        table.addCell(rs.getString("item_code"));
                        table.addCell(rs.getString("item_name"));
                        table.addCell(String.valueOf(rs.getBoolean("critically_low")));
                        table.addCell(String.valueOf(rs.getInt("total_quantity")));
                    }
                }

                document.add(table);
                document.close();
            } else {
                // Handle case when branch is invalid or missing
                document.add(new Paragraph("Invalid or missing branch parameter.", titleFont));
            }
        } catch (Exception e) {
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
