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
        }
        .left-side, .right-side {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 45%;
        }
        .left-side h2 {
            margin-top: 0;
        }
        .left-side input[type="text"], .left-side select {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        .left-side input[type="radio"] {
            margin-right: 5px;
        }
        .left-side label {
            margin-right: 20px;
        }
        .da_button {
            background-color: #5cb5c9;
            color: white;
            border: none;
            padding: 10px;
            border-radius: 5px;
            cursor: pointer;
        }
        .right-side h3 {
            margin-top: 0;
        }
        .right-side .item {
            background-color: #e1bee7;
            padding: 10px;
            margin: 10px 0;
            border-radius: 5px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .right-side .item span {
            background-color: #d1c4e9;
            padding: 5px 10px;
            border-radius: 50%;
        }
        .right-side input[type="checkbox"] {
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
            <h2>Include Items</h2>
            <input type="text" placeholder="Item Code">
            <input type="text" placeholder="Item Name">
            <div>
                <input type="radio" id="dog" name="animal" value="dog">
                <label for="dog">Dog</label>
                <input type="radio" id="cat" name="animal" value="cat">
                <label for="cat">Cat</label>
                <input type="radio" id="dog-cat" name="animal" value="dog-cat">
                <label for="dog-cat">Dog & Cat</label>
            </div>
            <select>
                <option value="category1">Category 1</option>
                <!-- Add more categories as needed -->
            </select>
            <input type="text" placeholder="0-99999">
            <button class="da_button">Add to List</button>
        </div>
        <div class="right-side">
            <h3>Items to Include</h3>
            <!-- This is where the list of items will be displayed -->
        </div>
    </div>
</body>
</html>
