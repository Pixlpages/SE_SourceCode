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

<style> 
    .modal {
        display: none;
        position: fixed;
        left: 50%;
        top: 50%;
        transform: translate(-50%, -50%);
        background: white;
        padding: 20px;
        box-shadow: 5px 5px 15px rgba(0, 0, 0, 0.2);
        border-radius: 8px;
        width: 330px;
        text-align: center;
    }

    .modal-content {
        display: grid;
        flex-direction: column;
        align-items: center;
        gap: 15px;
    }

    .modal-content input {
        width: 95%;
        max-width: 280px;
        padding: 8px;
        border: 1px solid #ccc;
        border-radius: 4px;
        display: block;
        margin: 0 auto;
    }

    .modal-content button {
        width: 95%;
        max-width: 300px;
        text-align: center;
        padding: 8px;
        background: #e0b354;
        border: none;
        color: black;
        font-size: 14px;
        font-weight: bold;
        border-radius: 4px;
        cursor: pointer;
        display: block;
        margin: 0 auto;
    }

    .toast-notification {
        position: fixed;
        bottom: 20px;
        right: 20px;
        background: rgba(0, 0, 0, 0.8);
        color: white;
        padding: 10px 15px;
        border-radius: 6px;
        font-size: 14px;
        opacity: 1;
        transition: opacity 0.5s ease-out;
    }

</style>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const forgotPasswordLink = document.querySelector(".forgot-password a");
        if (forgotPasswordLink) {
            forgotPasswordLink.addEventListener("click", function(event) {
                event.preventDefault();
                openModal();
            });
        }
    });

    function openModal() {
        document.getElementById("security-answer").value = ""; // Clears text field when modal opens
        document.getElementById("forgot-password-modal").style.display = "block";
    }

    function closeModal() {
        document.getElementById("forgot-password-modal").style.display = "none";
    }

    function verifyUsername() {
        const usernameField = document.getElementById("security-answer");
        const username = usernameField.value.trim();

        if (username) {
            showNotification("Please wait for admin to retrieve your password.");
            closeModal(); // Closes modal after submission
        } else {
            showNotification("Please enter a valid username.");
        }
    }

    function showNotification(message) {
        const notification = document.createElement("div");
        notification.className = "toast-notification";
        notification.textContent = message;
        document.body.appendChild(notification);

        setTimeout(() => {
            notification.style.opacity = "0";
            setTimeout(() => {
                notification.remove();
            }, 500);
        }, 3000);
    }
</script>

<body>
    <div class="container">
        <div class="title">MV88 Ventures <br> Inventory System</div>
        <div class="login-box">
            <form action="LoginServlet" method="post">
                <div class="input-container">
                    <label>Username</label>
                    <div class="input-wrapper">
                        <input type="text" name="username" placeholder="Value" required>
                    </div>
                    <label>Password</label>
                    <div class="input-wrapper">
                        <input type="password" name="password" placeholder="Value" required>
                    </div>
                </div>
                <input class="button" type="submit" value="LOGIN">
                <div class="forgot-password">
                    <a href="#">Forgot Password?</a>
                </div>
            </form>
        </div>
    </div>
    <div id="forgot-password-modal" class="modal">
        <div class="modal-content">
            <h2>Forgot Password</h2>
            <p>Please Enter Username:</p>
            <input type="text" id="security-answer" placeholder="Username">
            <button onclick="verifyUsername()">Submit</button>
            <button onclick="closeModal()">Close</button>
        </div>
    </div>
</body>

</html>