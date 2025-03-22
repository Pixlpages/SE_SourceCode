<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MV88 Ventures Inventory System</title>
    <style>
        
        @media screen and (max-width: 600px) {
            .container {
                width: 100%;
            }
        }
        html, body {
            font-family: Arial, sans-serif;
            height: 100%;
            background-color: #f5f5f5;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column; /* Stack header, content, and footer vertically */
        }
        
        .main-content {
            flex: 1; /* Ensures this takes up all remaining space */
        }
        
        header {
            background-color: #4a90e2;
            color: white;
            padding: 20px;
            padding-right: 50px;
            text-align: left;
            font-size: 24px;
        }
        
        footer {
            width: 100%;
            background: #141414;
            border: 1px solid #e50914;
            box-sizing: border-box;
            text-align: center;
            color: white;
            padding: 10px 0;
            margin-top: auto; /* Ensures footer is pushed to the bottom */
        }
        
        .secondary-header {
            background-color: lightgray; /* Adjust if necessary */
            color: white;
            padding: 5px;
            font-size: 18px;
            border-bottom: 1px solid #ccc; /* Optional for visual separation */
            display: flex; /* Use flexbox for alignment */
            align-items: center; /* Vertically center items */
            justify-content: flex-start; /* Align items to the left */
        }

        .back-button {
            color: black; /* Change text/icon color if needed */
            text-decoration: none; /* Remove underline from link */
            font-size: 16px;
            padding-left: 10px; /* Add some left spacing */
            display: flex; /* Ensure icon and text align together */
            align-items: center; /* Vertically align icon and text */
        }
        

        .back-button:hover {
            background-color: #357abd; /* Optional: Add a hover effect */
        }

        .left-side {
            padding: 20px;
            border-radius: 5px;
            width: 45%;
        }
        
        .right-side {
            margin-top: 80px;
            padding: 20px;
            border-radius: 5px;
            width: 45%;
        }
        
        .search-items-container {
            background-color: #f0f0f0; /* Matches the items list background */
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }

        .search-bar {
            display: flex;
            align-items: center;
            background-color: #e0e0e0;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 10px; /* Reduced margin to make it visually closer to the items */
        }

        .search-bar input {
            border: none;
            background: none;
            flex-grow: 1;
            padding: 5px;
            font-size: 16px;
        }
        .search-bar button {
            background-color: #4a90e2;
            color: white;
            border: none;
            padding: 10px;
            border-radius: 5px;
            cursor: pointer;
        }
        
        .distribution-list {
            background-color: #f0f0f0;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        
        .distribution-list h3 {
            margin-top: 0;
        }
        
        .items-list {
            background-color: #f0f0f0;
            padding: 10px;
            border-radius: 5px;
            margin-top: 10px;
            max-height: 200px; /* Limit the height */
            overflow-y: auto; /* Enable vertical scrolling */
        }

        .item {
            display: flex;
            align-items: center;
            padding: 10px;
            border-bottom: 1px solid #ccc;
        }

        .item:last-child {
        border-bottom: none;
        }

        .item-icon {
            width: 40px;
            height: 40px;
            background-color: #4a90e2;
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            border-radius: 50%;
            font-size: 18px;
            font-weight: bold;
            margin-right: 10px;
        }

        .item-details h3 {
            margin: 0;
            font-size: 16px;
        }

        .item-details p {
            margin: 5px 0 0;
            font-size: 14px;
            color: #666;
        }

        .items-list::-webkit-scrollbar {
            width: 8px;
        }

        .items-list::-webkit-scrollbar-thumb {
            background-color: #4a90e2;
            border-radius: 4px;
        }

        .items-list::-webkit-scrollbar-track {
            background-color: #e0e0e0;
        }

        .amount-location h5 {
            margin-bottom: 10px; /* Adjust the value as needed */
        }

        .amount-location input {
            margin-right: 10px; /* Adds space between input field and button */
            padding: 5px; /* Optional: adds some padding inside the field for better visual appeal */
        }

        .amount-location select {
            display: flex;
            flex-direction: column; /* Aligns elements vertically */
            align-items: flex-start; /* Keeps the items aligned to the left */
        }

        /* RIGHT SIDE CSS*/

        .distribution-list h3 {
            padding: 10px;
            margin-bottom: 10px;
            font-size: 20px;
            color: #333;
        }

        .distribution-list {
            background-color: #f0f0f0;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }

        .items {
            max-height: 200px; /* Limit the height for scrolling */
            overflow-y: auto; /* Enable vertical scrolling */
        }

        .item {
            display: flex;
            align-items: center;
            padding: 10px 0;
            border-bottom: 1px solid #ccc;
        }

        .item:last-child {
            border-bottom: none;
        }

        .item-icon {
            width: 40px;
            height: 40px;
            background-color: #4a90e2;
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            border-radius: 50%;
            font-size: 18px;
            font-weight: bold;
            margin-right: 10px;
        }

        .item-details {
            flex: 1;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .item-quantity {
            font-weight: bold;
            color: #555;
        }

        .confirm-add {
            display: flex;
            align-items: center;
            margin-bottom: 10px;
        }

        .confirm-add input {
            margin-right: 10px;
        }

        .add-button {
            background-color: #4a90e2;
            color: white;
            border: none;
            padding: 10px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            width: 100%;
        }

        .add-button:hover {
            background-color: #357abd;
        }

        /* Optional scrollbar customization */
        .items::-webkit-scrollbar {
            width: 8px;
        }

        .items::-webkit-scrollbar-thumb {
            background-color: #4a90e2;
            border-radius: 4px;
        }

        .items::-webkit-scrollbar-track {
            background-color: #e0e0e0;
        }
    </style>
</head>
<body>
    <header>
        MV88 Ventures Inventory System
    </header>
    <div class="secondary-header">
        <a href="javascript:history.back()" class="back-button">
            ? Back
        </a>
    </div>
    <div class="container">
        <br>
        <br>
        <div class="left-side">
            <h1>
                Increase Item Quantity
            </h1>
        <div class="search-items-container">
            <div class="search-bar">
                <input type="text" placeholder="Search Item Name/Code">
                <button>Search</button>
            </div>
            <div class="items-list">
                <div class="item">
                    <div class="item-icon">
                        <span>A</span>
                    </div>
                    <div class="item-details">
                        <h3>Item Code A</h3>
                        <p>Supporting line text lorem ipsum dolor sit</p>
                    </div>
                </div>
                <div class="item">
                    <div class="item-icon">
                        <span>B</span>
                    </div>
                    <div class="item-details">
                        <h3>Item Code B</h3>
                        <p>Supporting line text lorem ipsum dolor sit</p>
                    </div>
                </div>
                <div class="item">
                    <div class="item-icon">
                        <span>C</span>
                    </div>
                    <div class="item-details">
                        <h3>Item Code C</h3>
                        <p>Supporting line text lorem ipsum dolor sit</p>
                    </div>
                </div>
                <div class="item">
                    <div class="item-icon">
                        <span>D</span>
                    </div>
                    <div class="item-details">
                        <h3>Item Code D</h3>
                        <p>Supporting line text lorem ipsum dolor sit</p>
                    </div>
                </div>
                <div class="item">
                    <div class="item-icon">
                        <span>E</span>
                    </div>
                    <div class="item-details">
                        <h3>Item Code E</h3>
                        <p>Supporting line text lorem ipsum dolor sit</p>
                    </div>
                </div>
            </div>
        </div>
        <div class="amount-location">
            <h5>Amount to Add</h5>
            <input type="number" placeholder="0-99999">
            <button>Add to List</button>
        </div>
        </div>
        <div class="right-side">
            <div class="distribution-list">
                <h3>List of Items to Add</h3>
                <div class="items">
                    <div class="item">
                        <div class="item-icon">A</div>
                        <div class="item-details">
                            <span>List item A</span>
                            <span class="item-quantity">100+</span>
                        </div>
                    </div>
                    <div class="item">
                        <div class="item-icon">B</div>
                        <div class="item-details">
                            <span>List item B</span>
                            <span class="item-quantity">100+</span>
                        </div>
                    </div>
                    <div class="item">
                        <div class="item-icon">C</div>
                        <div class="item-details">
                            <span>List item C</span>
                            <span class="item-quantity">100+</span>
                        </div>
                    </div>
                    <div class="item">
                        <div class="item-icon">D</div>
                        <div class="item-details">
                            <span>List item D</span>
                            <span class="item-quantity">100+</span>
                        </div>
                    </div>
                    <div class="item">
                        <div class="item-icon">E</div>
                        <div class="item-details">
                            <span>List item E</span>
                            <span class="item-quantity">100+</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="confirm-add">
                <input type="checkbox" id="confirm-items" checked>
                <label for="confirm-items">Confirm Items</label>
            </div>
            <button class="add-button">Add Items</button>
        </div>
        <br>
        <br>
    </div>
    <footer> </footer>
</body>
</html>