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
    <title>Distribute Items</title>
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.21/css/jquery.dataTables.css">
    <script type="text/javascript" charset="utf8" src="https://code.jquery.com/jquery-3.5.1.js"></script>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.21/js/jquery.dataTables.js"></script>
    <style>
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
        .selected-item {
            margin-top: 20px;
            padding: 10px;
            background-color: #e0f7fa;
            border-radius: 5px;
        }
    </style>
    <script>
        let itemsToDistribute = []; // Array to hold items to distribute

        $(document).ready(function() {
            var table = $('#itemsTable').DataTable({
                "ajax": {
                    "url": "Agetproducts", // Servlet to fetch products
                    "dataSrc": ""
                },
                "columns": [
                    { "data": "itemCode" },
                    { "data": "itemName" },
                    { "data": "totalQuantity" }
                ]
            });

            // Handle row click event for item selection
            $('#itemsTable tbody').on('click', 'tr', function() {
                var data = table.row(this).data();
                if (data) {
                    // Display selected item details
                    $('#selectedItemCode').text(data.itemCode);
                    $('#selectedItemName').text(data.itemName);
                    $('#selectedItemQuantity').text(data.totalQuantity);
                    $('#quantityInput').val(''); // Clear previous input
                    $('#selectedItem').show();
                }
            });

            // Update database functionality
            $('#distributeButton').on('click', function() {
                var quantityToDistribute = $('#quantityInput').val();
                var selectedItemCode = $('#selectedItemCode').text();
                var selectedItemName = $('#selectedItemName').text();
                var targetBranch = $('#branchSelect').val(); // Get selected branch

                if (selectedItemCode && quantityToDistribute && targetBranch) {
                    // Add item to the batch list
                    itemsToDistribute.push({
                        itemCode: selectedItemCode,
                        itemName: selectedItemName,
                        quantity: quantityToDistribute,
                        branch: targetBranch // Include the target branch
                    });
                }

                if (itemsToDistribute.length === 0) {
                    alert("No items to distribute.");
                    return;
                }

                $.ajax({
                    url: 'Adistribute', // Your servlet to handle distribution
                    type: 'POST',
                    data: {
                        action: 'distributeItems',
                        itemsToDistribute: JSON.stringify(itemsToDistribute)
                    },
                    success: function(response) {
                        alert("Items distributed successfully!");
                        $('#itemsTable').DataTable().ajax.reload(); // Reload the table data
                        itemsToDistribute = []; // Clear the batch list
                        $('#selectedItem').hide(); // Hide the selected item details
                        $('#quantityInput').val(''); // Clear the input field
                    },
                    error: function() {
                        alert("Error distributing items. Please try again.");
                    }
                });
            });
        });
    </script>
</head>
<body>
    <div class="header">
        <h1>MV88 Ventures Inventory System</h1>
    </div>
    <div class="sub-header">
        <a href="Ahome.jsp">&#8592; back</a>
        <input type="text" id="searchInput" placeholder="Search items..." />
    </div>
    <div class="container">
        <div class="left-side">
            <table id="itemsTable" class="display">
                <thead>
                    <tr>
                        <th>Item Code</th>
                        <th>Item Name</th>
                        <th >Total Quantity</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>
        <div class="right-side">
            <h3>Item Details</h3>
            <div id="selectedItem" class="selected-item" style="display:none;">
                <h3>Selected Item</h3>
                <p><strong>Item Code:</strong> <span id="selectedItemCode"></span></p>
                <p><strong>Item Name:</strong> <span id="selectedItemName"></span></p>
                <p><strong>Total Quantity:</strong> <span id="selectedItemQuantity"></span></p>
                <input type="number" id="quantityInput" placeholder="Enter quantity to distribute" />
                <label for="branchSelect">Select Branch:</label>
                <select id="branchSelect">
                    <option value="">Select a branch</option>
                    <option value="Branch1">malabon</option>
                    <option value="Branch2">Branch 2</option>
                    <option value="Branch3">Branch 3</option>
                    <!-- Add more branches as needed -->
                </select>
                <button id="distributeButton" class="da_button">Distribute Items</button>
            </div> 
        </div>
    </div>
</body>
</html>