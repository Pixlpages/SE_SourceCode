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
    <title>Edit Product</title>
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
            flex-wrap: wrap;
        }

        .left-side,
        .right-side {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 45%;
            min-width: 300px;
            box-sizing: border-box;
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
            width: 100%;
            padding: 8px;
            margin: 8px 0;
            box-sizing: border-box;
        }

        #addToBatchButton,
        #distributeButton,
        #batchList button,
        #editButton {
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
            }

            .left-side,
            .right-side {
                width: 100%;
                margin-bottom: 20px;
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
    </style>

    <script>
        let itemsToEdit = []; // Array to hold items to edit

        $(document).ready(function () {
            var table = $('#itemsTable').DataTable({
                "ajax": {
                    "url": "Agetproducts", // Servlet to fetch products
                    "dataSrc": ""
                },
                "columns": [
                    { "data": "itemCode" },
                    { "data": "itemName" },
                    { "data": "itemCategory" },
                    { "data": "petCategory" },
                    { "data": "totalQuantity" },
                    { "data": "criticalCondition" }
                ]
            });

            // Handle row click event for item selection
            $('#itemsTable tbody').on('click', 'tr', function () {
                var data = table.row(this).data();
                if (data) {
                    // Display selected item details
                    $('#selectedItemCode').text(data.itemCode);
                    $('#selectedItemName').text(data.itemName);
                    $('#newItemName').val(data.itemName);
                    $('#selectedItemCategory').text(data.itemCategory);
                    $('#selectedItemQuantity').text(data.totalQuantity);
                    $('#selectedItemCondition').text(data.criticalCondition);
                    $('#newItemCondition').val(data.criticalCondition);
                    $('#quantityInput').val(''); // Clear previous input
                    $('#selectedItem').show();
                }
            });

            // Add item to batch list
            $('#addToBatchButton').on('click', function () {
                var itemCode = $('#selectedItemCode').text();
                var itemName = $('#newItemName').val();
                var criticalCondition = $('#newItemCondition').val();
                var itemCategory = $('#itemCategorySelect').val(); // Get the selected item category
                var petCategory = $('input[name="petCategory"]:checked').val();

                if (itemCode && itemName && itemCategory && petCategory) {
                    // Add item to the batch list
                    itemsToEdit.push({
                        itemCode: itemCode,
                        itemName: itemName,
                        criticalCondition: criticalCondition,
                        itemCategory: itemCategory, // Include item category
                        petCategory: petCategory
                    });

                    // Update the batch list display
                    updateBatchList();
                } else {
                    alert("Please select an item and fill in all fields.");
                }
            });

            // Function to update the batch list display
            function updateBatchList() {
                var batchListHtml = '';
                itemsToEdit.forEach(function (item, index) {
                    batchListHtml += '<tr>' +
                        '<td>' + item.itemCode + '</td>' +
                        '<td>' + item.itemName + '</td>' +
                        '<td>' + item.criticalCondition + '</td>' +
                        '<td>' + item.itemCategory + '</td>' + // Display item category
                        '<td>' + item.petCategory + '</td>' +
                        '<td><button onclick="removeFromBatch(' + index + ')">Remove</button></td>' +
                        '</tr>';
                });
                $('#batchList tbody').html(batchListHtml);
            }

            // Function to remove an item from the batch list
            window.removeFromBatch = function (index) {
                itemsToEdit.splice(index, 1);
                updateBatchList();
            };

            // Submit the batch list for editing
            $('#editButton').on('click', function () {
                if (itemsToEdit.length > 0) {
                    $.ajax({
                        url: 'Aeditproduct', // Your servlet to handle editing
                        type: 'POST',
                        contentType: 'application/json',
                        data: JSON.stringify(itemsToEdit), // Send the items as JSON
                        success: function (response) {
                            alert("Items edited successfully!");
                            table.ajax.reload();
                            itemsToEdit = []; // Clear the batch list
                            updateBatchList(); // Refresh the display
                        },
                        error: function (xhr, status, error) {
                            alert("Error editing items: " + error);
                        }
                    });
                } else {
                    alert("No items in the batch list to edit.");
                }
            });
        });
    </script>
</head>

<body>
    <div class="header">
        <h1>Edit Product</h1>
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
                        <th>Item Category</th>
                        <th>Pet Category</th>
                        <th>Total Quantity</th>
                        <th>Critical Condition</th>
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
                <p><strong>New Item Name:</strong> <input type="text" id="newItemName"/></p>
                <p><strong>Total Quantity:</strong> <span id="selectedItemQuantity"></span></p>
                <p><strong>Critical Condition:</strong> <span id="selectedItemCondition"></span></p>
                <p><strong>New Critical Condition:</strong> <input type="number" id="newItemCondition"/></p>
                <select id="itemCategorySelect">
                    <option value="CODE1">CODE 1</option>
                    <option value="CODE2">CODE 2</option>
                    <option value="CODE3">CODE 3</option>
                    <option value="CODE4">CODE 4</option>
                    <option value="CODE5">CODE 5</option>
                    <option value="CODE6">CODE 6</option>
                    <option value="CODE7">CODE 7</option>
                    </select>
                <div class="pet-category-options">
                    <label>
                        <input type="radio" name="petCategory" value="Dog" id="petCategoryDog"> Dog
                    </label>
                    <label>
                        <input type="radio" name="petCategory" value="Cat" id="petCategoryCat"> Cat
                    </label>
                    <label>
                        <input type="radio" name="petCategory" value="Both" id="petCategoryBoth"> Both
                    </label>
                </div>
                <button id="addToBatchButton">Add to Batch</button>
            </div>
            <h2>Batch List</h2>
            <table id="batchList">
                <thead>
                    <tr>
                        <th>Item Code</th>
                        <th>Item Name</th>
                        <th>Critical Condition</th>
                        <th>Item Category</th>
                        <th>Pet Category</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
            <button id="editButton">Edit Items</button>
        </div>
    </div>
</body>

</html>