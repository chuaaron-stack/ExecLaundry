<?php
// Database configuration for SQL Server
$serverName = "localhost";
$connectionInfo = array(
    "Database" => "ExecutiveLaundryVerdant",
    "CharacterSet" => "UTF-8"
);

// Connect to SQL Server
$conn = sqlsrv_connect($serverName, $connectionInfo);

if ($conn === false) {
    die("Database connection failed: " . print_r(sqlsrv_errors(), true));
}

// Note: Ensure sqlsrv and pdo_sqlsrv extensions are enabled in php.ini
?>
