package Controllers;

import java.util.ArrayList;
import java.util.List;

public class DBManager {
    private String username;
    private String role;
    
    // List to hold items associated with the user
    private List<Item> itemList;

    // Constructor
    public DBManager() {
        this.itemList = new ArrayList<>(); // Initialize the item list
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

    // Inner Item class
    public static class Item {
        private String itemCode;
        private String itemName;
        private String itemCategory;
        private String petCategory;
        private int totalQuantity;

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
    }
}