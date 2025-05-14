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
            flex-wrap: wrap;
            justify-content: space-between;
            gap: 20px;
            padding: 20px;
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

        .selected-item {
            margin-top: 20px;
            padding: 10px;
            background-color: #e0f7fa;
            border-radius: 5px;
        }

        table.dataTable {
            width: 100% !important;
        }

        .disabled-row {
            background-color: #ddd !important;
            pointer-events: none;
            cursor: not-allowed;
        }

        #itemsTable,
        #batchList {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }

        #itemsTable th,
        #itemsTable td,
        #batchList th,
        #batchList td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }

        #quantityInput,
        #branchSelect {
            width: auto;
            max-width: 300px;
            padding: 6px 12px;
            margin: 8px 0;
            box-sizing: border-box;
            display: block;
        }

        #addToBatchButton,
        #distributeButton,
        #batchList button {
            background-color: #5cb5c9;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin-top: 10px;
            width: auto;
            min-width: 120px;
        }

        #batchList button {
            background-color: #f44336;
            color: white;
            padding: 6px 12px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin: 0 auto;
            display: block;
            text-align: center;
        }

        #batchList td {
            text-align: center;
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

            #addToBatchButton,
            #distributeButton {
                width: 100%;
            }

            .sub-header {
                flex-direction: column;
                align-items: flex-start;
            }
        }

        /* Modal styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgb(0, 0, 0);
            background-color: rgba(0, 0, 0, 0.4);
        }

        .modal-content {
            background-color: #fefefe;
            margin: 15% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 80%;
            max-width: 500px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
        }

        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
        }

        .close:hover,
        .close:focus {
            color: black;
            text-decoration: none;
            cursor: pointer;
        }
    </style>
    <script>
        let itemsToDistribute = [];

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
                if ($(this).hasClass('disabled-row')) return; // Ignore disabled rows

                var data = table.row(this).data();
                if (data) {
                    $('#selectedItemCode').text(data.itemCode);
                    $('#selectedItemName').text(data.itemName);
                    $('#selectedItemQuantity').text(data.totalQuantity);
                    $('#quantityInput').val('');
                    $('#selectedItem').show();
                }
            });

            $('#addToBatchButton').on('click', function () {
                var quantity = parseInt($('#quantityInput').val());
                var code = $('#selectedItemCode').text();
                var name = $('#selectedItemName').text();
                var available = parseInt($('#selectedItemQuantity').text());

                if (!code || !quantity) {
                    alert("Please select an item and enter quantity.");
                    return;
                }

                if (quantity > available) {
                    $('#overQuantityModal').css("display", "block");
                    return;
                }

                itemsToDistribute.push({
                    itemCode: code,
                    itemName: name,
                    quantity: quantity
                });

                // Add after itemsToDistribute.push(...)
                $('#itemsTable tbody tr').each(function () {
                    var rowData = table.row(this).data();
                    if (rowData && rowData.itemCode === code) {
                        $(this).addClass('disabled-row');
                    }
                });

                updateBatchList();
                resetItemSelection();
            });


            function resetItemSelection() {
                $('#selectedItemCode').text('');
                $('#selectedItemName').text('');
                $('#selectedItemQuantity').text('');
                $('#quantityInput').val('');
                $('#selectedItem').hide();
            }

            function updateBatchList() {
                let html = '';
                itemsToDistribute.forEach(function (item, index) {
                    html += '<tr>' +
                        '<td>' + item.itemCode + '</td>' +
                        '<td>' + item.itemName + '</td>' +
                        '<td>' + item.quantity + '</td>' +
                        '<td><button onclick="removeFromBatch(' + index + ')">Remove</button></td>' +
                        '</tr>';
                });
                $('#batchList tbody').html(html);
            }

            window.removeFromBatch = function (index) {
                let item = itemsToDistribute[index];

                // Re-enable the row in the available items table
                $('#itemsTable tbody tr').each(function () {
                    var rowData = table.row(this).data();
                    if (rowData && rowData.itemCode === item.itemCode) {
                        $(this).removeClass('disabled-row'); // Remove the disabled class
                    }
                });

                // Remove the item from the batch list
                itemsToDistribute.splice(index, 1);

                // Update the batch list
                updateBatchList();
            };


            $('#distributeButton').on('click', function () {
                var branch = $('#branchSelect').val();
                if (!branch) {
                    alert("Please select a branch for distribution.");
                    return;
                }

                if (itemsToDistribute.length > 0) {
                    itemsToDistribute.forEach(item => item.branch = branch);

                    $.ajax({
                        url: 'Adistribute',
                        type: 'POST',
                        contentType: 'application/json',
                        data: JSON.stringify(itemsToDistribute),
                        success: function (criticallyLowItems) {
                            $('#itemsTable tbody tr').removeClass('disabled-row');

                            alert("Items distributed successfully!");

                            // Check if there are critically low items
                            if (criticallyLowItems.length > 0) {
                                showModal(criticallyLowItems);
                            }

                            itemsToDistribute = [];
                            updateBatchList();
                            table.ajax.reload();
                            $('#branchSelect').val('');
                        },
                        error: function (xhr, status, error) {
                            alert("Error: " + error);
                        }
                    });
                } else {
                    alert("No items to distribute.");
                }
            });

            function showModal(criticallyLowItems) {
                $('#modalContent').text("Warning: The following items are critically low: " + criticallyLowItems.join(", "));
                $('#myModal').css("display", "block");
            }

            $('.close').on('click', function () {
                $('#myModal').css("display", "none");
            });

            $(window).on('click', function (event) {
                if ($(event.target).is('#myModal')) {
                    $('#myModal').css("display", "none");
                }
            });
            $('.close-over').on('click', function () {
                $('#overQuantityModal').css("display", "none");
            });

            $(window).on('click', function (event) {
                if ($(event.target).is('#overQuantityModal')) {
                    $('#overQuantityModal').css("display", "none");
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
                <button id="addToBatchButton">Add to Batch</button>
            </div>
            <h2>Batch List</h2>
            <table id="batchList">
                <thead>
                    <tr>
                        <th>Item Code</th>
                        <th>Item Name</th>
                        <th>Quantity</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
            <select id="branchSelect">
                <option value="">Select Branch</option>
                <option value="bacolod">Bacolod</option>
                <option value="cebu">Cebu</option>
                <option value="marquee">Marquee</option>
                <option value="olongapo">Olongapo</option>
                <option value="subic">Subic</option>
                <option value="tacloban">Tacloban</option>
                <option value="tagaytay">Tagaytay</option>
                <option value="urdaneta">Urdaneta</option>
            </select>
            <button id="distributeButton">Distribute Items</button>
        </div>
    </div>
    <div id="overQuantityModal" class="modal">
        <div class="modal-content">
            <span class="close-over">&times;</span>
            <p id="overQuantityContent">You cannot distribute more than the available quantity.</p>
        </div>
    </div>

    <div id="myModal" class="modal">
        <div class="modal-content">
            <span class="close">&times;</span>
            <p id="modalContent"></p>
        </div>
    </div>
</body>

</html>