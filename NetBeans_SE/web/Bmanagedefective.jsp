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
    <title>Manage Defective Items</title>
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
        .back {
            padding: 10px;
            color: black;
            cursor: pointer;
            display: block;
        }
        .container {
            padding: 20px;
            background: #f5f5f5;
            display: flex;
            gap: 30px;
            justify-content: space-around;
        }
        .box {
            background: #f3ecf9;
            padding: 20px;
            border-radius: 15px;
            width: 45%;
            box-shadow: 2px 2px 10px rgba(0, 0, 0, 0.1);
        }
        .input-field, select, button {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border-radius: 8px;
            border: 1px solid #ccc;
        }
        .da_button {
            background-color: #5cb5c9;
            color: white;
            border: none;
            padding: 10px;
            border-radius: 5px;
            cursor: pointer;
        }
        .checkbox {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .items-list {
            background: white;
            padding: 15px;
            border-radius: 10px;
            margin-top: 10px;
            max-height: 200px;
            overflow-y: auto;
            box-shadow: 1px 1px 5px rgba(0, 0, 0, 0.1);
        }
        .item {
            display: flex;
            justify-content: space-between;
            padding: 8px;
            background: #ede7f6;
            margin-bottom: 5px;
            border-radius: 5px;
            cursor: pointer;
        }
        .item:hover {
            background: #d1c4e9;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>MV88 Ventures Inventory System</h1>
    </div>
    <div class="sub-header">
        <a href="Bhome.jsp">&#8592; back</a>
    </div>
    <div class="container">
        <div class="box">
            <h3>Search Item Name/Code</h3>
            <input type="text" id="search" class="input-field" placeholder="Search..." onkeyup="searchItems()">
            <div id="searchResults" class="items-list"></div>
            <label>Amount of Defective Items</label>
            <input type="number" class="input-field" min="0" max="99999">
            <label>Reason</label>
            <select class="input-field">
                <option>Reason 1</option>
                <option>Reason 2</option>
            </select>
            <button class="da_button" onclick="addToList()">Add to List</button>
        </div>
        <div class="box">
            <h3>List of Items to Mark as Defective</h3>
            <div id="defectiveList" class="items-list"></div>
            <div class="checkbox">
                <input type="checkbox" id="confirm">
                <label for="confirm">Confirm Items</label>
            </div>
            <button class="da_button">Mark As Defective</button>
        </div>
    </div>

    <script>
        function searchItems() {
            let searchQuery = document.getElementById('search').value;
            fetch('/api/get-items?q=' + searchQuery)
                .then(response => response.json())
                .then(data => {
                    let resultsDiv = document.getElementById('searchResults');
                    resultsDiv.innerHTML = '';
                    data.forEach(item => {
                        let div = document.createElement('div');
                        div.className = 'item';
                        div.innerHTML = <span>${item.name}</span><span>100+</span>;
                        div.onclick = () => selectItem(item);
                        resultsDiv.appendChild(div);
                    });
                });
        }

        function selectItem(item) {
            document.getElementById('search').value = item.name;
        }

        function addToList() {
            let itemName = document.getElementById('search').value;
            let defectiveList = document.getElementById('defectiveList');
            let div = document.createElement('div');
            div.className = 'item';
            div.innerHTML = <span>${itemName}</span><span>100+</span>;
            defectiveList.appendChild(div);
        }
    </script>
</body>
</html>