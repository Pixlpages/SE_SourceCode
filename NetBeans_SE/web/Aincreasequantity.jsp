<!DOCTYPE html>
<%@ page session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setHeader("Expires", "0"); // Proxies

    // Session validation
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    Boolean loggedIn = (Boolean) session.getAttribute("LoggedIn");

    if (loggedIn == null || !loggedIn || !"admin".equals(role)) {
        response.sendRedirect("error_session.jsp"); // Redirect unauthorized users
    }
%>

<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MV88 Ventures Inventory System</title>
    <style>
        /* Add your CSS styles here */
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f5f5f5;
        }
        .header {
            background-color: #5cb5c9;
            color: white;
            padding: 20px;
            text-align: center;
        }
        .sub-header {
            padding: 10px;
            display: flex;
            align-items: center;
        }
        .sub-header a {
            text-decoration: none;
            color: black;
            margin-right: 10px;
        }
        .container {
            display: flex;
            justify-content: space-between;
            padding: 20px;
        }
        .left-side, .right-side {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 45%;
        }
        .search-bar {
            display: flex;
            align-items: center;
            background-color: #e0e0e0;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .search-bar input {
            border: none;
            background: none;
            flex-grow: 1;
            padding: 5px;
            font-size: 16px;
        }
        .da_button {
            background-color: #5cb5c9;
            color: white;
            border: none;
            padding: 10px;
            border-radius: 5px;
            cursor: pointer;
        }
        .items-list {
            background-color: #f0f0f0;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .items-list h3 {
            margin-top: 0;
        }
        .item {
            display: flex;
            justify-content: space-between;
            padding: 10px;
            border-bottom: 1px solid #ccc;
        }
        .item:last-child {
            border-bottom: none;
        }
        .selected-item {
            margin-top: 20px;
            padding: 10px;
            background-color: #e0f7fa;
            border-radius: 5px;
        }
    </style>
    <script>
        let selectedItemId = null; 
        let selectedItemName = ""; 
        let selectedItemQuantity = 0; 
        let itemsToUpdate = []; 

        function searchItems() {
            const query = document.getElementById("searchInput").value;
            const xhr = new XMLHttpRequest();
            xhr.open("GET", "Aincreasequantity?query=" + encodeURIComponent(query), true);
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    const response = JSON.parse(xhr.responseText);
                    console.log("Response from server:", response);
                    const items = response.items; 
                    const itemsList = document.getElementById("itemsList");
                    itemsList.innerHTML = ""; 

                    items.forEach(item => {
                        const li = document.createElement("li");
                        li.className = "item"; 

                        li.innerHTML = `
                            <strong>Item Code:</strong> ${item.itemCode}, 
                            <strong>Item Name:</strong> ${item.itemName}, 
                            <strong>Current Quantity:</strong> ${item.totalQuantity} 
                            <button onclick="selectItem('${item.itemCode}', '${item.itemName}', ${item.totalQuantity})">Select</button>`;

                        itemsList.appendChild(li);
                    });
                }
            };
            xhr.send();
        }

        function selectItem(itemCode, itemName, totalQuantity) {
            console.log("Selected Item Code:", itemCode);
            console.log("Selected Item Name:", itemName);
            console.log("Selected Item Quantity:", totalQuantity);
            selectedItemId = itemCode; 
            selectedItemName = itemName; 
            selectedItemQuantity = totalQuantity; 

            document.getElementById("selectedItemDetails").innerHTML = `
                <strong>Selected Item:</strong> ${selectedItemName} (Code: ${selectedItemId})<br>
                <strong>Current Quantity:</strong> ${selectedItemQuantity}<br>
                <input type="number" id="quantityInput" placeholder="Enter quantity to add" min="1" max="99999">
                <button class="da_button" onclick="addToUpdateList()">Add to List</button>`;
        }
        function addToUpdateList() {
            const quantity = document.getElementById("quantityInput").value;
            if (quantity > 0) {
                const itemToUpdate = {
                    itemCode: selectedItemId,
                    itemName: selectedItemName,
                    quantity: parseInt(quantity) // Ensure this is a valid number
                };
                itemsToUpdate.push(itemToUpdate);
                updateItemsList();
            } else {
                alert("Please enter a valid quantity.");
            }
        }

        function updateItemsList() {
            const itemsList = document.getElementById("itemsToUpdate");
            itemsList.innerHTML = ""; 
            itemsToUpdate.forEach(item => {
                const li = document.createElement("li");
                li.className = "item";
                li.innerHTML = `
                    <strong>Item Code:</strong> ${item.itemCode}, 
                    <strong>Item Name:</strong> ${item.itemName}, 
                    <strong>Quantity to Add:</strong> ${item.quantity}`;
                itemsList.appendChild(li);
            });
        }

        function updateQuantity() {
            if (itemsToUpdate.length === 0) {
                alert("No items to update.");
                return;
            }
            console.log("Items to Update:", itemsToUpdate);
            const xhr = new XMLHttpRequest();
            xhr.open("POST", "Aincreasequantity", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    const response = JSON.parse(xhr.responseText);
                    if (response.success) {
                        alert("Quantity updated successfully!");
                        searchItems(); 
                        itemsToUpdate = []; 
                        updateItemsList(); 
                    } else {
                        alert("Failed to update quantity.");
                    }
                }
            };
            const itemsToUpdateString = JSON.stringify(itemsToUpdate);
            xhr.send("action=updateQuantity&itemsToUpdate=" + encodeURIComponent(itemsToUpdateString));
        }
    </script>
</head>
<body>
    <div class="header">
        <h1>MV88 Ventures Inventory System</h1>
    </div>
    <div class="sub-header">
        <a href="Ahome.jsp">&#8592; back</a>
    </div>
    <div class="container">
        <div class="left-side">
            <div class="search-bar">
                <input type="text" id="searchInput" placeholder="Search Item Name/Code" onkeyup="searchItems()">
                <button class="da_button" onclick="searchItems()">Search</button>
            </div>
            <div class="items-list">
                <h3>Items Code</h3>
                <ul id="itemsList">
                    <!-- Dynamic item list will be populated here -->
                </ul>
            </div>
            <div class="selected-item" id="selectedItemDetails">
                <!-- Selected item details will be displayed here -->
            </div>
        </div>
        <div class="right-side">
            <div class="add-list">
                <h3>List of Items to Update</h3>
                <ul id="itemsToUpdate">
                    <!-- Dynamic list of items to update will be populated here -->
                </ul>
            </div>
            <div class="confirm-add">
                <input type="checkbox" id="confirm-items">
                <label for="confirm-items">Confirm Items</label>
            </div>
            <button class="da_button" onclick="updateQuantity()">Update Item Quantity</button>
        </div>
    </div>
</body>
</html>