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
    <title>Edit Product</title>
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
        gap: 20px;
        padding: 20px;
    }

    .search-section {
        background-color: #ECE3F0;
        border-radius: 10px;
        padding: 10px;
        width: 50%;
    }

    .search-box {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 5px;
        border-bottom: 1px solid #ccc;
    }

    .search-box input {
        flex: 1;
        border: none;
        background: none;
        outline: none;
    }

    .search-results {
        max-height: 300px;
        overflow-y: auto;
    }

    .search-item {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px;
        background-color: white;
        border-radius: 5px;
        margin-top: 5px;
    }

    .search-item img {
        width: 20px;
        height: 20px;
        border-radius: 50%;
        background-color: purple;
    }

    .edit-section {
        flex-grow: 1;
        width: 50%;
    }

    .radio-group {
        display: flex;
        gap: 10px;
        margin-top: 10px;
    }

    input, select {
        display: block;
        margin-top: 10px;
        padding: 5px;
        width: 100%;
        border: 1px solid #ccc;
        border-radius: 5px;
    }

    .confirm-btn {
        margin-top: 10px;
        padding: 10px;
        background-color: lightgray;
        border: none;
        cursor: pointer;
    }

    h2 {
        display: block;
        font-size: 1.5em;
        margin-block-start: 0.83em;
        margin-block-end: 0.83em;
        margin-inline-start: 0px;
        margin-inline-end: 0px;
        font-weight: bold;
        unicode-bidi: isolate;
    }
    
    .pet-category-options {
        display: flex;
        flex-direction: center; /* Stack radio buttons vertically */
        gap: 15px; /* Space between radio buttons */
    }

    .pet-category-options label {
        display: flex;
        align-items: center; /* Center align the radio button and text */
        margin: 0; /* Remove default margin */
    }
    </style>
    <script>
        $(document).ready(function() {
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
                    { "data": "totalQuantity" }
                ]
            });

            // Handle row click event for item selection
            $('#itemsTable tbody').on('click', 'tr', function() {
                var data = table.row(this).data();
                if (data) {
                    // Populate the edit form with selected item data
                    $('#itemCodeInput').val(data.itemCode);
                    $('#itemNameInput').val(data.itemName);
                    $('#itemCategorySelect').val(data.itemCategory);
                    $('#petCategoryInput').val(data.petCategory);
                    
                    $('input[name="petCategory"]').prop('checked', false); // Uncheck all radio buttons
                    if (data.petCategory) {
                       $('input[name="petCategory"][value="' + data.petCategory + '"]').prop('checked', true); // Check the corresponding radio button
                    }
                }
            });

            // Handle confirm edit button click
            $('.confirm-btn').on('click', function() {
                var itemCode = $('#itemCodeInput').val();
                var itemName = $('#itemNameInput').val();
                var itemCategory = $('#itemCategorySelect').val();
                var petCategory = $('input[name="petCategory"]:checked').val();

                $.ajax({
                    url: 'Aeditproduct', // Your servlet to handle the edit
                    type: 'POST',
                    data: {
                        itemCode: itemCode,
                        itemName: itemName,
                        itemCategory: itemCategory,
                        petCategory: petCategory
                    },
                    success: function(response) {
                        alert("Item updated successfully!");
                        table.ajax.reload(); // Reload the table data
                    },
                    error: function() {
                        alert("Error updating item. Please try again.");
                    }
                });
            });

            // Handle delete button click
            $('#deleteButton').on('click', function() {
                var itemCode = $('#itemCodeInput').val();

                if (itemCode) {
                    $.ajax({
                        url: 'Aeditproduct_delete', // Your servlet to handle the delete
                        type: 'POST',
                        data: {
                            itemCode: itemCode
                        },
                        success: function(response) {
                            alert("Item deleted successfully!");
                            table.ajax.reload(); // Reload the table data
                            $('#itemCodeInput').val(''); // Clear the input field
                            $('#itemNameInput').val('');
                            $('#itemCategorySelect').val('');
                        },
                        error: function() {
                            alert("Error deleting item. Please try again.");
                        }
                    });
                } else {
                    alert("No item selected for deletion.");
                }
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
        <div class="search-section">
            <table id="itemsTable" class="display">
                <thead>
                    <tr>
                        <th>Item Code</th>
                        <th>Item Name</th>
                        <th>Category</th>
                        <th>Pet Category</th>
                        <th>Total Quantity</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>

        <div class="edit-section">
            <h3>Edit Selected Item</h3>
            <h4>Item Code:</h4>
            <input type="text" id="itemCodeInput" placeholder="Item Code" required>
            <h4>Item Name:</h4>
            <input type="text" id="itemNameInput" placeholder="Item Name" required>
            <h4>Item Category:</h4>
            <select id="itemCategorySelect" required>
                <option value="CODE1">CODE 1</option>
                <option value="CODE2">CODE 2</option>
                <option value="CODE3">CODE 3</option>
                <option value="CODE4">CODE 4</option>
                <option value="CODE5">CODE 5</option>
                <option value="CODE6">CODE 6</option>
                <option value="CODE7">CODE 7</option>
                <!-- Add more categories as needed -->
            </select>
            <h4>Pet Category:</h4>
            <div class="pet-category-options">
                <label>
                    <input type="radio" name="petCategory" value="Cat" id="petCategoryCat"> Cat
                </label>
                <label>
                    <input type="radio" name="petCategory" value="Dog" id="petCategoryDog"> Dog
                </label>
                <label>
                    <input type="radio" name="petCategory" value="Both" id="petCategoryBoth"> Both
                </label>
            </div>
            <button type="button" class="confirm-btn">Confirm Edit</button>
            <button type="button" id="deleteButton" class="confirm-btn">Delete Item</button>
        </div>
    </div>
</body>
</html>