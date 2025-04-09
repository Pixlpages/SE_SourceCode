package Controllers;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

public class Aviewdefective extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/pdf");

        try (Connection connection = DatabaseUtil.getConnection()) {
            Document document = new Document();
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();

            Font titleFont = new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD);
            Paragraph title = new Paragraph("Defective Items Report", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            document.add(title);
            document.add(Chunk.NEWLINE);

            PdfPTable table = new PdfPTable(4); // Defective has 4 columns
            table.setWidthPercentage(100);
            Font headerFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD);
            BaseColor headerColor = new BaseColor(220, 220, 220); // light gray

            String[] headers = {"Defect Code", "Item Code", "Cause", "Quantity"};
            for (String col : headers) {
                PdfPCell cell = new PdfPCell(new Phrase(col, headerFont));
                cell.setBackgroundColor(headerColor);
                table.addCell(cell);
            }

            String query = "SELECT * FROM defective";  // Query for defective table
            try (Statement stmt = connection.createStatement();
                 ResultSet rs = stmt.executeQuery(query)) {

                while (rs.next()) {
                    table.addCell(String.valueOf(rs.getInt("defect_code")));
                    table.addCell(rs.getString("item_code"));
                    table.addCell(rs.getString("cause"));
                    table.addCell(String.valueOf(rs.getInt("quantity")));
                }
            }

            document.add(table);
            document.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
