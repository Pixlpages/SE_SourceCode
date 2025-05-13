<%@ page session="true" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "0");

    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    Boolean loggedIn = (Boolean) session.getAttribute("LoggedIn");

    if (loggedIn == null || !loggedIn || !"staff".equals(role)) {
        response.sendRedirect("error_session.jsp");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Receive Shipments</title>
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.21/css/jquery.dataTables.min.css">
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.21/js/jquery.dataTables.min.js"></script>
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
        }

        .sub-header a {
            text-decoration: none;
            color: black;
        }

        .container {
            display: flex;
            padding: 20px;
            gap: 20px;
        }

        .left-side, .right-side {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 50%;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }
        table.dataTable {
            width: 100% !important;
        }

        th, td {
            padding: 10px;
            border: 1px solid #ddd;
        }

        th {
            background-color: #f2f2f2;
        }

        .right-side h2 {
            margin-top: 0;
        }

        .hidden {
            display: none;
        }
    </style>
    <script>
        $(document).ready(function () {
            // Left table: DR Code list
            const drTable = $('#drTable').DataTable({
                ajax: {
                    url: 'Breceive',
                    dataSrc: 'data'
                },
                columns: [
                    { data: 'drCode' },
                    { data: 'deliveryDate' }
                ],
                lengthChange: false
            });

            // Click row to load items
            $('#drTable tbody').on('click', 'tr', function () {
                const data = drTable.row(this).data();
                if (data && data.drCode) {
                    loadDRDetails(data.drCode);
                }
            });

            // Load items for selected DR code
            function loadDRDetails(drCode) {
    $.ajax({
        url: 'Breceive?drCode=' + encodeURIComponent(drCode),
        method: 'GET',
        success: function (response) {
            console.log("Response:", response);

            // Destroy existing DataTable if exists
            if ($.fn.DataTable.isDataTable('#detailsTable')) {
                $('#detailsTable').DataTable().clear().destroy();
            }

            // Reinitialize with new data
            $('#detailsTable').DataTable({
                data: response.data,
                columns: [
                    { data: 'itemCode' },
                    { data: 'itemName' },
                    { data: 'quantity' }
                ],
                destroy: true,
                lengthChange: false
            });

            $('#rightPanelTitle').text("Details for DR Code: " + drCode);
            $('#detailsTable').removeClass('hidden');
        },
        error: function () {
            alert("Failed to fetch DR details.");
        }
    });
}

        });
    </script>
</head>
<body>
<div class="header">
    <h1>Receive Shipments</h1>
</div>
<div class="sub-header">
    <a href="Bhome.jsp">&#8592; Back</a>
</div>
<div class="container">
    <div class="left-side">
        <h2>Delivery Receipts</h2>
        <table id="drTable" class="display">
            <thead>
                <tr>
                    <th>DR Code</th>
                    <th>Delivery Date</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
    <div class="right-side">
        <h2 id="rightPanelTitle">Select a DR Code</h2>
        <table id="detailsTable" class="display hidden">
            <thead>
                <tr>
                    <th>Item Code</th>
                    <th>Item Name</th>
                    <th>Quantity</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
</div>
</body>
</html>
