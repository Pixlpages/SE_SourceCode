<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pull Out Items</title>
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.21/css/jquery.dataTables.min.css">
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.21/js/jquery.dataTables.min.js"></script>
    <script>
        let itemsToPullout = []; // Array to hold items to pull out

        $(document).ready(function() {
            var table = $('#itemsTable').DataTable({
                "ajax": {
                    "url": "Bgetproducts", // Servlet to fetch products from the branch
                    "dataSrc": ""
                },
                "columns": [
                    { "data": "itemCode" },
                    { "data": "itemName" },
                    { "data": "totalQuantity" },
                    { "data": "criticallyLow" }
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

            // Add item to pullout list
            $('#addToPulloutButton').on('click', function() {
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
                itemsToPullout.forEach(function(item, index) {
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
            window.removeFromPullout = function(index) {
                itemsToPullout.splice(index, 1);
                updatePulloutList();
            };

            // // Submit the pullout request
            $('#submitPulloutButton').on('click', function() {
                if (itemsToPullout.length === 0) {
                    alert("No items to pull out.");
                    return;
                }

                $.ajax({
                    url: 'Bpullout',
                    type: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify(itemsToPullout),
                    success: function(response) {
                        alert(response.message);
                        itemsToPullout = []; // Clear the list after successful submission
                        updatePulloutList(); // Refresh the displayed list
                    },
                    error: function(xhr) {
                        alert("Error: " + xhr.responseText);
                    }
                });
            });
        });
    </script>
</head>
    <body>
        <h1>Pull Out Items</h1>
        <table id="itemsTable" class="display">
            <thead>
                <tr>
                    <th>Item Code</th>
                    <th>Item Name</th>
                    <th>Total Quantity</th>
                    <th>Critically Low</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>

        <div id="selectedItem" style="display:none;">
            <h2>Selected Item</h2>
            <p>Item Code: <span id="selectedItemCode"></span></p>
            <p>Item Name: <span id="selectedItemName"></span></p>
            <p>Total Quantity: <span id="selectedItemQuantity"></span></p>
            <input type="number" id="quantityInput" placeholder="Enter quantity" />
            <button id="addToPulloutButton">Add to Pullout</button>
        </div>

        <h2>Pullout List</h2>
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
    </body>
</html>