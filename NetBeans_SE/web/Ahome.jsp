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
    <link rel="stylesheet" href="styles.css">
    <style>
        /* General Styles */
        body {
            font-family: Arial, sans-serif;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            margin: 0;
            overflow: hidden; /* Prevent scrolling */
        }

        /* Header Styles */
        .header {
    background-color: #5cb5c9;
    color: white;
    padding: 20px;
    display: flex;
    justify-content: center; /* Centers everything in the header */
    align-items: center;
    width: 100%;
    box-sizing: border-box;
}


        .header-left {
    display: flex;
    align-items: center;
    flex: 1; /* Allows it to take up available space */
    justify-content: center; /* Centers content horizontally */
    text-align: center;
}


        .header-right {
            display: flex;
            align-items: center;
        }

        .logout-button {
            padding: 8px 12px;
            background-color: #e0b354; /* Use button color */
            border: none;
            color: black;
            border-radius: 4px;
            cursor: pointer;
            margin-right: 15px;
        }

        .datetime {
            font-size: small;
            text-align: right;
            margin-top: 10px;
        }

        /* Main Content Styles */
        .main-content {
            background-color: #f5f5f5; /* Dirty white background */
            padding: 20px;
            width: 1920px; /* Fixed width */
            height: 1080px; /* Fixed height */
            margin: 0 auto;
            display: flex;
            flex-direction: column;
            align-items: center;
            box-sizing: border-box;
            flex: 1;
        }

        .welcome-admin {
            font-size: 32px;
            margin-bottom: 20px;
            align-self: flex-start;
            display: flex;
            align-items: center;
            margin-top: 20px; /* Add margin to push it down */
        }

        .admin-circle {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            background-color: gray;
            margin-left: 10px;
            margin-right: 10px;
        }

        .access-title {
            font-size: 24px;
            margin-bottom: 20px;
            margin-top: 60px; /* Add more margin to push it down */
        }

        .access-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            width: 100%;
        }

        .card {
            background-color: #FFFBDD; /* Fill color */
            padding: 20px;
            text-align: left;
            border-radius: 8px; /* Rounded corners */
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); /* Box shadow for modern look */
            border: 2px solid #FFD085; /* Stroke color */
            transition: transform 0.3s ease; /* Smooth transition for hover effect */
        }

        .card:hover {
            transform: translateY(-10px); /* Lift card on hover */
        }

        .card h3 {
            margin-top: 0;
            font-size: 20px;
            color: #333;
        }

        .card ul {
            list-style-type: none;
            padding: 0;
        }

        .card ul li {
            margin-bottom: 10px;
        }

        .card ul li a {
            text-decoration: none;
            color: #5cb5c9;
            transition: color 0.3s ease;
        }

        .card ul li a:hover {
            color: #0056b3;
        }

        .card ul li::before {
            content: "\25BA \0020"; /* Triangle bullet */
            color: #5cb5c9;
        }

        .header-right-container {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
        }
        
        .content-right {
            align-self: flex-end;
            text-align: right;
            margin-top: -20px; /* Adjust margin to position it higher */
        }

        /* Footer Styles */
        .footer {
            width: 1920px;
            height: 40px;
            background-color: #D9D9D9; /* Fill color */
            opacity: 1; /* 100% opacity */
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            justify-content: center;
            align-items: center;
            box-sizing: border-box;
        }

        /* Media Queries for Responsiveness */
        @media (max-width: 1920px) {
            .main-content {
                width: 100%;
                height: auto;
            }
        }

        @media (max-height: 1080px) {
            .main-content {
                height: 100%;
            }
        }
    </style>
    <script>
        // Real-time date and time script
        function updateDateTime() {
            const now = new Date();
            document.getElementById("current-date").textContent = now.toISOString().split("T")[0];
            document.getElementById("current-time").textContent = now.toLocaleTimeString();
        }

        setInterval(updateDateTime, 1000);
        updateDateTime();
    </script>
</head>
<body>
    <!-- Header Section -->
    <header class="header" role="navigation">
        <div class="header-left">
            <h1>MV88 Ventures Inventory System</h1>
        </div>
        <div class="header-right">
            <form action="LogoutServlet" method="post">
                <input class="logout-button" type="submit" value="LOGOUT">
            </form>
        </div>
    </header>

    <!-- Main Content Section -->
    <main class="main-content">
        <div class="content-right">
            <div class="datetime">
                <span id="current-date">YYYY-MM-DD</span>
                <br />
                <span id="current-time">HH:MM:SS</span>
            </div>
        </div>
        <div class="welcome-admin">
            <span>Welcome</span>
            <div class="admin-circle"></div>
            <span>ADMIN</span>
        </div>
        <h2 class="access-title">What would you like to access?</h2>
        <div class="access-cards">
            <!-- Add Items Card -->
            <section class="card" aria-labelledby="add-items-title">
                <h3 id="add-items-title">Add Items</h3>
                <ul>
                    <li><a href="AdminActionsServlet?action=increasequantity">Add Items Quantity</a></li>
                    <li><a href="AdminActionsServlet?action=newproduct">Include to Inventory</a></li>
                    <li><a href="AdminActionsServlet?action=edit">Edit Item Information</a></li>
                </ul>
            </section>

            <!-- Distribute Items Card -->
            <section class="card" aria-labelledby="deliver-items-title">
                <h3 id="deliver-items-title">Distribute Items</h3>
                <ul>
                    <li><a href="AdminActionsServlet?action=distribute">Search Item Name/Code</a></li>
                </ul>
            </section>

            <!-- Reports Card -->
            <section class="card" aria-labelledby="reports-title">
                <h3 id="reports-title">Reports</h3>
                <ul>
                    <li><a href="AdminActionsServlet?action=view">View Items</a></li>
                    <!-- Backend: Implement view items report functionality here -->
                    <li><a href="AdminActionsServlet?action=managedefective">Manage Defective Items</a></li>
                </ul>
            </section>
        </div>
    </main>

    <!-- Footer Section -->
    <footer class="footer">
    </footer>
</body>
</html>