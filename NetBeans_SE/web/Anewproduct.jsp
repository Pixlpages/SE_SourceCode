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

<!DOCTYPE html>
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
            flex-wrap: wrap;
            justify-content: space-between;
            gap: 20px;
            padding: 20px;
        }

        .left-side,
        .right-side {
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            flex: 1 1 45%;
            min-width: 300px;
            box-sizing: border-box;
        }

        .left-side h2,
        .right-side h3 {
            margin-top: 0;
        }

        .left-side input[type="text"],
        .left-side input[type="number"],
        .left-side select {
            width: 100%;
            padding: 10px;
            margin-top: 10px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
            box-sizing: border-box;
        }

        .left-side label {
            margin-right: 15px;
        }

        .left-side input[type="radio"] {
            margin-right: 5px;
        }

        .left-side div {
            margin-top: 10px;
            margin-bottom: 10px;
        }

        .da_button {
            background-color: #5cb5c9;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin-top: 10px;
            width: auto;
            min-width: 120px;
            font-size: 14px;
        }

        .da_button:hover {
            background-color: #4ca7bb;
        }

        .message {
            margin-top: 10px;
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

        ul {
            list-style-type: disc;
            padding-left: 20px;
        }

        li {
            margin-bottom: 10px;
        }

        li div {
            display: inline-block;
        }

        li form {
            display: inline-block;
            margin-left: 10px;
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
            <form action="Anewproduct" method="POST">
                <input type="hidden" name="action" value="addItem">
                <input type="text" name="item_code" placeholder="Item Code" required>
                <input type="text" name="item_name" placeholder="Item Name" required>
                <div>
                    <input type="radio" id="dog" name="pet_category" value="Dog" required>
                    <label for="dog">Dog</label>
                    <input type="radio" id="cat" name="pet_category" value="Cat">
                    <label for="cat">Cat</label>
                    <input type="radio" id="dog-cat" name="pet_category" value="Both">
                    <label for="dog-cat">Dog & Cat</label>
                </div>
                <select name="item_category" required>
                    <option value="CODE1">CODE 1</option>
                    <option value="CODE2">CODE 2</option>
                    <option value="CODE3">CODE 3</option>
                    <option value="CODE4">CODE 4</option>
                    <option value="CODE5">CODE 5</option>
                    <option value="CODE6">CODE 6</option>
                    <option value="CODE7">CODE 7</option>
                    </select>
                <input type="number" name="total_quantity" placeholder="Total Quantity" min="0" max="99999" required>
                <button type="submit" class="da_button">Add to List</button>
            </form>

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
                        <li style="display: flex; justify-content: space-between; align-items: center;">
                            <div>
                                <strong>Item Code:</strong> ${item.itemCode},
                                <strong>Item Name:</strong> ${item.itemName},
                                <strong>Category:</strong> ${item.itemCategory},
                                <strong>Pet Category:</strong> ${item.petCategory},
                                <strong>Quantity:</strong> ${item.totalQuantity}
                            </div>
                            <form action="Anewproduct" method="POST" style="margin-left: 10px;">
                                <input type="hidden" name="action" value="removeItem">
                                <input type="hidden" name="item_code" value="${item.itemCode}">
                                <button type="submit" class="da_button" style="background-color: #e74c3c;">Remove</button>
                            </form>
                        </li>
                    </c:forEach>
                </ul>
                <form action="Anewproduct" method="POST">
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