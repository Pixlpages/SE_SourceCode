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

            // Get log type parameter from request
            String logType = request.getParameter("logType");
            StringBuilder queryBuilder = new StringBuilder();

            // Set dynamic title based on logType
            String reportTitle;
            if (logType == null || logType.equals("all")) {
                reportTitle = "Delivery, Pullout, and Sales Logs";
                queryBuilder.append("SELECT 'Distribute' AS receipt_type, item_code, item_name, branch, delivery_date, quantity FROM delivery_receipt ")
                            .append("UNION ALL ")
                            .append("SELECT 'Pullout' AS receipt_type, item_code, item_name, branch, delivery_date, quantity FROM pullout_receipt ")
                            .append("UNION ALL ")
                            .append("SELECT 'Sales' AS receipt_type, item_code, item_name, branch, delivery_date, quantity FROM sales ");
            } else if (logType.equals("distribute")) {
                reportTitle = "Distribute Logs";
                queryBuilder.append("SELECT 'Distribute' AS receipt_type, item_code, item_name, branch, delivery_date, quantity FROM delivery_receipt ");
            } else if (logType.equals("pullout")) {
                reportTitle = "Pullout Logs";
                queryBuilder.append("SELECT 'Pullout' AS receipt_type, item_code, item_name, branch, delivery_date, quantity FROM pullout_receipt ");
            } else if (logType.equals("sales")) {
                reportTitle = "Sales Logs";
                queryBuilder.append("SELECT 'Sales' AS receipt_type, item_code, item_name, branch, delivery_date, quantity FROM sales ");
            } else {
                reportTitle = "Unknown Logs";
            }

            queryBuilder.append("ORDER BY delivery_date ASC");
            String query = queryBuilder.toString();

            // Add title to the document
            Font titleFont = new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD);
            Paragraph title = new Paragraph(reportTitle, titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            document.add(title);
            document.add(Chunk.NEWLINE);

            // Create the table
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

            // Fill the table with data
            try (Statement stmt = connection.createStatement(); ResultSet rs = stmt.executeQuery(query)) {
                while (rs.next()) {
                    table.addCell(rs.getString("receipt_type"));
                    table.addCell(rs.getString("item_code"));
                    table.addCell(rs.getString("item_name"));
                    table.addCell(rs.getString("branch"));
                    // Format date
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
