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

    if (loggedIn == null || !loggedIn || !"staff".equals(role)) {
        response.sendRedirect("error_session.jsp"); // Redirect unauthorized users
    }
%>

<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MV88 Ventures Inventory System</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 0;
        }
        header {
            background-color: #4a90e2;
            color: white;
            padding: 10px;
            text-align: center;
            font-size: 24px;
        }
        .container {
            padding: 20px;
        }
        .dr-section {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }
        .dr-section h2 {
            margin-top: 0;
            font-size: 20px;
            color: #333;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .dr-section h2 a {
            color: #4a90e2;
            text-decoration: none;
            font-weight: bold;
            font-size: 16px;
        }
        .dr-section ul {
            list-style-type: none;
            padding: 0;
            margin: 10px 0;
        }
        .dr-section ul li {
            padding: 5px 0;
            border-bottom: 1px solid #ccc;
        }
        .dr-section ul li:last-child {
            border-bottom: none;
        }
        .dr-section .timestamp {
            font-size: 14px;
            color: #777;
            margin-top: 10px;
        }
        .dr-section .actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 15px;
        }
        .dr-section .actions button {
            background-color: #4a90e2;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
        }

        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            justify-content: center;
            align-items: center;
        }
        .modal-content {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            max-width: 500px;
            width: 100%;
        }
        .modal-header {
            font-size: 20px;
            font-weight: bold;
            margin-bottom: 15px;
        }
        .modal-body {
            margin-bottom: 15px;
        }
        .modal-footer {
            text-align: right;
        }
        .modal-footer button {
            background-color: #4a90e2;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
        }
        .close {
            cursor: pointer;
            float: right;
            font-size: 24px;
            font-weight: bold;
        }

        /* Circular Icon Styles */
        .circular-icon {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            object-fit: cover;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        table th, table td {
            padding: 10px;
            text-align: left;
            border-bottom: 1px solid #ccc;
        }
    </style>
</head>
<body>
    <header>
        MV88 Ventures Inventory System
    </header>
    <div class="container">
        <!-- DR Code Section 1 -->
        <div class="dr-section">
            <h2>
                DR Code 1
                <a href="#" class="view-all" onclick="openViewAllModal()">View All Products</a>
            </h2>
            <ul>
                <li>Item Code | Quantity</li>
                <li>Item Code | Quantity</li>
                <li>Item Code | Quantity</li>
                <li>Item Code | Quantity</li>
            </ul>
            <div class="timestamp">Report Today 23 min</div>
            <div class="actions">
                <button class="receive-button" onclick="openReceiveModal()">Receive Items</button>
            </div>
        </div>

        <!-- DR Code Section 2 -->
        <div class="dr-section">
            <h2>
                DR Code 2
                <a href="#" class="view-all" onclick="openViewAllModal()">View All Products</a>
            </h2>
            <ul>
                <li>Item Code | Quantity</li>
                <li>Item Code | Quantity</li>
                <li>Item Code | Quantity</li>
            </ul>
            <div class="timestamp">Report Today 23 min</div>
            <div class="actions">
                <button class="receive-button" onclick="openReceiveModal()">Receive Items</button>
            </div>
        </div>

        <!-- DR Code Section 3 -->
        <div class="dr-section">
            <h2>
                DR Code 3
                <a href="#" class="view-all" onclick="openViewAllModal()">View All Products</a>
            </h2>
            <ul>
                <li>Item Code | Quantity</li>
                <li>Item Code | Quantity</li>
                <li>Item Code | Quantity</li>
            </ul>
            <div class="timestamp">Report Today 23 min</div>
            <div class="actions">
                <button class="receive-button" onclick="openReceiveModal()">Receive Items</button>
            </div>
        </div>
    </div>

    <!-- View All Products Modal -->
    <div id="viewAllModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeViewAllModal()">&times;</span>
            <div class="modal-header">List of Items to Receive</div>
            <div class="modal-body">
                <table>
                    <tr>
                        <th></th>
                        <th>Item</th>
                        <th>Quantity</th>
                    </tr>
                    <tr>
                        <td><img src="https://via.placeholder.com/30" alt="Icon" class="circular-icon"></td>
                        <td>List Item</td>
                        <td>100+</td>
                    </tr>
                    <tr>
                        <td><img src="https://via.placeholder.com/30" alt="Icon" class="circular-icon"></td>
                        <td>List Item</td>
                        <td>100+</td>
                    </tr>
                    <tr>
                        <td><img src="https://via.placeholder.com/30" alt="Icon" class="circular-icon"></td>
                        <td>List Item</td>
                        <td>100+</td>
                    </tr>
                </table>
            </div>
            <div class="modal-footer">
                <button onclick="closeViewAllModal()">Close</button>
            </div>
        </div>
    </div>

<!-- Receive Items Modal -->
<div id="receiveModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeReceiveModal()">&times;</span>
        <div class="modal-header">Items to Update</div>
        <div class="modal-body">
            <!-- Flex container for both sections -->
            <div class="sections-container">
                <!-- List of Items to Receive Section -->
                <div class="section">
                    <h3>List of Items to Receive</h3>
                    <table>
                        <tr>
                            <th></th>
                            <th>Item</th>
                            <th>Quantity</th>
                        </tr>
                        <tr>
                            <td><img src="https://via.placeholder.com/30" alt="Icon" class="circular-icon"></td>
                            <td>List Item</td>
                            <td>100+</td>
                        </tr>
                        <tr>
                            <td><img src="https://via.placeholder.com/30" alt="Icon" class="circular-icon"></td>
                            <td>List Item</td>
                            <td>100+</td>
                        </tr>
                        <tr>
                            <td><img src="https://via.placeholder.com/30" alt="Icon" class="circular-icon"></td>
                            <td>List Item</td>
                            <td>100+</td>
                        </tr>
                    </table>
                    <div class="input-fields">
                        <div>
                            <label for="defectiveItem">Defective Item Name/Code:</label>
                            <input type="text" id="defectiveItem">
                        </div>
                        <div>
                            <label for="defectiveAmount">Amount of Defective Items:</label>
                            <input type="number" id="defectiveAmount" min="0" max="99999">
                        </div>
                        <div>
                            <label for="reason">Reason:</label>
                            <select id="reason">
                                <option>Reason 1</option>
                                <option>Reason 2</option>
                            </select>
                        </div>
                        <button onclick="addToList()">Add to List</button>
                    </div>
                </div>

                <!-- List of Items to Mark as Defective Section -->
                <div class="section">
                    <h3>List of Items to Mark as Defective</h3>
                    <table id="defectiveItemsTable">
                        <tr>
                            <th></th>
                            <th>Item</th>
                            <th>Quantity</th>
                        </tr>
                    </table>
                    <div class="confirm-section">
                        <label>
                            <input type="checkbox" id="confirmCheckbox"> Confirm Items
                        </label>
                        <button id="receiveButton" disabled onclick="receiveAndReportItems()">Receive & Report Items</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function addToList() {
        const defectiveItem = document.getElementById('defectiveItem').value;
        const defectiveAmount = document.getElementById('defectiveAmount').value;
        const reason = document.getElementById('reason').value;

        if (defectiveItem && defectiveAmount && reason) {
            const table = document.getElementById('defectiveItemsTable');
            const row = table.insertRow(-1);
            row.innerHTML = `
                <td><img src="https://via.placeholder.com/30" alt="Icon" class="circular-icon"></td>
                <td>${defectiveItem}</td>
                <td>${defectiveAmount}</td>
            `;
        }
    }

    document.getElementById('confirmCheckbox').addEventListener('change', function() {
        document.getElementById('receiveButton').disabled = !this.checked;
    });

    function receiveAndReportItems() {
        alert('Items received and reported successfully!');
        closeReceiveModal();
    }
</script>

<style>
    /* Flexbox container for both sections */
    .sections-container {
        display: flex;
        justify-content: space-between;
        gap: 20px; /* Adds space between the two sections */
    }

    /* Each section takes up equal width */
    .section {
        flex: 1; /* Ensures both sections take equal space */
        background-color: #f9f9f9;
        padding: 15px;
        border-radius: 5px;
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
    }

    .input-fields {
        margin-top: 10px;
    }

    .input-fields div {
        margin-bottom: 10px;
    }

    .confirm-section {
        margin-top: 10px;
    }

    .confirm-section label {
        display: block;
        margin-bottom: 10px;
    }

    /* Ensure tables take full width */
    table {
        width: 100%;
        border-collapse: collapse;
    }

    table th, table td {
        padding: 10px;
        text-align: left;
        border-bottom: 1px solid #ccc;
    }
</style>

<script>
    function addToList() {
        const defectiveItem = document.getElementById('defectiveItem').value;
        const defectiveAmount = document.getElementById('defectiveAmount').value;
        const reason = document.getElementById('reason').value;

        if (defectiveItem && defectiveAmount && reason) {
            const table = document.getElementById('defectiveItemsTable');
            const row = table.insertRow(-1);
            row.innerHTML = `
                <td><img src="https://via.placeholder.com/30" alt="Icon" class="circular-icon"></td>
                <td>${defectiveItem}</td>
                <td>${defectiveAmount}</td>
            `;
        }
    }

    document.getElementById('confirmCheckbox').addEventListener('change', function() {
        document.getElementById('receiveButton').disabled = !this.checked;
    });

    function receiveAndReportItems() {
        alert('Items received and reported successfully!');
        closeReceiveModal();
    }
</script>

<style>
    .section {
        width: 48%;
        display: inline-block;
        vertical-align: top;
        margin-right: 2%;
    }

    .input-fields {
        margin-top: 10px;
    }

    .input-fields div {
        margin-bottom: 10px;
    }

    .confirm-section {
        margin-top: 10px;
    }

    .confirm-section label {
        display: block;
        margin-bottom: 10px;
    }
</style>

    <script>
        // Function to open View All Products modal
        function openViewAllModal() {
            document.getElementById("viewAllModal").style.display = "flex";
        }

        // Function to close View All Products modal
        function closeViewAllModal() {
            document.getElementById("viewAllModal").style.display = "none";
        }

        // Function to open Receive Items modal
        function openReceiveModal() {
            document.getElementById("receiveModal").style.display = "flex";
        }

        // Function to close Receive Items modal
        function closeReceiveModal() {
            document.getElementById("receiveModal").style.display = "none";
        }
    </script>
</body>
</html>