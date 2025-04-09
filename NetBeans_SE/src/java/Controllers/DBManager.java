package Controllers;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DBManager {
    private String username;
    private String role;

    // List to hold items associated with the user
    private List<Item> itemList;
    // List to hold delivery receipts
    private List<DeliveryReceipt> deliveryReceipts;

    // Constructor
    public DBManager() {
        this.itemList = new ArrayList<>(); // Initialize the item list
        this.deliveryReceipts = new ArrayList<>(); // Initialize the delivery receipts list
    }

    // Getters and Setters for User properties
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    // Methods for managing items
    public void addItem(Item item) {
        this.itemList.add(item);
    }

    public List<Item> getItemList() {
        return itemList;
    }

    public void setItemList(List<Item> itemList) {
        this.itemList = itemList;
    }

    // Methods for managing delivery receipts
    public void addDeliveryReceipt(DeliveryReceipt receipt) throws SQLException {
        // SQL statement to insert a delivery receipt into the database
        String sql = "INSERT INTO delivery_receipt (dr_code, item_code, quantity, branch, delivery_date) VALUES (?, ?, ?, ?, ?)";

        try (Connection connection = DatabaseUtil.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setString(1, receipt.getDrCode());
            preparedStatement.setString(2, receipt.getItemCode());
            preparedStatement.setInt(3, receipt.getQuantity());
            preparedStatement.setString(4, receipt.getBranch());
            preparedStatement.setTimestamp(5, receipt.getDeliveryDate());
            preparedStatement.executeUpdate(); // Execute the insert
        }
    }

    public List<DeliveryReceipt> getDeliveryReceipts() {
        return deliveryReceipts;
    }

    // Inner Item class
    public static class Item {
        private String itemCode;
        private String itemName;
        private String itemCategory;
        private String petCategory;
        private int totalQuantity;
        private int criticallyLow;

        // No-argument constructor
        public Item() {
        }

        // Constructor with parameters
        public Item(String itemCode, String itemName, String itemCategory, String petCategory, int totalQuantity) {
            this.itemCode = itemCode;
            this.itemName = itemName;
            this.itemCategory = itemCategory;
            this.petCategory = petCategory;
            this.totalQuantity = totalQuantity;
        }

        // Getters and Setters
        public String getItemCode() { return itemCode; }
        public void setItemCode(String itemCode) { this.itemCode = itemCode; }
        public String getItemName() { return itemName; }
        public void setItemName(String itemName) { this.itemName = itemName; }
        public String getItemCategory() { return itemCategory; }
        public void setItemCategory(String itemCategory) { this.itemCategory = itemCategory; }
        public String getPetCategory() { return petCategory; }
        public void setPetCategory(String petCategory) { this.petCategory = petCategory; }
        public int getTotalQuantity() { return totalQuantity; }
        public void setTotalQuantity(int totalQuantity) { this.totalQuantity = totalQuantity; }
        public int getCriticallyLow() { return criticallyLow; }
        public void setCriticallyLow(int criticallyLow) { this.criticallyLow = criticallyLow; }
    }

    // Inner DeliveryReceipt class
    public static class DeliveryReceipt {
        private String drCode;
        private String itemCode;
        private int quantity;
        private String branch;
        private java.sql.Timestamp deliveryDate;

        // No-argument constructor
        public DeliveryReceipt() {
        }

        // Constructor with parameters
        public DeliveryReceipt(String drCode, String itemCode, int quantity, String branch, java.sql.Timestamp deliveryDate) {
            this.drCode = drCode;
            this.itemCode = itemCode;
            this.quantity = quantity;
            this.branch = branch;
            this.deliveryDate = deliveryDate;
        }

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
}