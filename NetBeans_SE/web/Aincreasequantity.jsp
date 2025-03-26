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
    <title>MV88 Ventures Inventory System</title>
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
            justify-content: space-between;
            padding: 20px;
        }
        .left-side, .right-side {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 45%;
        }
        .search-bar {
            display: flex;
            align-items: center;
            background-color: #e0e0e0;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .search-bar input {
            border: none;
            background: none;
            flex-grow: 1;
            padding: 5px;
            font-size: 16px;
        }
        .da_button {
            background-color: #5cb5c9;
            color: white;
            border: none;
            padding: 10px;
            border-radius: 5px;
            cursor: pointer;
        }
        .items-list, .add-list {
            background-color: #f0f0f0;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .items-list h3, .add-list h3 {
            margin-top: 0;
        }
        .item {
            display: flex;
            justify-content: space-between;
            padding: 10px;
            border-bottom: 1px solid #ccc;
        }
        .item:last-child {
            border-bottom: none;
        }
        .amount-location {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
        }
        .amount-location input, .amount-location select {
            margin-right: 10px;
            padding: 5px;
            font-size: 16px;
        }
        .confirm-add {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
        }
        .confirm-add input {
            margin-right: 10px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>MV88 Ventures Inventory System</h1>
    </div>
    <div class="sub-header">
        <a href="Ahome.jsp">&#8592; back</a>
    </div>
    <div class="container">
        <div class="left-side">
            <div class="search-bar">
                <input type="text" placeholder="Search Item Name/Code">
                <button class="da_button">Search</button>
            </div>
            <div class="items-list">
                <h3>Items Code</h3>
                <div class="item">
                    <span>Supporting line text lorem ipsum dolor sit</span>
                </div>
                <div class="item">
                    <span>Supporting line text lorem ipsum dolor sit</span>
                </div>
                <div class="item">
                    <span>Supporting line text lorem ipsum dolor sit</span>
                </div>
            </div>
            <div class="amount-location">
                <input type="number" placeholder="0-99999">
                <button class="da_button">Add to List</button>
            </div>
        </div>
        <div class="right-side">
            <div class="add-list">
                <h3>List of Items to Add</h3>
                <div class="item">
                    <span>List item</span>
                    <span>100+</span>
                </div>
                <div class="item">
                    <span>List item</span>
                    <span>100+</span>
                </div>
                <div class="item">
                    <span>List item</span>
                    <span>100+</span>
                </div>
            </div>
            <div class="confirm-add">
                <input type="checkbox" id="confirm-items">
                <label for="confirm-items">Confirm Items</label>
            </div>
            <button class="da_button">Add Items</button>
        </div>
    </div>
</body>
</html>
