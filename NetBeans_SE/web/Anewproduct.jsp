<!DOCTYPE html>
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

    // Get success or error message from request
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
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
        .left-side input[type="text"], .left-side select, .left-side input[type="number"] {
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
        .message {
            margin: 10px 0;
            padding: 10px;
            border-radius: 5px;
        }
        .success {
            background-color: #d4edda;
            color: #155724;
        }
        .error {
            background-color: #f8d7da;
            color: #721c24;
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
            <form action="AddItemServlet" method="POST">
                <input type="hidden" name="action" value="addItem">
                <input type="text" name="item_code" placeholder="Item Code" required>
                <input type="text" name="item_name" placeholder="Item Name" required>
                <div>
                    <input type="radio" id="dog" name="pet_category" value="dog" required>
                    <label for="dog">Dog</label>
                    <input type="radio" id="cat" name="pet_category" value="cat">
                    <label for="cat">Cat</label>
                    <input type="radio" id="dog-cat" name="pet_category" value="dog-cat">
                    <label for="dog-cat">Dog & Cat</label>
                </div>
                <select name="item_category" required>
                    <option value="category1">CODE 1</option>
                    <option value="category2">CODE 2</option>
                    <option value="category2">CODE 3</option>
                    <option value="category2">CODE 4</option>
                    <option value="category2">CODE 5</option>
                    <option value="category2">CODE 6</option>
                    <option value="category2">CODE 7</option>
                    <!-- Add more categories as needed -->
                </select>
                <input type="number" name="total_quantity" placeholder="Total Quantity" min="0" max="99999" required>
                <button type="submit" class="da_button">Add to List</button>
            </form>

            <!-- Display success or error message -->
            <c:if test="${not empty message}">
                <div class="message ${messageType}">
                    ${message}
                </div>
            </c:if>
        </div>
        <div class="right-side">
            <h3>Items to Include</h3>
            <c:if test="${not empty itemList}">
                <ul>
                    <c:forEach var="item" items="${itemList}">
                        <li>
                            <strong>Item Code:</strong> ${item.itemCode}, 
                            <strong>Item Name:</strong> ${item.itemName}, 
                            <strong>Category:</strong> ${item.itemCategory}, 
                            <strong>Pet Category:</strong> ${item.petCategory}, 
                            <strong>Quantity:</strong> ${item.totalQuantity}
                        </li>
                    </c:forEach>
                </ul>
                <form action="AddItemServlet" method="POST">
                    <input type="hidden" name="action" value="addAllItems">
                    <button type="submit" class="da_button">Include Items to Database</button>
                </form>
            </c:if>
            <c:if test="${empty itemList}">
                <p>No items added yet.</p>
            </c:if>
        </div>
    </div>
</body>
</html>