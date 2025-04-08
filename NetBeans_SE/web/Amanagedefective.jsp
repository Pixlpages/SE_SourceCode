<!DOCTYPE html>
<%@ page session="true" %>
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
    <title>Manage Defective Items</title>
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.21/css/jquery.dataTables.css">
    <script type="text/javascript" charset="utf8" src="https://code.jquery.com/jquery-3.5.1.js"></script>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.21/js/jquery.dataTables.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 0;
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
        .da_button {
            background-color: #5cb5c9;
            color: white;
            border: none;
            padding: 10px;
            border-radius: 5px;
            cursor: pointer;
        }
        .defective-list {
            background-color: #f0f0f0;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .defective-list h3 {
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
    </style>
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
            <h3>Items List</h3>
            <table id="itemsTable" class="display">
                <thead>
                    <tr>
                        <th>Item Code</th>
                        <th>Item Name</th>
                        <th>Total Quantity</th>
                        <th>Is Defective</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- Data will be populated by DataTable -->
                </tbody>
            </table>
        </div>
        <div class="right-side">
            <h3>Mark Item as Defective</h3>
            <div id="selectedItemDetails" style="display:none;">
                <p><strong>Item Code:</strong> <span id="selectedItemCode"></span></p>
                <p><strong>Item Name:</strong> <span id="selected ItemName"></span></p>
                <p><strong>Total Quantity:</strong> <span id="selectedItemQuantity"></span></p>
                <label for="isDefective">Mark as Defective:</label>
                <select id="isDefective">
                    <option value="0">No</option>
                    <option value="1">Yes</option>
                </select>
                <button id="markDefectiveButton" class="da_button">Update Defective Status</button>
            </div>
        </div>
    </div>

    <script>
        $(document).ready(function() {
            var table = $('#itemsTable').DataTable({
                "ajax": {
                    "url": "Agetproducts", // Your servlet to fetch products
                    "dataSrc": ""
                },
                "columns": [
                    { "data": "itemCode" },
                    { "data": "itemName" },
                    { "data": "totalQuantity" },
                    { 
                        "data": "is_defective", 
                        "render": function(data) {
                            return String(data) === "1" ? "Yes" : "No"; // Ensure comparison is done correctly
                        }
                    }
                ]
            });

            // Handle row click event for item selection
            $('#itemsTable tbody').on('click', 'tr', function() {
                var data = table.row(this).data();
                if (data) {
                    // Populate the selected item details
                    $('#selectedItemCode').text(data.itemCode);
                    $('#selectedItemName').text(data.itemName);
                    $('#selectedItemQuantity').text(data.totalQuantity);
                    $('#isDefective').val(data.is_defective); // Set the dropdown based on current status
                    $('#selectedItemDetails').show(); // Show the details section
                }
            });

            // Handle marking item as defective
            $('#markDefectiveButton').on('click', function() {
                var itemCode = $('#selectedItemCode').text();
                var isDefective = $('#isDefective').val();

                $.ajax({
                    url: 'Amanagedefective', // Your servlet to update the defective status
                    type: 'POST',
                    data: {
                        itemCode: itemCode,
                        isDefective: isDefective
                    },
                    success: function(response) {
                        alert("Defective status updated successfully!");
                        table.ajax.reload(); // Reload the table data
                        $('#selectedItemDetails').hide(); // Hide the details section
                    },
                    error: function() {
                        alert("Error updating defective status. Please try again.");
                    }
                });
            });
        });
    </script>
</body>
</html>