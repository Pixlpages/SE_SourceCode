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

    if (loggedIn == null || !loggedIn || !"staff".equals(role)) {
        response.sendRedirect("error_session.jsp"); // Redirect unauthorized users
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Receive Shipments</title>
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.21/css/jquery.dataTables.min.css">
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.21/js/jquery.dataTables.min.js"></script>
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

        .left-side,
        .right-side {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 45%;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th, td {
            padding: 10px;
            text-align: left;
            border: 1px solid #ddd;
        }

        th {
            background-color: #f2f2f2;
        }

        .selected-receipt {
            margin-top: 20px;
            display: none;
        }

        .confirm-button {
            margin-top: 20px;
            padding: 10px 20px;
            background-color: #5cb5c9;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }

        .confirm-button:hover {
            background-color: #4cae4f;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Receive Shipments</h1>
    </div>
    <div class="sub-header">
        <a href="Bhome.jsp">&#8592; back</a>
    </div>
    <div class="container">
        <div class="left-side">
            <h1>Delivery Receipts</h1>
            <table id="receiptsTable" class="display">
                <thead>
                    <tr>
                        <th>DR Code</th>
                        <th>Item Code</th>
                        <th>Item Name</th>
                        <th>Quantity</th>
                        <th>Branch</th>
                        <th>Delivery Date</th>
                    </tr>
                </thead>
                <tbody id="receiptsBody">
                    <!-- Data will be populated here -->
                </tbody>
            </table>
        </div>
        <div class="right-side">
            <h2>Selected Receipt Details</h2>
            <div class="selected-receipt" id="selectedReceipt">
                <p>DR Code: <span id="selectedDrCode"></span></p>
                <p>Item Code: <span id="selectedItemCode"></span></p>
                <p>Quantity: <span id="selectedQuantity"></span></p>
                <p>Branch: <span id="selectedBranch"></span></p>
                <p>Delivery Date: <span id="selectedDeliveryDate"></span></p>
            </div>
        </div>
    </div>

    <script>
        $(document).ready(function() {
            // Initialize DataTable
            const table = $('#receiptsTable').DataTable({
                "ajax": {
                    "url": "Breceive", // Fetch all data without pagination
                    "dataSrc": "data" // Adjust based on your JSON structure
                },
                "columns": [
                    { "data": "drCode" },
                    { "data": "itemCode" },
                    { "data": "itemName" },
                    { "data": "quantity" },
                    { "data": "branch" },
                    { "data": "deliveryDate" }
                ],
                "lengthChange": false // Disable the option to change the number of records per page
            });

            // Handle row click event for receipt selection
            $('#receiptsTable tbody').on('click', 'tr', function() {
                var data = table.row(this).data();
                if (data) {
                    $('#selectedDrCode').text(data.drCode);
                    $('#selectedItemCode').text(data.itemCode);
                    $('#selectedQuantity').text(data.quantity);
                    $('#selectedBranch').text(data.branch);
                    $('#selectedDeliveryDate').text(data.deliveryDate);
                    $('#selectedItemName').text(data.itemName);
                    $('#selectedReceipt').show();
                }
            });

            // Handle confirm button click
            $('#confirmButton').on('click', function() {
                const selectedDrCode = $('#selectedDrCode').text();
                const selectedItemCode = $('#selectedItemCode').text();
                const selectedQuantity = $('#selectedQuantity').text();
                const selectedBranch = $('#selectedBranch').text();
                const selectedDeliveryDate = $('#selectedDeliveryDate').text();
                const selectedItemName = $('#selectedItemName').text();

                // Prepare data to send to the server
                const dataToSend = {
                    drCode: selectedDrCode,
                    itemCode: selectedItemCode,
                    quantity: selectedQuantity,
                    branch: selectedBranch,
                    deliveryDate: selectedDeliveryDate,
                    itemName: selectedItemName
                };

                // Send data to the server
                $.ajax({
                    url: 'AddToBranchTable', // Endpoint to handle adding items to the branch table
                    method: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify(dataToSend),
                    success: function(response) {
                        alert('Items confirmed and added to the branch table successfully!');
                        // Optionally, you can clear the selected receipt details after confirmation
                        $('#selectedReceipt').hide();
                        $('#receiptsTable').DataTable().ajax.reload(); // Reload the table data
                    },
                    error: function(xhr, status, error) {
                        console.error("Error adding items to branch table:", error);
                        alert('Failed to add items to the branch table. Please try again.');
                    }
                });
            });
        });
    </script>
</body>
</html>