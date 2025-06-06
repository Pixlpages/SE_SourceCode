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

@WebServlet("/Breceive")
public class Breceive extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userBranch = (String) request.getSession().getAttribute("username");
        String drCode = request.getParameter("drCode");

        List<DeliveryReceipt> receipts;

        if (drCode != null && !drCode.isEmpty()) {
            // If drCode is provided, fetch specific DR details
            receipts = fetchDeliveryReceiptDetails(drCode);
        } else {
            // Otherwise, fetch all DRs for the branch
            receipts = fetchDeliveryReceipts(userBranch);
        }

        // Return JSON response
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        String json = new Gson().toJson(new ResponseData(receipts));
        out.print(json);
        out.flush();
    }

    private List<DeliveryReceipt> fetchDeliveryReceipts(String branch) {
    List<DeliveryReceipt> receipts = new ArrayList<>();
    String query = "SELECT DISTINCT dr_code, delivery_date FROM delivery_receipt WHERE branch = ?";

    try (Connection connection = DatabaseUtil.getConnection();
         PreparedStatement statement = connection.prepareStatement(query)) {
        statement.setString(1, branch);

        try (ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                DeliveryReceipt receipt = new DeliveryReceipt();
                receipt.setDrCode(rs.getString("dr_code"));
                receipt.setDeliveryDate(rs.getTimestamp("delivery_date"));
                receipts.add(receipt); // Only drCode is needed for left side
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }

    return receipts;
}


    private List<DeliveryReceipt> fetchDeliveryReceiptDetails(String drCode) {
        List<DeliveryReceipt> items = new ArrayList<>();
        String query = "SELECT * FROM delivery_receipt WHERE dr_code = ?";

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setString(1, drCode);

            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    DeliveryReceipt item = new DeliveryReceipt();
                    item.setDrCode(rs.getString("dr_code"));
                    item.setItemCode(rs.getString("item_code"));
                    item.setItemName(rs.getString("item_name"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setBranch(rs.getString("branch"));
                    items.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return items;
    }

    private static class DeliveryReceipt {
        private String drCode;
        private String itemCode;
        private int quantity;
        private String branch;
        private java.sql.Timestamp deliveryDate;
        private String itemName;

        // Getters and Setters
        public String getDrCode() { return drCode; }
        public void setDrCode(String drCode) { this.drCode = drCode; }
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
        private List<DeliveryReceipt> data;

        public ResponseData(List<DeliveryReceipt> data) {
            this.data = data;
        }

        public List<DeliveryReceipt> getData() { return data; }
    }
}

