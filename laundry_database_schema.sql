-- Executive Laundry Verdant Database Schema
-- This SQL script creates all necessary tables for the laundry service management system

-- Create database
CREATE DATABASE ExecutiveLaundryVerdant;
GO

USE ExecutiveLaundryVerdant;
GO

-- Users table (customers)
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL, -- Store hashed passwords in production
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Phone NVARCHAR(20),
    FullName NVARCHAR(100) NOT NULL,
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    LastLoginDate DATETIME2,
    IsActive BIT DEFAULT 1
);

-- Services table (available laundry services)
CREATE TABLE Services (
    ServiceID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceName NVARCHAR(50) UNIQUE NOT NULL,
    Description NVARCHAR(255),
    BasePrice DECIMAL(10,2) NOT NULL,
    EstimatedDurationHours INT, -- Estimated completion time
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME2 DEFAULT GETDATE()
);

-- Service Requests/Orders table
CREATE TABLE ServiceRequests (
    RequestID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    ServiceID INT FOREIGN KEY REFERENCES Services(ServiceID),
    RequestDate DATETIME2 DEFAULT GETDATE(),
    ScheduledPickupDate DATETIME2,
    ScheduledDeliveryDate DATETIME2,
    ActualPickupDate DATETIME2,
    ActualDeliveryDate DATETIME2,
    Status NVARCHAR(20) DEFAULT 'Pending', -- Pending, In Progress, Ready for Pickup, Completed, Cancelled
    TotalAmount DECIMAL(10,2) DEFAULT 0,
    SpecialInstructions NVARCHAR(500),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    ModifiedDate DATETIME2 DEFAULT GETDATE()
);

-- Clothing Items table (items within each service request)
CREATE TABLE ClothingItems (
    ItemID INT IDENTITY(1,1) PRIMARY KEY,
    RequestID INT FOREIGN KEY REFERENCES ServiceRequests(RequestID) ON DELETE CASCADE,
    ItemName NVARCHAR(100) NOT NULL,
    Color NVARCHAR(30),
    Quantity INT DEFAULT 1,
    ItemDescription NVARCHAR(255),
    CreatedDate DATETIME2 DEFAULT GETDATE()
);

-- Service Request Status History (audit trail)
CREATE TABLE ServiceRequestHistory (
    HistoryID INT IDENTITY(1,1) PRIMARY KEY,
    RequestID INT FOREIGN KEY REFERENCES ServiceRequests(RequestID),
    OldStatus NVARCHAR(20),
    NewStatus NVARCHAR(20) NOT NULL,
    ChangedBy NVARCHAR(100), -- Could be user or staff
    ChangeDate DATETIME2 DEFAULT GETDATE(),
    Notes NVARCHAR(500)
);

-- Reports table (for storing generated reports)
CREATE TABLE Reports (
    ReportID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    ReportType NVARCHAR(50) NOT NULL, -- Monthly Usage, Spending Summary, Service History, Environmental Impact
    ReportPeriodStart DATE,
    ReportPeriodEnd DATE,
    GeneratedDate DATETIME2 DEFAULT GETDATE(),
    ReportData NVARCHAR(MAX), -- JSON or XML data for the report
    FilePath NVARCHAR(255) -- Path to generated report file if saved
);

-- User Sessions table (for tracking login sessions)
CREATE TABLE UserSessions (
    SessionID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    LoginDate DATETIME2 DEFAULT GETDATE(),
    LogoutDate DATETIME2,
    IPAddress NVARCHAR(45),
    UserAgent NVARCHAR(500)
);

-- Settings table (for application configuration)
CREATE TABLE Settings (
    SettingID INT IDENTITY(1,1) PRIMARY KEY,
    SettingKey NVARCHAR(100) UNIQUE NOT NULL,
    SettingValue NVARCHAR(MAX),
    Description NVARCHAR(255),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    ModifiedDate DATETIME2 DEFAULT GETDATE()
);

-- Insert default services
INSERT INTO Services (ServiceName, Description, BasePrice, EstimatedDurationHours) VALUES
('Wash & Fold', 'Complete washing and folding service for regular clothes', 150.00, 24),
('Dry Cleaning', 'Professional dry cleaning for delicate fabrics and formal wear', 220.00, 48),
('Ironing', 'Professional ironing service for wrinkle-free clothes', 100.00, 12);

-- Insert default settings
INSERT INTO Settings (SettingKey, SettingValue, Description) VALUES
('CompanyName', 'Executive Laundry Verdant', 'Company name displayed throughout the application'),
('DefaultCurrency', 'PHP', 'Default currency symbol'),
('BusinessHoursStart', '08:00', 'Business hours start time'),
('BusinessHoursEnd', '18:00', 'Business hours end time'),
('MaxItemsPerOrder', '50', 'Maximum number of clothing items allowed per order');

-- Create indexes for better performance
CREATE INDEX IX_ServiceRequests_UserID ON ServiceRequests(UserID);
CREATE INDEX IX_ServiceRequests_Status ON ServiceRequests(Status);
CREATE INDEX IX_ServiceRequests_RequestDate ON ServiceRequests(RequestDate);
CREATE INDEX IX_ClothingItems_RequestID ON ClothingItems(RequestID);
CREATE INDEX IX_ServiceRequestHistory_RequestID ON ServiceRequestHistory(RequestID);
CREATE INDEX IX_Reports_UserID ON Reports(UserID);
CREATE INDEX IX_Reports_ReportType ON Reports(ReportType);
CREATE INDEX IX_UserSessions_UserID ON UserSessions(UserID);

