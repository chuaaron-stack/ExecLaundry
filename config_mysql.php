<?php
// Database configuration for MySQL
$serverName = "localhost";
$username = "root";
$password = "Shadow3ckster";
$database = "ExecutiveLaundryVerdant";

// Connect to MySQL
$conn = new mysqli("localhost:3307", $username, $password, $database);

if ($conn->connect_error) {
    die("Database connection failed: " . $conn->connect_error);
}

// Set charset to UTF-8
$conn->set_charset("utf8");
?>
