package Controllers;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

public class Aviewlogs extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/pdf");

        try (Connection connection = DatabaseUtil.getConnection()) {
            Document document = new Document();
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();

            Font titleFont = new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD);
            Paragraph title = new Paragraph("Delivery and Pullout Receipt Logs", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            document.add(title);
            document.add(Chunk.NEWLINE);

            PdfPTable table = new PdfPTable(6); // 6 columns: Receipt Type, Item Code, Item Name, Branch, Date, Quantity
            table.setWidthPercentage(100);
            Font headerFont = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD);
            BaseColor headerColor = new BaseColor(220, 220, 220); // light gray

            String[] headers = {"Receipt Type", "Item Code", "Item Name", "Branch", "Date", "Quantity"};
            for (String col : headers) {
                PdfPCell cell = new PdfPCell(new Phrase(col, headerFont));
                cell.setBackgroundColor(headerColor);
                table.addCell(cell);
            }

            // Fetch data from both tables (delivery_receipts and pullout_receipts), ordered by delivery_date
            String query = "SELECT 'Distribute' AS receipt_type, item_code, item_name, branch, delivery_date, quantity FROM delivery_receipt " +
                           "UNION ALL " +
                           "SELECT 'Pullout' AS receipt_type, item_code, item_name, branch, delivery_date, quantity FROM pullout_receipt " +
                           "ORDER BY delivery_date ASC";  // Ordering by delivery_date

            try (Statement stmt = connection.createStatement(); ResultSet rs = stmt.executeQuery(query)) {
                while (rs.next()) {
                    table.addCell(rs.getString("receipt_type"));
                    table.addCell(rs.getString("item_code"));
                    table.addCell(rs.getString("item_name"));
                    table.addCell(rs.getString("branch"));
                    // Formatting date to display in a readable format
                    Timestamp deliveryDate = rs.getTimestamp("delivery_date");
                    String formattedDate = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(deliveryDate);
                    table.addCell(formattedDate);
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
