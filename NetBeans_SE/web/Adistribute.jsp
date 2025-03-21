<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MV88 Ventures Inventory System</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 0;
        }
        header {
            background-color: #4a90e2;
            color: white;
            padding: 10px;
            text-align: center;
            font-size: 24px;
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
        .search-bar {
            display: flex;
            align-items: center;
            background-color: #e0e0e0;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
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
        .items-list, .distribution-list {
            background-color: #f0f0f0;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .items-list h3, .distribution-list h3 {
            margin-top: 0;
        }
        .item {
            display: flex;
            justify-content: space-between;
            padding: 10px;
            border-bottom: 1px solid #ccc;
        }
        .item:last-child {
            border-bottom: none;
        }
        .amount-location {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
        }
        .amount-location input, .amount-location select {
            margin-right: 10px;
            padding: 5px;
            font-size: 16px;
        }
        .confirm-distribute {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
        }
        .confirm-distribute input {
            margin-right: 10px;
        }
        .distribute-button {
            background-color: #4a90e2;
            color: white;
            border: none;
            padding: 10px;
            border-radius: 5px;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <header>
        MV88 Ventures Inventory System
    </header>
    <div class="container">
        <div class="left-side">
            <div class="search-bar">
                <input type="text" placeholder="Search Item Name/Code">
                <button>Search</button>
            </div>
            <div class="items-list">
                <h3>Items Code</h3>
                <div class="item">
                    <span>Supporting line text lorem ipsum dolor sit</span>
                </div>
                <div class="item">
                    <span>Supporting line text lorem ipsum dolor sit</span>
                </div>
                <div class="item">
                    <span>Supporting line text lorem ipsum dolor sit</span>
                </div>
            </div>
            <div class="amount-location">
                <input type="number" placeholder="0-99999">
                <select>
                    <option>Location 1</option>
                    <!-- Add more locations as needed -->
                </select>
                <button>Add to List</button>
            </div>
        </div>
        <div class="right-side">
            <div class="distribution-list">
                <h3>List of Items to Distribute</h3>
                <div class="item">
                    <span>List item</span>
                    <span>100+</span>
                </div>
                <div class="item">
                    <span>List item</span>
                    <span>100+</span>
                </div>
                <div class="item">
                    <span>List item</span>
                    <span>100+</span>
                </div>
            </div>
            <div class="confirm-distribute">
                <input type="checkbox" id="confirm-items-out">
                <label for="confirm-items-out">Confirm Items Out</label>
            </div>
            <button class="distribute-button">Distribute</button>
        </div>
    </div>
</body>
</html>
