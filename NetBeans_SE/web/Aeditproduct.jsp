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

.page-title {
    margin: 20px;
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
    <div class="page-title">
        <h2>Search Item to Edit</h2>
    </div>


    <div class="container">
        <div class="search-section">
            <div class="search-box">
                <button class="back-search">&#8592;</button>
                <input type="text" placeholder="Search Item Name/Code">
                <button class="clear-search">&#10006;</button>
            </div>
            <div class="search-results">
                <div class="search-item">
                    <img src="Placeholder.png" alt="icon">
                    <div>
                        <strong>Item Code</strong>
                        <p>Supporting line text lorem ipsum dolor si...</p>
                    </div>
                </div>
                <div class="search-item">
                    <img src="Placeholder.png" alt="icon">
                    <div>
                        <strong>Item Code</strong>
                        <p>Supporting line text lorem ipsum dolor si...</p>
                    </div>
                </div>
                <div class="search-item">
                    <img src="Placeholder.png" alt="icon">
                    <div>
                        <strong>Item Code</strong>
                        <p>Supporting line text lorem ipsum dolor si...</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="edit-section">
            <p>Selected Item Code: <strong>*item code*</strong></p>
            <input type="text" placeholder="Item Name">
            <div class="radio-group">
                <label><input type="radio" name="category"> Dog</label>
                <label><input type="radio" name="category"> Dog & Cat</label>
                <label><input type="radio" name="category"> Cat</label>
            </div>
            <select>
                <option>Category 1</option>
            </select>
            <input type="text" placeholder="Insert URL">
            <button class="confirm-btn">Confirm Edit</button>
        </div>
    </div>
</body>

</html>