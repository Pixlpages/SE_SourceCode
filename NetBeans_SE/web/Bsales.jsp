<!DOCTYPE html>
<%@ page session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    // HTTP 1.1
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    // HTTP 1.0
    response.setHeader("Pragma", "no-cache");
    // Proxies
    response.setHeader("Expires", "0");

    // Session validation
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    Boolean loggedIn = (Boolean) session.getAttribute("LoggedIn");

    if (loggedIn == null || !loggedIn || !"staff".equals(role)) {
        // Redirect unauthorized users
        response.sendRedirect("error_session.jsp");
    }
%>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MV88 Ventures Inventory System</title>
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
        #pulloutList {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }

        #itemsTable th,
        #itemsTable td,
        #pulloutList th,
        #pulloutList td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }

        #quantityInput {
            width: auto;
            max-width: 300px;
            padding: 6px 12px;
            margin: 8px 0;
            box-sizing: border-box;
            display: block;
        }

        #addToPulloutButton,
        #submitPulloutButton,
        #pulloutList button {
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

        #pulloutList button {
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

        #pulloutList td {
            text-align: center;
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

        .close-over {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
        }


        .close:hover,
        .close:focus {
            color: black;
            text-decoration: none;
            cursor: pointer;
        }
    </style>
    <script>
        let itemsToPullout = [];

        $(document).ready(function () {
            var table = $('#itemsTable').DataTable({
                "ajax": {
                    "url": "Bgetproducts",
                    "dataSrc": ""
                },
                "columns": [
                    { "data": "itemCode" },
                    { "data": "itemName" },
                    { "data": "totalQuantity" }
                ]
            });

            // Store items already added to pullout
            var disabledItems = [];

            $('#itemsTable tbody').on('click', 'tr', function () {
                var data = table.row(this).data();
                var itemCode = data.itemCode;

                if (disabledItems.includes(itemCode)) {
                    return; // Item is already in the pullout, prevent selection
                }

                if (data) {
                    $('#selectedItemCode').text(data.itemCode);
                    $('#selectedItemName').text(data.itemName);
                    $('#selectedItemQuantity').text(data.totalQuantity);
                    $('#quantityInput').val('');
                    $('#selectedItem').show();
                }
            });

            $('#addToPulloutButton').on('click', function () {
                var quantityToPullout = $('#quantityInput').val();
                var selectedItemCode = $('#selectedItemCode').text();
                var selectedItemName = $('#selectedItemName').text();
                var totalQuantity = parseInt($('#selectedItemQuantity').text());

                if (selectedItemCode && quantityToPullout) {
                    if (parseInt(quantityToPullout) > totalQuantity) {
                        // Show modal if quantity exceeds total stock
                        $('#overQuantityModal').css("display", "block");
                        return;
                    }

                    itemsToPullout.push({
                        itemCode: selectedItemCode,
                        itemName: selectedItemName,
                        quantity: quantityToPullout
                    });

                    disabledItems.push(selectedItemCode); // Disable item
                    updatePulloutList();
                    resetItemInformation();
                    updateDisabledItems();
                } else {
                    alert("Please select an item and enter a quantity.");
                }
            });


            $('#submitPulloutButton').on('click', function () {
                if (itemsToPullout.length === 0) {
                    alert("No items to pull out.");
                    return;
                }

                $.ajax({
                    url: 'Bsales',
                    type: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify(itemsToPullout),
                    success: function (response) {
                        console.log("Response from server:", response); // Debug

                        alert("Items sold successfully!");

                        let criticallyLowArray = [];

                        if (Array.isArray(response)) {
                            criticallyLowArray = response;
                        } else if (typeof response === "string") {
                            try {
                                const parsed = JSON.parse(response);
                                if (Array.isArray(parsed)) {
                                    criticallyLowArray = parsed;
                                } else if (parsed && Array.isArray(parsed.criticallyLowItems)) {
                                    criticallyLowArray = parsed.criticallyLowItems;
                                }
                            } catch (e) {
                                console.error("Failed to parse JSON:", e);
                            }
                        }


                        if (criticallyLowArray.length > 0) {
                            showMod(criticallyLowArray);
                        }

                        itemsToPullout = [];
                        updatePulloutList();
                        resetItemInformation();
                        table.ajax.reload();

                        // Re-enable items after pulling out
                        disabledItems = [];
                        updateDisabledItems();
                    },
                    error: function (xhr) {
                        alert("Error: " + xhr.responseText);
                    }
                });
            });

            function showMod(criticallyLowItems) {
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

            function resetItemInformation() {
                $('#selectedItemCode').text('');
                $('#selectedItemName').text('');
                $('#selectedItemQuantity').text('');
                $('#quantityInput').val('');
                $('#selectedItem').hide();
            }

            function updatePulloutList() {
                var html = '';
                itemsToPullout.forEach(function (item, index) {
                    html += '<tr>' +
                        '<td>' + item.itemCode + '</td>' +
                        '<td>' + item.itemName + '</td>' +
                        '<td>' + item.quantity + '</td>' +
                        '<td><button onclick="removeFromPullout(' + index + ')">Remove</button></td>' +
                        '</tr>';
                });
                $('#pulloutList tbody').html(html);
            }

            window.removeFromPullout = function (index) {
                let item = itemsToPullout.splice(index, 1)[0];
                updatePulloutList();

                // Remove the item from the disabledItems array
                let itemCode = item.itemCode;
                disabledItems = disabledItems.filter(code => code !== itemCode);

                updateDisabledItems();
            };

            function updateDisabledItems() {
                $('#itemsTable tbody tr').each(function () {
                    var itemCode = $(this).find('td').eq(0).text();
                    if (disabledItems.includes(itemCode)) {
                        $(this).addClass('disabled-row');
                    } else {
                        $(this).removeClass('disabled-row');
                    }
                });
            }

            function showModal(message) {
                $('#modalContent').text(message);
                $('#myModal').css("display", "block");
            }
            // Close the over-quantity modal
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
        <h1>Sales</h1>
    </div>
    <div class="sub-header">
        <a href="Bhome.jsp">&#8592; back</a>
    </div>
    <div class="container">
        <div class="left-side">
            <h1>Items</h1>
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
            <div id="selectedItem" style="display:none;">
                <h2>Selected Item</h2>
                <p>Item Code: <span id="selectedItemCode"></span></p>
                <p>Item Name: <span id="selectedItemName"></span></p>
                <p>Total Quantity: <span id="selectedItemQuantity"></span></p>
                <input type="number" id="quantityInput" placeholder="Enter quantity" min="1" />
                <button id="addToPulloutButton">Add to List</button>
            </div>
            <h2>Sales List</h2>
            <table id="pulloutList">
                <thead>
                    <tr>
                        <th>Item Code</th>
                        <th>Item Name</th>
                        <th>Quantity</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
            <button id="submitPulloutButton">Submit Sales</button>
        </div>
    </div>

    <div id="overQuantityModal" class="modal">
        <div class="modal-content">
            <span class="close-over">&times;</span>
            <p>You cannot sell more than the available quantity.</p>
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