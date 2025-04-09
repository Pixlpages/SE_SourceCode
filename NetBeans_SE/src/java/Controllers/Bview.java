package Controllers;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

public class Bview extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get the username from the session
        HttpSession session = request.getSession();
        String branch = (String) session.getAttribute("username");

        // If the username doesn't match a branch, return an error
        if (!isValidBranch(branch)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid branch for username");
            return;
        }

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=" + branch + "-report.pdf");

        try {
            Document document = new Document();
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();

            // Title
            Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18);
            Paragraph title = new Paragraph("Branch Report: " + capitalize(branch), titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            document.add(title);
            document.add(Chunk.NEWLINE);

            // Use DatabaseUtil to get connection
            Connection conn = DatabaseUtil.getConnection();

            // Query specific to the branch (e.g., malabon, tagaytay, etc.)
            String query = "SELECT item_code, item_name, critically_low, total_quantity FROM " + branch;
            try (Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(query)) {

                // Create PDF Table
                PdfPTable table = new PdfPTable(4); // 4 columns
                table.setWidthPercentage(100);
                table.setSpacingBefore(10f);
                table.setSpacingAfter(10f);

                // Table headers
                Font headFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD);
                String[] headers = {"Item Code", "Item Name", "Critically Low", "Total Quantity"};
                for (String header : headers) {
                    PdfPCell cell = new PdfPCell(new Phrase(header, headFont));
                    cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
                    cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                    table.addCell(cell);
                }

                // Table rows
                while (rs.next()) {
                    table.addCell(rs.getString("item_code"));
                    table.addCell(rs.getString("item_name"));
                    table.addCell(String.valueOf(rs.getBoolean("critically_low")));
                    table.addCell(String.valueOf(rs.getInt("total_quantity")));
                }

                document.add(table);
            } finally {
                if (conn != null) conn.close();
            }

            document.close();

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error generating PDF", e);
        }
    }

    private boolean isValidBranch(String branch) {
        // List of valid branch names to check against
        String[] validBranches = {
            "malabon", "tagaytay", "cebu", "olongapo", "marquee", "subic", "urdaneta", "bacolod", "tacloban"
        };
        for (String b : validBranches) {
            if (b.equals(branch)) {
                return true;
            }
        }
        return false;
    }

    private String capitalize(String input) {
        if (input == null || input.isEmpty()) return input;
        return input.substring(0, 1).toUpperCase() + input.substring(1).toLowerCase();
    }
}
