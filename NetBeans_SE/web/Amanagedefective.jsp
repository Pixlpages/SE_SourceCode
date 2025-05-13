<!DOCTYPE html>
<%@ page session="true" %>
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
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Defective Items</title>
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.21/css/jquery.dataTables.css">
    <script src="https://code.jquery.com/jquery-3.5.1.js"></script>
    <script src="https://cdn.datatables.net/1.10.21/js/jquery.dataTables.js"></script>
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
            flex-wrap: wrap;
            gap: 20px;
            padding: 20px;
            justify-content: space-between;
        }

        .left-side,
        .right-side {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            flex: 1 1 45%;
            min-width: 300px;
        }

        table.dataTable {
            width: 100% !important;
        }

        .da_button {
            background-color: #5cb5c9;
            color: white;
            border: none;
            padding: 10px;
            border-radius: 5px;
            cursor: pointer;
            width: 100%;
            max-width: 200px;
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

        #itemsTable th,
        #itemsTable td{
    border: 1px solid #ddd;
    padding: 8px;
    text-align: left;
}
        
        @media screen and (max-width: 768px) {
            .container {
                flex-direction: column;
                padding: 10px;
            }

            .left-side,
            .right-side {
                width: 100%;
            }

            .da_button {
                width: 100%;
            }
        }
    </style>
    <script>
        $(document).ready(function () {
            var table = $('#itemsTable').DataTable({
                "ajax": {
                    "url": "Agetmal",
                    "dataSrc": ""
                },
                "columns": [
                    { "data": "itemCode" },
                    { "data": "itemName" },
                    { "data": "totalQuantity" }
                ]
            });

            $('#itemsTable tbody').on('click', 'tr', function () {
                var data = table.row(this).data();
                if (data) {
                    $('#selectedItemCode').text(data.itemCode);
                    $('#selectedItemName').text(data.itemName);
                    $('#selectedItemQuantity').text(data.totalQuantity);
                    $('#selectedItemDetails').show();
                }
            });

            $('#markDefectiveButton').on('click', function () {
                var itemCode = $('#selectedItemCode').text();
                var cause = $('#defectCause').val();
                var quantity = $('#defectQuantity').val();

                if (!itemCode || !cause || !quantity) {
                    alert("Please complete all fields.");
                    return;
                }

                $.ajax({
                    url: 'Amanagedefective',
                    type: 'POST',
                    data: {
                        itemCode: itemCode,
                        cause: cause,
                        quantity: quantity
                    },
                    success: function (response) {
                        alert("Defective status updated successfully!");
                        table.ajax.reload();
                        $('#selectedItemDetails').hide();
                    },
                    error: function (xhr) {
                        if (xhr.status === 409) {
                            alert("Not enough quantity in stock.");
                        } else {
                            alert("Error updating defective status.");
                        }
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
            <h3>Items List</h3>
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
            <h3>Mark Item as Defective</h3>
            <div id="selectedItemDetails" style="display:none;">
                <p><strong>Item Code:</strong> <span id="selectedItemCode"></span></p>
                <p><strong>Item Name:</strong> <span id="selectedItemName"></span></p>
                <p><strong>Total Quantity:</strong> <span id="selectedItemQuantity"></span></p>

                <label for="defectCause">Cause of Defect:</label>
                <select id="defectCause">
                    <option value="">-- Select Cause --</option>
                    <option value="Damaged during transport">Damaged during transport</option>
                    <option value="Manufacturing defect">Manufacturing defect</option>
                    <option value="Customer return">Customer return</option>
                    <option value="Expired">Expired</option>
                </select><br><br>
                
                <label for="defectQuantity">Defective Quantity:</label>
                <input type="number" id="defectQuantity" min="1" placeholder="Enter quantity" required><br><br>

                <button id="markDefectiveButton" class="da_button">Update Defective Status</button>
            </div>
        </div>
    </div>
</body>

</html>