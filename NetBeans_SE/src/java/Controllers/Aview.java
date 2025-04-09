package Controllers;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/Aview")
public class Aview extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "inline; filename=branch-report.pdf");

        try {
            Document document = new Document();
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();

            // Title
            Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18);
            Paragraph title = new Paragraph("Branch Report", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            document.add(title);
            document.add(Chunk.NEWLINE);

            // Use DatabaseUtil to get connection
            Connection conn = DatabaseUtil.getConnection();

            String query = "SELECT item_code, item_name, item_category, total_quantity, pet_category FROM items";
            try (Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(query)) {

                // Create PDF Table
                PdfPTable table = new PdfPTable(5); // 5 columns
                table.setWidthPercentage(100);
                table.setSpacingBefore(10f);
                table.setSpacingAfter(10f);

                // Table headers
                Font headFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD);
                String[] headers = {"Item Code", "Item Name", "Item Category", "Total Quantity", "Pet Category"};
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
                    table.addCell(rs.getString("item_category"));
                    table.addCell(String.valueOf(rs.getInt("total_quantity")));
                    table.addCell(rs.getString("pet_category"));
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
}
