package Controllers;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import java.text.SimpleDateFormat;
import java.util.Locale;

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
// Create a Date object to get the current date and time
            java.util.Date now = new java.util.Date();
            // Define the desired format
            SimpleDateFormat formatter = new SimpleDateFormat("EEEE, MMMM d, yyyy 'at' h:mm a", Locale.ENGLISH);
            // Format the current date and time
            String formattedDate = formatter.format(now);
            Font dateFont = new Font(Font.FontFamily.HELVETICA, 8, Font.NORMAL);
            Paragraph dateGen = new Paragraph("Date generated: " + formattedDate, dateFont);
            document.add(dateGen);
            document.add(title);
            document.add(Chunk.NEWLINE);

            // Adjusted to 5 columns now
            PdfPTable table = new PdfPTable(5);
            table.setWidthPercentage(100);
            Font headerFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD);
            BaseColor headerColor = new BaseColor(220, 220, 220); // light gray

            String[] headers = {"Defect Code", "Item Code", "Item Name", "Cause", "Quantity"};
            for (String col : headers) {
                PdfPCell cell = new PdfPCell(new Phrase(col, headerFont));
                cell.setBackgroundColor(headerColor);
                table.addCell(cell);
            }

            // JOIN with items to get item_name
            String query = "SELECT d.defect_code, d.item_code, i.item_name, d.cause, d.quantity " +
                           "FROM defective d " +
                           "JOIN items i ON d.item_code = i.item_code";

            try (Statement stmt = connection.createStatement();
                 ResultSet rs = stmt.executeQuery(query)) {

                while (rs.next()) {
                    table.addCell(rs.getString("defect_code"));
                    table.addCell(rs.getString("item_code"));
                    table.addCell(rs.getString("item_name"));
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
