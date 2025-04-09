package Controllers;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

@WebServlet("/Aview")
public class Aview extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=branch-report.pdf");

        // Get branch parameter or default to "items"
        String branch = request.getParameter("branch");
        if (branch == null || branch.trim().isEmpty()) {
            branch = "items";
        }

        // Validate table name against a whitelist
        Set<String> validTables = new HashSet<>(Arrays.asList(
    "items", "malabon", "tagaytay", "cebu", "olongapo",
    "marquee", "subic", "urdaneta", "bacolod", "tacloban"
));

        if (!validTables.contains(branch)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid branch/table name.");
            return;
        }

        try {
            Document document = new Document();
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();

            Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18);
            Paragraph title = new Paragraph(branch.substring(0, 1).toUpperCase() + branch.substring(1) + " Report", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            document.add(title);
            document.add(Chunk.NEWLINE);

            try (Connection conn = DatabaseUtil.getConnection();
                 Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT item_code, item_name, total_quantity FROM " + branch)) {

                PdfPTable table = new PdfPTable(3); // 3 columns for branches
                table.setWidthPercentage(100);
                table.setSpacingBefore(10f);
                table.setSpacingAfter(10f);

                Font headFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD);
                String[] headers = {"Item Code", "Item Name", "Total Quantity"};
                for (String header : headers) {
                    PdfPCell cell = new PdfPCell(new Phrase(header, headFont));
                    cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
                    cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                    table.addCell(cell);
                }

                while (rs.next()) {
                    table.addCell(rs.getString("item_code"));
                    table.addCell(rs.getString("item_name"));
                    table.addCell(String.valueOf(rs.getInt("total_quantity")));
                }

                document.add(table);

            }

            document.close();

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error generating PDF", e);
        }
    }
}

