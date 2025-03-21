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
            background-color: #f0f0f0;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }
        .header, .footer {
            background-color: #4da6ff;
            color: white;
            padding: 20px;
            text-align: left;
            font-size: 24px;
        }
        .footer {
            background-color: #D3D3D3;
            color: white;
        }
        .container {
            padding: 20px;
            display: flex;
            flex-direction: column;
            flex: 1;
        }
        .welcome, .question {
            font-size: 20px;
            text-align: left;
            margin-bottom: 20px;
        }
        .content-wrapper {/*comment*/
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        .sections {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 150px;
            padding-top: 0px; /* Adjust this value to move the sections up or down */
        }
        .section {
            background-color: #ffffe0;
            border: 5px solid #ffd700;
            padding: 20px;
            width: 200px;
            text-align: left;
        }
        .section h3 {
            margin-top: 0;
        }
        .logout {
            position: absolute;
            top: 20px;
            right: 20px;
        }
        .datetime {
            position: fixed;
            top: 80px;
            right: 20px;
            font-size: 12px;
        }
        @media (max-width: 768px) {
            .sections {
                flex-direction: column;
                align-items: flex-start;
            }
            .section {
                width: 100%;
                max-width: 300px;
            }
        }
    </style>
      
</head>
<body>
    <div class="header">
        MV88 Ventures Inventory System
    </div>
    <div class="container">
        <div class="content-wrapper">
            <div class="welcome">
                Welcome <span style="color: gray;">?</span> Tagaytay Staff
            </div>
            <div class="question">
                What would you like to access?
            </div>
        </div>
        <div class="sections">
            <div class="section">
                <h3>Receive Items</h3>
                <ul>
                    <li>Recent Shipments</li>
                </ul>
            </div>
            <div class="section">
                <h3>Distribute Items</h3>
                <ul>
                    <li>Search Item Name/Code</li>
                </ul>
            </div>
            <div class="section">
                <h3>Reports</h3>
                <ul>
                    <li>View Items</li>
                    <li>Manage Defective Items</li>
                </ul>
            </div>
        </div>
    </div>
    <div class="logout">
        (Logout Button)
    </div>
    <div class="datetime">
        YYYY-MM-DD<br>HH:MM:SS
    </div>
    <div class="footer">
        <!-- footer -->
    </div>
</body>
</html>
