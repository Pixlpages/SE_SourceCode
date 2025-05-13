<%@ page session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "0");

    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    Boolean loggedIn = (Boolean) session.getAttribute("LoggedIn");

    if (loggedIn == null || !loggedIn || !"admin".equals(role)) {
        response.sendRedirect("error_session.jsp");
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MV88 Ventures Inventory System</title>
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

        .left-side,
        .right-side {
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

        .selected-item {
            margin-top: 20px;
            padding: 10px;
            background-color: #e0f7fa;
            border-radius: 5px;
        }

        #quantityInput {
            width: auto;
            max-width: 300px;
            padding: 6px 12px;
            margin: 8px 0;
            box-sizing: border-box;
            display: block;
        }

        table.display {
            width: 100%;
            border-collapse: collapse;
        }

        table.display th,
        table.display td {
            padding: 10px;
            border: 1px solid #ddd;
            text-align: left;
        }
        
        table.dataTable {
            width: 100% !important;
        }
    </style>
    <script>
        let itemsToUpdate = [];

        $(document).ready(function () {
            const table = $('#itemsTable').DataTable({
                ajax: {
                    url: 'Aincreasequantity',
                    dataSrc: 'aaData'
                },
                columns: [
                    { data: 0 },
                    { data: 1 },
                    { data: 2 }
                ]
            });

            $('#itemsTable tbody').on('click', 'tr', function () {
                const data = table.row(this).data();
                if (data) {
                    $('#selectedItemCode').text(data[0]);
                    $('#selectedItemName').text(data[1]);
                    $('#selectedItemQuantity').text(data[2]);
                    $('#selectedItem').show();
                }
            });

            $('#updateDatabaseButton').on('click', function () {
                const quantityToAdd = $('#quantityInput').val();
                const selectedItemCode = $('#selectedItemCode').text();
                const selectedItemName = $('#selectedItemName').text();

                if (selectedItemCode && quantityToAdd) {
                    itemsToUpdate.push({
                        itemCode: selectedItemCode,
                        itemName: selectedItemName,
                        quantity: quantityToAdd
                    });
                }

                if (itemsToUpdate.length === 0) {
                    alert("No items to update.");
                    return;
                }

                $.ajax({
                    url: 'Aincreasequantity',
                    type: 'POST',
                    data: {
                        action: 'updateQuantity',
                        itemsToUpdate: JSON.stringify(itemsToUpdate)
                    },
                    success: function () {
                        alert("Quantity updated successfully!");
                        table.ajax.reload();
                        itemsToUpdate = [];
                        $('#selectedItem').hide();
                        $('#quantityInput').val('');
                    },
                    error: function () {
                        alert("Error updating quantity. Please try again.");
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
    </div>
    <div class="container">
        <div class="left-side">
            <table id="itemsTable" class="display">
                <thead>
                    <tr>
                        <th>Item Code</th>
                        <th>Item Name</th>
                        <th>Total Quantity</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
        <div class="right-side">
            <h3>Item Details</h3>
            <div id="selectedItem" class="selected-item" style="display:none;">
                <h3>Selected Item</h3>
                <p><strong>Item Code:</strong> <span id="selectedItemCode"></span></p>
                <p><strong>Item Name:</strong> <span id="selectedItemName"></span></p>
                <p><strong>Total Quantity:</strong> <span id="selectedItemQuantity"></span></p>
                <input type="number" id="quantityInput" placeholder="Enter quantity to add" />
                <button id="updateDatabaseButton" class="da_button">Update Database</button>
            </div>
        </div>
    </div>
</body>

</html>