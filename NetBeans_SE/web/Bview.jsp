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
            padding: 15px;
            background: #f5f5f5;
        }
        .reports {
            display: flex;
            gap: 20px;
            padding: 10px 0;
        }
        .reports div {
            display: flex;
            align-items: center;
            gap: 5px;
            cursor: pointer;
        }
        .report-view {
            border: 1px solid #ccc;
            padding: 10px;
            margin-top: 10px;
            background: white;
        }
        .toolbar {
            background: #444;
            color: white;
            padding: 8px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .toolbar button {
            background: none;
            border: none;
            color: white;
            cursor: pointer;
        }
        .report-content {
            height: 300px;
            background: #ddd;
            margin-top: 10px;
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
        <h2>View Reports</h2>
        <div class="reports">
            <div><span>&#128196;</span> Report</div>
            <div><span>&#128196;</span> Defective</div>
            <div><span>&#128196;</span> Critical Condition</div>
        </div>
        <h3>Branch Report</h3>
        <div class="report-view">
            <div class="toolbar">
                <button>&#11015;</button>
                <span>Page <input type="text" value="1" size="1"> of 3</span>
                <button>+</button>
                <button>-</button>
                <button>&#128393;</button>
                <button>&#128396;</button>
                <button>&#128438;</button>
            </div>
            <div class="report-content"></div>
        </div>
    </div>
</body>
</html>