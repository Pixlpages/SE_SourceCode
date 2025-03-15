-- Step 1: Create a new database
CREATE DATABASE simple_db;

-- Step 2: Use the newly created database
USE simple_db;

-- Step 3: Create a new table called 'users'
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL
);

-- Step 4: Insert some data into the 'users' table
INSERT INTO users (name, email) VALUES ('Alice', 'alice@example.com');
INSERT INTO users (name, email) VALUES ('Bob', 'bob@example.com');
INSERT INTO users (name, email) VALUES ('Charlie', 'charlie@example.com');

-- Step 5: Select and display all data from the 'users' table
SELECT * FROM users;