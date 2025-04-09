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

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Assuming you have a way to get the logged-in user's branch
        String userBranch = (String) request.getSession().getAttribute("username");

        List<DeliveryReceipt> receipts = fetchDeliveryReceipts(userBranch);

        // Send the response
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();
        String json = gson.toJson(new ResponseData(receipts));
        out.print(json);
        out.flush();
    }

    private List<DeliveryReceipt> fetchDeliveryReceipts(String branch) {
        List<DeliveryReceipt> receipts = new ArrayList<>();
        String query = "SELECT dr_code, item_code, quantity, branch, delivery_date FROM delivery_receipt WHERE branch = ?";

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setString(1, branch); // Set the branch parameter

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    DeliveryReceipt receipt = new DeliveryReceipt();
                    receipt.setDrCode(resultSet.getString("dr_code"));
                    receipt.setItemCode(resultSet.getString("item_code"));
                    receipt.setQuantity(resultSet.getInt("quantity"));
                    receipt.setBranch(resultSet.getString("branch"));
                    receipt.setDeliveryDate(resultSet.getTimestamp("delivery_date"));

                    // Add each receipt to the list
                    receipts.add(receipt);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return receipts;
    }

    private static class DeliveryReceipt {
        private String drCode;
        private String itemCode;
        private int quantity;
        private String branch;
        private java.sql.Timestamp deliveryDate;

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
    }

    private static class ResponseData {
        private List<DeliveryReceipt> data;

        public ResponseData(List<DeliveryReceipt> data) {
            this.data = data;
        }

        public List<DeliveryReceipt> getData() { return data; }
    }
}