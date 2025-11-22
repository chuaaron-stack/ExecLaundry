<?php
session_start();
include 'config.php';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Executive Laundry Verdant</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        header {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            z-index: 10;
        }
        .sidebar {
            position: fixed;
            left: 0;
            top: 0;
            width: 160px;
            background: #232a34;
            padding: 20px;
            height: 100vh;
            overflow-y: auto;
            box-shadow: 2px 0 8px rgba(0,0,0,0.18);
            z-index: 5;
        }
        .sidebar ul {
            list-style: none;
            padding: 0;
        }
        .sidebar li {
            margin-bottom: 10px;
        }
        .sidebar a {
            color: #e0e6ed;
            text-decoration: none;
            display: block;
            padding: 10px;
            border-radius: 6px;
            transition: background 0.2s;
        }
        .sidebar a:hover {
            background: #2d3e50;
            color: #4caf50;
        }
        .container {
            margin-left: 180px;
            padding: 20px;
            padding-top: 0;
            text-align: center;
        }
        .services, .about, .contact {
            margin-bottom: 40px;
            text-align: left;
            max-width: 800px;
            margin-left: auto;
            margin-right: auto;
            padding: 20px;
            background: rgba(35, 42, 52, 0.85);
            border-radius: 12px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.18);
        }
        .services h2, .about h2, .contact h2 {
            color: #4caf50;
        }
        .services ul {
            list-style: none;
            padding: 0;
        }
        .services li {
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <header>
        <div class="header-content">
            <h1>Executive Laundry Verdant</h1>
        </div>
    </header>
    <div class="sidebar">
        <ul>
            <li><a href="login.php">Login</a></li>
            <li><a href="register.php">Register</a></li>
        </ul>
    </div>
    <div class="container">
        <h1>Welcome to Executive Laundry Verdant</h1>
        <p>Your trusted partner for dry cleaning and laundry services.</p>
        <section class="services">
            <h2>Our Services</h2>
            <p>We offer a wide range of laundry and dry cleaning services tailored to your needs.</p>
            <ul>
                <li>Dry Cleaning</li>
                <li>Laundry Services</li>
                <li>Clothing Alterations</li>
                <li>Pickup and Delivery</li>
            </ul>
        </section>
        <section class="about">
            <h2>About Us</h2>
            <p>Executive Laundry Verdant has been serving the community with quality and care for over 10 years. Our team is dedicated to providing the best service possible.</p>
            <p>We use eco-friendly products and state-of-the-art equipment to ensure your clothes are cleaned safely and effectively.</p>
        </section>
        <section class="contact">
            <h2>Contact Us</h2>
            <p>Phone: (123) 456-7890</p>
            <p>Email: info@executivelaundryverdant.com</p>
            <p>Address: 123 Main St, City, State 12345</p>
        </section>
    </div>
</body>
</html>
