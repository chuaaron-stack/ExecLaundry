CREATE DATABASE IF NOT EXISTS executivelaundryverdant;
USE executivelaundryverdant;

CREATE TABLE IF NOT EXISTS Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(50) UNIQUE NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    PasswordHash VARCHAR(255) NOT NULL,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    LastLoginDate TIMESTAMP NULL
);

CREATE TABLE IF NOT EXISTS Services (
    ServiceID INT AUTO_INCREMENT PRIMARY KEY,
    ServiceName VARCHAR(100) NOT NULL,
    Description TEXT,
    Price DECIMAL(10,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS ServiceRequests (
    RequestID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    ServiceID INT NOT NULL,
    Status ENUM('Pending', 'In Progress', 'Completed', 'Cancelled') DEFAULT 'Pending',
    TotalAmount DECIMAL(10,2) DEFAULT 0,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Notes TEXT,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (ServiceID) REFERENCES Services(ServiceID)
);

CREATE TABLE IF NOT EXISTS ClothingItems (
    ItemID INT AUTO_INCREMENT PRIMARY KEY,
    RequestID INT NOT NULL,
    ItemName VARCHAR(100) NOT NULL,
    Color VARCHAR(50),
    Quantity INT DEFAULT 1,
    ItemDescription TEXT,
    FOREIGN KEY (RequestID) REFERENCES ServiceRequests(RequestID)
);

INSERT INTO Users (Username, FullName, Email, PasswordHash) VALUES ('admin', 'Admin User', 'admin@example.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi')
ON DUPLICATE KEY UPDATE Username=Username;

INSERT INTO Services (ServiceName, Description, Price) VALUES 
('Wash and Fold', 'Basic laundry service', 10.00),
('Dry Cleaning', 'Professional dry cleaning', 20.00)
ON DUPLICATE KEY UPDATE ServiceName=ServiceName;
