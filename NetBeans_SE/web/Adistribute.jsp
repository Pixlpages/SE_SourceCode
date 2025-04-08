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

<!DOCTYPE html>
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

            // Add item to batch list
            $('#addToBatchButton').on('click', function() {
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

                    // Update the batch list display
                    updateBatchList();

                    // Reset item information
                    resetItemInformation();
                } else {
                    alert("Please select an item, quantity, and branch.");
                }
            });

            // Function to reset item information
            function resetItemInformation() {
                $('#selectedItemCode').text('');
                $('#selectedItemName').text('');
                $('#selectedItemQuantity').text('');
                $('#quantityInput').val(''); // Clear input
                $('#branchSelect').val(''); // Reset branch selection
                $('#selectedItem').hide(); // Hide selected item details
            }

            // Function to update the batch list display
            function updateBatchList() {
                var batchListHtml = '';
                itemsToDistribute.forEach(function(item, index) {
                    batchListHtml += '<tr>' +
                        '<td>' + item.itemCode + '</td>' +
                        '<td>' + item.itemName + '</td>' +
                        '<td>' + item.quantity + '</td>' +
                        '<td>' + item.branch + '</td>' +
                        '<td><button onclick="removeFromBatch(' + index + ')">Remove</button></td>' +
                        '</tr>';
                });
                $('#batchList tbody').html(batchListHtml);
            }

            // Function to remove an item from the batch list
            window.removeFromBatch = function(index) {
                itemsToDistribute.splice(index, 1);
                updateBatchList();
            };

            // Submit the batch list for distribution
            $('#distributeButton').on('click', function() {
                if (itemsToDistribute.length > 0) {
                    $.ajax({
                        url: 'Adistribute', // Your servlet to handle distribution
                        type: 'POST',
                        contentType: 'application/json',
                        data: JSON.stringify(itemsToDistribute), // Send the items as JSON
                        success: function(response) {
                            alert("Items distributed successfully!");
                            itemsToDistribute = []; // Clear the batch list
                            updateBatchList(); // Refresh the display
                            table.ajax.reload(); // Reload the items table to reflect updated quantities
                        },
                        error: function(xhr, status, error) {
                            alert("Error distributing items: " + error);
                        }
                    });
                } else {
                    alert("No items in the batch list to distribute.");
                }
            });
        });
    </script>
</head>
<body>
    <div class="header">
        <h1>Distribute Items</h1>
    </div>
    <div class="sub-header">
        <a href="Ahome.jsp">&#8592; back</a>
    </div>
    <div class="container">
        <div class="left-side">
            <h2>Available Items</h2>
            <table id="itemsTable" class="display">
                <thead>
                    <tr>
                        <th>Item Code</th>
                        <th>Item Name</th>
                        <th>Total Quantity</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>
        <div class="right-side">
            <h2>Selected Item</h2>
            <div id="selectedItem" style="display:none;">
                <p><strong>Item Code:</strong> <span id="selectedItemCode"></span></p>
                <p><strong>Item Name:</strong> <span id="selectedItemName"></span></p>
                <p><strong>Total Quantity:</strong> <span id="selectedItemQuantity"></span></p>
                <input type="number" id="quantityInput" placeholder="Enter quantity" min="1">
                <select id="branchSelect">
                    <option value="">Select Branch</option>
                    <option value="Branch1">Malabon</option>
                    <option value="Branch2">Branch 2</option>
                    <option value="Branch3">Branch 3</option>
                </select>
                <button id="addToBatchButton">Add to Batch</button>
            </div>
            <h2>Batch List</h2>
            <table id="batchList">
                <thead>
                    <tr>
                        <th>Item Code</th>
                        <th>Item Name</th>
                        <th>Quantity</th>
                        <th>Branch</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- Batch items will be populated here -->
                </tbody>
            </table>
            <button id="distributeButton">Distribute Items</button>
        </div>
    </div>
</body>
</html>