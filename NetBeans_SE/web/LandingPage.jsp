<!DOCTYPE html>
<%@ page session="true" %>
<%
    // Prevent browser caching
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "0");

    // If the user comes back using the Back button, set LoggedIn to false
    session.setAttribute("LoggedIn", false);
%>

<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MV88 Ventures Inventory System</title>
    <link rel="stylesheet" href="Styles.css">
</head>

<body>
    <div class="container">
        <div class="title">MV88 Ventures <br> Inventory System</div>
        <div class="login-box">
            <form action="LoginServlet" method="post">
                <div class="input-container">
                    <label>Username</label>
                    <div class="input-wrapper">
                        <input type="text" name="username" placeholder="Username" required>
                    </div>
                    <label>Password</label>
                    <div class="input-wrapper">
                        <input type="password" name="password" placeholder="*****" required>
                    </div>
                </div>
                <input class="button" type="submit" value="LOGIN">
                <div class="forgot-password">
                    <a href="#">Forgot Password?</a>
                </div>
            </form>
        </div>
    </div>
</body>

</html>