-- Create a view for user dashboard summary
CREATE VIEW vw_UserDashboard AS
SELECT
    u.UserID,
    u.FullName,
    u.Email,
    COUNT(sr.RequestID) as TotalOrders,
    SUM(CASE WHEN sr.Status = 'Completed' THEN 1 ELSE 0 END) as CompletedOrders,
    SUM(CASE WHEN sr.Status IN ('Pending', 'In Progress') THEN 1 ELSE 0 END) as ActiveOrders,
    SUM(sr.TotalAmount) as TotalSpent,
    MAX(sr.RequestDate) as LastOrderDate
FROM Users u
LEFT JOIN ServiceRequests sr ON u.UserID = sr.UserID
GROUP BY u.UserID, u.FullName, u.Email;

-- Create a view for monthly usage statistics
CREATE VIEW vw_MonthlyUsage AS
SELECT
    YEAR(RequestDate) as Year,
    MONTH(RequestDate) as Month,
    COUNT(*) as TotalOrders,
    SUM(TotalAmount) as TotalRevenue,
    COUNT(DISTINCT UserID) as UniqueCustomers
FROM ServiceRequests
WHERE Status = 'Completed'
GROUP BY YEAR(RequestDate), MONTH(RequestDate);

-- Create a stored procedure for user authentication
CREATE PROCEDURE sp_AuthenticateUser
    @Username NVARCHAR(50),
    @Password NVARCHAR(255)
AS
BEGIN
    SELECT UserID, Username, FullName, Email, IsActive
    FROM Users
    WHERE Username = @Username
    AND PasswordHash = @Password -- In production, use proper password hashing/verification
    AND IsActive = 1;
END;
GO

-- Create a stored procedure for creating a new service request
CREATE PROCEDURE sp_CreateServiceRequest
    @UserID INT,
    @ServiceID INT,
    @ScheduledPickupDate DATETIME2,
    @ScheduledDeliveryDate DATETIME2,
    @SpecialInstructions NVARCHAR(500) = NULL
AS
BEGIN
    DECLARE @BasePrice DECIMAL(10,2);
    DECLARE @EstimatedDuration INT;

    SELECT @BasePrice = BasePrice, @EstimatedDuration = EstimatedDurationHours
    FROM Services
    WHERE ServiceID = @ServiceID;

    INSERT INTO ServiceRequests (UserID, ServiceID, ScheduledPickupDate, ScheduledDeliveryDate, SpecialInstructions, TotalAmount)
    VALUES (@UserID, @ServiceID, @ScheduledPickupDate, @ScheduledDeliveryDate, @SpecialInstructions, @BasePrice);

    DECLARE @RequestID INT = SCOPE_IDENTITY();

    -- Add initial status to history
    INSERT INTO ServiceRequestHistory (RequestID, NewStatus, ChangedBy, Notes)
    VALUES (@RequestID, 'Pending', 'System', 'Service request created');

    SELECT @RequestID as NewRequestID;
END;
GO

-- Create a stored procedure for generating monthly reports
CREATE PROCEDURE sp_GenerateMonthlyReport
    @UserID INT,
    @Year INT,
    @Month INT
AS
BEGIN
    DECLARE @StartDate DATE = DATEFROMPARTS(@Year, @Month, 1);
    DECLARE @EndDate DATE = EOMONTH(@StartDate);

    INSERT INTO Reports (UserID, ReportType, ReportPeriodStart, ReportPeriodEnd, ReportData)
    SELECT
        @UserID,
        'Monthly Usage',
        @StartDate,
        @EndDate,
        (SELECT
            COUNT(*) as TotalOrders,
            SUM(TotalAmount) as TotalSpent,
            AVG(TotalAmount) as AverageOrderValue,
            MIN(RequestDate) as FirstOrderDate,
            MAX(RequestDate) as LastOrderDate
        FROM ServiceRequests
        WHERE UserID = @UserID
        AND RequestDate >= @StartDate
        AND RequestDate <= @EndDate
        AND Status = 'Completed'
        FOR JSON PATH) as ReportData;

    SELECT SCOPE_IDENTITY() as ReportID;
END;
GO

-- Sample data for testing
INSERT INTO Users (Username, PasswordHash, Email, Phone, FullName) VALUES
('johndoe', 'hashedpassword123', 'john.doe@email.com', '+1234567890', 'John Doe'),
('janesmith', 'hashedpassword456', 'jane.smith@email.com', '+0987654321', 'Jane Smith');

-- Sample service requests
EXEC sp_CreateServiceRequest 1, 1, '2025-04-15 10:00:00', '2025-04-16 16:00:00', 'Handle with care';
EXEC sp_CreateServiceRequest 1, 2, '2025-04-10 14:00:00', '2025-04-12 16:00:00', 'Dry clean only';

-- Add clothing items to the first request
INSERT INTO ClothingItems (RequestID, ItemName, Color, Quantity) VALUES
(1, 'Shirt', 'White', 3),
(1, 'Pants', 'Black', 2),
(2, 'Suit', 'Navy Blue', 1),
(2, 'Dress', 'Red', 1);

PRINT 'Executive Laundry Verdant database schema created successfully!';
PRINT 'Database includes: Users, Services, ServiceRequests, ClothingItems, ServiceRequestHistory, Reports, UserSessions, Settings';
PRINT 'Views created: vw_UserDashboard, vw_MonthlyUsage';
PRINT 'Stored procedures created: sp_AuthenticateUser, sp_CreateServiceRequest, sp_GenerateMonthlyReport';
