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

        .view-reports {
            margin: 20px;
        }

        .tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }

        .tab {
            background: #fff;
            border: 1px solid #ddd;
            display: flex;
            align-items: center;
            border: none;
            background: none;
            cursor: pointer;
            font-size: 16px;
            padding: 5px;
        }

        .button-txt {
            margin-left: 0.3rem;
            vertical-align: middle;
        }

        .tab:hover {
            background: #e0e0e0;
        }

        .content-section {
            display: none;
            background: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
        }

        .content-section.active {
            display: block;
        }

        .items {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }

        .item {
            display: flex;
            align-items: center;
            background: #fff;
            padding: 10px;
            border-radius: 5px;
            box-shadow: 0 0 5px rgba(0, 0, 0, 0.1);
        }

        .item img {
            width: 50px;
            height: 50px;
            margin-right: 15px;
        }

        .pdf-viewer {
            width: 100%;
            height: 400px;
            border: none;
        }
    </style>
    <script>
        function showView(view, selectedButton) {
            let buttons = document.querySelectorAll(".tab");
            document.querySelectorAll('.content-section').forEach(section => {
                section.classList.remove('active');
            });
            document.getElementById(view).classList.add('active');
            buttons.forEach(button => {
                let img = button.querySelector(".folder-icon");
                if (button === selectedButton) {
                    img.src = "./Icons/open-folder.png"; // Open the selected folder
                    button.classList.add("active");
                } else {
                    img.src = "./Icons/folder.png"; // Close all other folders
                    button.classList.remove("active");
                }
            });
        }
    </script>
</head>

<body>
    <div class="header">
        <h1>MV88 Ventures Inventory System</h1>
    </div>
    <div class="sub-header">
        <a href="Bhome.jsp">&#8592; back</a>
    </div>

    <div class="view-reports">
        <h2>View Reports</h2>
        <div class="tabs">
            <button class="tab" onclick="showView('report', this)">
                <img src="./Icons/open-folder.png" width="42" height="42" alt="Folder Icon" class="folder-icon">
                <span class="button-txt">Report</span>
            </button>
            <button class="tab" onclick="showView('defective', this)">
                <img src=".\Icons\folder.png" width="42" height="42" alt="Folder Icon" class="folder-icon">
                <span class="button-txt">Defective</span>
            </button>
            <button class="tab" onclick="showView('critical', this)">
                <img src=".\Icons\folder.png" width="42" height="42" alt="Folder Icon" class="folder-icon">
                <span class="button-txt">Critical Condition</span>
            </button>
        </div>
    </div>

    <div id="report" class="content-section active">
        <h3>Branch Report</h3>
        <iframe src="Bview" width="100%" height="400px"></iframe>
    </div>

    <div id="defective" class="content-section">
        <h3>Defective</h3>
        <div class="items">
            <div class="item">
                <img src="grey-placeholder.png" alt="Item">
                <div class="item-info">
                    <p><strong>Item Name</strong></p>
                    <p>Item Code</p>
                    <p>Item Quantity</p>
                </div>
            </div>
            <div class="item">
                <img src="grey-placeholder.png" alt="Item">
                <div class="item-info">
                    <p><strong>Item Name</strong></p>
                    <p>Item Code</p>
                    <p>Item Quantity</p>
                </div>
            </div>
        </div>
    </div>

    <div id="critical" class="content-section">
        <h3>Critical Condition</h3>
        <div class="items">
            <div class="item">
                <img src="grey-placeholder.png" alt="Item">
                <div class="item-info">
                    <p><strong>Item Name</strong></p>
                    <p>Item Code</p>
                    <p>Item Location</p>
                    <p>Item Quantity</p>
                </div>
            </div>
            <div class="item">
                <img src="grey-placeholder.png" alt="Item">
                <div class="item-info">
                    <p><strong>Item Name</strong></p>
                    <p>Item Code</p>
                    <p>Item Location</p>
                    <p>Item Quantity</p>
                </div>
            </div>
        </div>
    </div>
</body>

</html>