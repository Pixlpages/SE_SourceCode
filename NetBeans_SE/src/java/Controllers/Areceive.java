package Controllers;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.google.gson.Gson;

@WebServlet("/Areceive")
public class Areceive extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String PoCode = request.getParameter("PoCode");

        List<PullOutReceipt> receipts;

        if (PoCode != null && !PoCode.isEmpty()) {
            // If PoCode is provided, fetch specific details for the PoCode
            receipts = fetchPullOutReceiptDetails(PoCode);
        } else {
            // Otherwise, fetch all records from the pullout_receipt
            receipts = fetchPullOutReceipts();
        }

        // Return JSON response
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        String json = new Gson().toJson(new ResponseData(receipts));
        out.print(json);
        out.flush();
    }

    private List<PullOutReceipt> fetchPullOutReceipts() {
        List<PullOutReceipt> receipts = new ArrayList<>();
        String query = "SELECT DISTINCT pullout_code, delivery_date FROM pullout_receipt";

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {

            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    PullOutReceipt receipt = new PullOutReceipt();
                    receipt.setPoCode(rs.getString("pullout_code"));
                    receipt.setDeliveryDate(rs.getTimestamp("delivery_date"));
                    receipts.add(receipt); // Only PoCode and deliveryDate are needed for left side
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return receipts;
    }

    private List<PullOutReceipt> fetchPullOutReceiptDetails(String PoCode) {
        List<PullOutReceipt> items = new ArrayList<>();
        String query = "SELECT * FROM pullout_receipt WHERE pullout_code = ?";

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setString(1, PoCode);

            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    PullOutReceipt item = new PullOutReceipt();
                    item.setPoCode(rs.getString("pullout_code"));
                    item.setItemCode(rs.getString("item_code"));
                    item.setItemName(rs.getString("item_name"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setBranch(rs.getString("branch"));
                    item.setDeliveryDate(rs.getTimestamp("delivery_date"));
                    items.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return items;
    }

    private static class PullOutReceipt {
        private String PoCode;
        private String itemCode;
        private int quantity;
        private String branch;
        private java.sql.Timestamp deliveryDate;
        private String itemName;

        // Getters and Setters
        public String getPoCode() { return PoCode; }
        public void setPoCode(String PoCode) { this.PoCode = PoCode; }
        public String getItemCode() { return itemCode; }
        public void setItemCode(String itemCode) { this.itemCode = itemCode; }
        public int getQuantity() { return quantity; }
        public void setQuantity(int quantity) { this.quantity = quantity; }
        public String getBranch() { return branch; }
        public void setBranch(String branch) { this.branch = branch; }
        public java.sql.Timestamp getDeliveryDate() { return deliveryDate; }
        public void setDeliveryDate(java.sql.Timestamp deliveryDate) { this.deliveryDate = deliveryDate; }
        public String getItemName() { return itemName; } // Getter for itemName
        public void setItemName(String itemName) { this.itemName = itemName; } // Setter for itemName
    }

    private static class ResponseData {
        private List<PullOutReceipt> data;

        public ResponseData(List<PullOutReceipt> data) {
            this.data = data;
        }

        public List<PullOutReceipt> getData() { return data; }
    }
}
