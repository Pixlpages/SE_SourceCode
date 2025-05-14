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
            gap: 15px;
            align-items: center;
        }

        .modal-content input {
            width: 95%;
            max-width: 280px;
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            display: block;
            margin: 0 auto;
            box-sizing: border-box;
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

        body {
            margin: 0;
            font-family: Arial, sans-serif;
            display: flex;
            height: 100vh;
            justify-content: center;
            align-items: center;
            background: linear-gradient(to right, #4ca1af, #c4e0e5);
        }

        .container {
            display: grid;
            grid-template-columns: auto auto; /* Adjusts column sizes based on content */
            align-items: center;
            justify-content: center; /* Ensures the entire grid is centered */
            width: 100%;
            gap: 150px; /* Space between title and login box */
        }

        .title {
            font-size: 40px;
            font-weight: bold;
            color: white;
            text-align: center;
        }

        .login-box {
            background: white;
            padding: 20px;
            box-shadow: 5px 5px 15px rgba(0, 0, 0, 0.2);
            border-radius: 8px;
            width: 330px;
            height: auto;
            display: grid;
            gap: 15px;
            align-items: center;
        }

        .input-container {
            width: 100%;
            display: grid;
            gap: 10px;
        }

        .input-wrapper {
            display: flex;
            align-items: center;
            width: 100%;
            border: 1px solid #ccc;
            border-radius: 4px;
            background: white;
            padding: 5px;
            box-sizing: border-box;
            overflow: hidden; /* Ensures no overflow */
        }

        .input-wrapper input {
            flex: 1; /* Takes up remaining space inside the wrapper */
            border: none;
            outline: none;
            padding: 8px;
            box-sizing: border-box;
            min-width: 0; /* Prevents flex from causing an overflow */
        }

        .login-box .button {
            width: 100%;
            padding: 10px;
            background: #e0b354;
            border: none;
            color: black;
            font-weight: bold;
            border-radius: 4px;
            cursor: pointer;
            margin-top: 20px;
            margin-bottom: 20px;
        }

        .forgot-password {
            text-align: center;
            font-size: 14px;
        }

        .forgot-password a {
            text-decoration: none;
            cursor: pointer;
        }

        .forgot-password a:hover {
            text-decoration: underline;
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
                fetch('ForgotPassword', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded'
                        },
                        body: 'username=' + encodeURIComponent(username)
                    })
                    .then(response => response.text())
                    .then(data => {
                        showNotification(data);
                        closeModal(); // Closes modal after submission
                    })
                    .catch(error => {
                        showNotification("An error occurred. Please try again.");
                    });
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
</head>

<body>
    <div class="container">
        <div class="title">MV88 Ventures <br> Inventory System</div>
        <div class="login-box">
            <form action="LoginServlet" method="post">
                <div class="input-container">
                    <label for="username">Username</label>
                    <div class="input-wrapper">
                        <input type="text" id="username" name="username" placeholder="Username" required>
                    </div>
                    <label for="password">Password</label>
                    <div class="input-wrapper">
                        <input type="password" id="password" name="password" placeholder="*****" required>
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