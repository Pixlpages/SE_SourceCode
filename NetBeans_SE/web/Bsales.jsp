<!DOCTYPE html>
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

        @media screen and (max-width: 768px) {
            .container {
                flex-direction: column;
                padding: 10px;
            }

            .left-side,
            .right-side {
                width: 100%;
            }

            #addToPullOutButton,
            #submitPullOutButton {
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
            background-color: rgb(0,0,0); 
            background-color: rgba(0,0,0,0.4); 
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
        let itemsToPullout = []; // Array to hold items to pull out

        $(document).ready(function () {
            var table = $('#itemsTable').DataTable({
                "ajax": {
                    "url": "Bgetproducts", // Servlet to fetch products from the branch
                    "dataSrc": ""
                },
                "columns": [
                    { "data": "itemCode" },
                    { "data": "itemName" },
                    { "data": "totalQuantity" }
                ]
            });

            // Handle row click event for item selection
            $('#itemsTable tbody').on('click', 'tr', function () {
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

            // Add item to pullout list
            $('#addToPulloutButton').on('click', function () {
                var quantityToPullout = $('#quantityInput').val();
                var selectedItemCode = $('#selectedItemCode').text();
                var selectedItemName = $('#selectedItemName').text();

                if (selectedItemCode && quantityToPullout) {
                    // Add item to the pullout list
                    itemsToPullout.push({
                        itemCode: selectedItemCode,
                        itemName: selectedItemName,
                        quantity: quantityToPullout
                    });

                    // Update the pullout list display
                    updatePulloutList();
                    resetItemInformation(); // Reset item information after adding
                } else {
                    alert("Please select an item and enter a quantity.");
                }
            });

            // Function to reset item information
            function resetItemInformation() {
                $('#selectedItemCode').text('');
                $('#selectedItemName').text('');
                $('#selectedItemQuantity').text('');
                $('#quantityInput').val(''); // Clear input
                $('#selectedItem').hide(); // Hide selected item details
            }

            // Function to update the pullout list display
            function updatePulloutList() {
                var pulloutListHtml = '';
                itemsToPullout.forEach(function (item, index) {
                    pulloutListHtml += '<tr>' +
                        '<td>' + item.itemCode + '</td>' +
                        '<td>' + item.itemName + '</td>' +
                        '<td>' + item.quantity + '</td>' +
                        '<td><button onclick="removeFromPullout(' + index + ')">Remove</button></td>' +
                        '</tr>';
                });
                $('#pulloutList tbody').html(pulloutListHtml);
            }

            // Function to remove an item from the pullout list
            window.removeFromPullout = function (index) {
                itemsToPullout.splice(index, 1);
                updatePulloutList();
            };

            // // Submit the pullout request
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
                        alert(response.message);
                        itemsToPullout = []; // Clear the list after successful submission
                        updatePulloutList(); // Refresh the displayed list
                    },
                    error: function (xhr) {
                        alert("Error: " + xhr.responseText);
                    }
                });
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
                <tbody>
                </tbody>
            </table>
        </div>
        <div class="right-side">
            <div id="selectedItem" style="display:none;">
                <h2>Selected Item</h2>
                <p>Item Code: <span id="selectedItemCode"></span></p>
                <p>Item Name: <span id="selectedItemName"></span></p>
                <p>Total Quantity: <span id="selectedItemQuantity"></span></p>
                <input type="number" id="quantityInput" placeholder="Enter quantity" />
                <button id="addToPulloutButton">Add to Pullout</button>
            </div>

            <h2>Item List</h2>
            <table id="pulloutList">
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

            <button id="submitPulloutButton">Submit Pullout</button>
        </div>
    </div>
</body>

</html>