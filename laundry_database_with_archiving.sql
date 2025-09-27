-- Executive Laundry Verdant Database Schema with Archiving
-- Enhanced version with archive functionality for past services

-- Create database
CREATE DATABASE ExecutiveLaundryVerdant;
GO

USE ExecutiveLaundryVerdant;
GO

-- Users table (customers)
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
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
    EstimatedDurationHours INT,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME2 DEFAULT GETDATE()
);

-- Active Service Requests/Orders table (current orders)
CREATE TABLE ServiceRequests (
    RequestID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    ServiceID INT FOREIGN KEY REFERENCES Services(ServiceID),
    RequestDate DATETIME2 DEFAULT GETDATE(),
    ScheduledPickupDate DATETIME2,
    ScheduledDeliveryDate DATETIME2,
    ActualPickupDate DATETIME2,
    ActualDeliveryDate DATETIME2,
    Status NVARCHAR(20) DEFAULT 'Pending',
    TotalAmount DECIMAL(10,2) DEFAULT 0,
    SpecialInstructions NVARCHAR(500),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    ModifiedDate DATETIME2 DEFAULT GETDATE()
);

-- Archived Service Requests (completed orders older than specified period)
CREATE TABLE ServiceRequestsArchive (
    ArchiveID INT IDENTITY(1,1) PRIMARY KEY,
    OriginalRequestID INT, -- Reference to original request ID
    UserID INT,
    ServiceID INT,
    RequestDate DATETIME2,
    ScheduledPickupDate DATETIME2,
    ScheduledDeliveryDate DATETIME2,
    ActualPickupDate DATETIME2,
    ActualDeliveryDate DATETIME2,
    Status NVARCHAR(20),
    TotalAmount DECIMAL(10,2),
    SpecialInstructions NVARCHAR(500),
    CreatedDate DATETIME2,
    ModifiedDate DATETIME2,
    ArchivedDate DATETIME2 DEFAULT GETDATE(),
    ArchiveReason NVARCHAR(100) DEFAULT 'Age-based archival'
);

-- Active Clothing Items table
CREATE TABLE ClothingItems (
    ItemID INT IDENTITY(1,1) PRIMARY KEY,
    RequestID INT FOREIGN KEY REFERENCES ServiceRequests(RequestID) ON DELETE CASCADE,
    ItemName NVARCHAR(100) NOT NULL,
    Color NVARCHAR(30),
    Quantity INT DEFAULT 1,
    ItemDescription NVARCHAR(255),
    CreatedDate DATETIME2 DEFAULT GETDATE()
);

-- Archived Clothing Items table
CREATE TABLE ClothingItemsArchive (
    ArchiveItemID INT IDENTITY(1,1) PRIMARY KEY,
    OriginalItemID INT,
    RequestID INT, -- Reference to archived request
    ItemName NVARCHAR(100) NOT NULL,
    Color NVARCHAR(30),
    Quantity INT DEFAULT 1,
    ItemDescription NVARCHAR(255),
    CreatedDate DATETIME2,
    ArchivedDate DATETIME2 DEFAULT GETDATE()
);

-- Service Request Status History (audit trail)
CREATE TABLE ServiceRequestHistory (
    HistoryID INT IDENTITY(1,1) PRIMARY KEY,
    RequestID INT FOREIGN KEY REFERENCES ServiceRequests(RequestID),
    OldStatus NVARCHAR(20),
    NewStatus NVARCHAR(20) NOT NULL,
    ChangedBy NVARCHAR(100),
    ChangeDate DATETIME2 DEFAULT GETDATE(),
    Notes NVARCHAR(500)
);

-- Reports table
CREATE TABLE Reports (
    ReportID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    ReportType NVARCHAR(50) NOT NULL,
    ReportPeriodStart DATE,
    ReportPeriodEnd DATE,
    GeneratedDate DATETIME2 DEFAULT GETDATE(),
    ReportData NVARCHAR(MAX),
    FilePath NVARCHAR(255)
);

-- User Sessions table
CREATE TABLE UserSessions (
    SessionID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    LoginDate DATETIME2 DEFAULT GETDATE(),
    LogoutDate DATETIME2,
    IPAddress NVARCHAR(45),
    UserAgent NVARCHAR(500)
);

-- Settings table
CREATE TABLE Settings (
    SettingID INT IDENTITY(1,1) PRIMARY KEY,
    SettingKey NVARCHAR(100) UNIQUE NOT NULL,
    SettingValue NVARCHAR(MAX),
    Description NVARCHAR(255),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    ModifiedDate DATETIME2 DEFAULT GETDATE()
);

-- Archive Settings table
CREATE TABLE ArchiveSettings (
    ArchiveSettingID INT IDENTITY(1,1) PRIMARY KEY,
    ArchiveAgeDays INT DEFAULT 365, -- Archive orders older than 1 year
    ArchiveEnabled BIT DEFAULT 1,
    LastArchiveRun DATETIME2,
    NextArchiveRun DATETIME2,
    ArchiveRetentionYears INT DEFAULT 5, -- Keep archived data for 5 years
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

-- Insert default archive settings
INSERT INTO ArchiveSettings (ArchiveAgeDays, ArchiveEnabled, NextArchiveRun) VALUES
(365, 1, DATEADD(DAY, 30, GETDATE())); -- Archive orders older than 1 year, next run in 30 days

-- Create indexes for better performance
CREATE INDEX IX_ServiceRequests_UserID ON ServiceRequests(UserID);
CREATE INDEX IX_ServiceRequests_Status ON ServiceRequests(Status);
CREATE INDEX IX_ServiceRequests_RequestDate ON ServiceRequests(RequestDate);
CREATE INDEX IX_ClothingItems_RequestID ON ClothingItems(RequestID);
CREATE INDEX IX_ServiceRequestHistory_RequestID ON ServiceRequestHistory(RequestID);
CREATE INDEX IX_Reports_UserID ON Reports(UserID);
CREATE INDEX IX_Reports_ReportType ON Reports(ReportType);
CREATE INDEX IX_UserSessions_UserID ON UserSessions(UserID);

-- Archive table indexes
CREATE INDEX IX_ServiceRequestsArchive_UserID ON ServiceRequestsArchive(UserID);
CREATE INDEX IX_ServiceRequestsArchive_RequestDate ON ServiceRequestsArchive(RequestDate);
CREATE INDEX IX_ServiceRequestsArchive_ArchivedDate ON ServiceRequestsArchive(ArchivedDate);
CREATE INDEX IX_ClothingItemsArchive_RequestID ON ClothingItemsArchive(RequestID);

GO

-- View for all service requests (active + archived)
CREATE VIEW vw_AllServiceRequests AS
SELECT
    RequestID,
    UserID,
    ServiceID,
    RequestDate,
    ScheduledPickupDate,
    ScheduledDeliveryDate,
    ActualPickupDate,
    ActualDeliveryDate,
    Status,
    TotalAmount,
    SpecialInstructions,
    CreatedDate,
    ModifiedDate,
    'Active' as DataSource,
    NULL as ArchivedDate,
    NULL as ArchiveReason
FROM ServiceRequests
UNION ALL
SELECT
    OriginalRequestID as RequestID,
    UserID,
    ServiceID,
    RequestDate,
    ScheduledPickupDate,
    ScheduledDeliveryDate,
    ActualPickupDate,
    ActualDeliveryDate,
    Status,
    TotalAmount,
    SpecialInstructions,
    CreatedDate,
    ModifiedDate,
    'Archive' as DataSource,
    ArchivedDate,
    ArchiveReason
FROM ServiceRequestsArchive;

GO

-- View for user dashboard (includes archived data)
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
LEFT JOIN vw_AllServiceRequests sr ON u.UserID = sr.UserID
GROUP BY u.UserID, u.FullName, u.Email;

GO

-- View for monthly usage statistics (includes archived data)
CREATE VIEW vw_MonthlyUsage AS
SELECT
    YEAR(RequestDate) as Year,
    MONTH(RequestDate) as Month,
    COUNT(*) as TotalOrders,
    SUM(TotalAmount) as TotalRevenue,
    COUNT(DISTINCT UserID) as UniqueCustomers
FROM vw_AllServiceRequests
WHERE Status = 'Completed'
GROUP BY YEAR(RequestDate), MONTH(RequestDate);

GO

-- Stored procedure for user authentication
CREATE PROCEDURE sp_AuthenticateUser
    @Username NVARCHAR(50),
    @Password NVARCHAR(255)
AS
BEGIN
    SELECT UserID, Username, FullName, Email, IsActive
    FROM Users
    WHERE Username = @Username
    AND PasswordHash = @Password
    AND IsActive = 1;
END;

GO

-- Enhanced stored procedure for creating a new service request
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

-- Stored procedure for archiving old completed orders
CREATE PROCEDURE sp_ArchiveOldServiceRequests
    @DaysOld INT = NULL,
    @BatchSize INT = 100
AS
BEGIN
    DECLARE @ArchiveAgeDays INT;
    DECLARE @RecordsArchived INT = 0;

    -- Get archive settings if not specified
    IF @DaysOld IS NULL
    BEGIN
        SELECT @ArchiveAgeDays = ArchiveAgeDays
        FROM ArchiveSettings
        WHERE ArchiveEnabled = 1;
    END
    ELSE
    BEGIN
        SET @ArchiveAgeDays = @DaysOld;
    END

    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -@ArchiveAgeDays, GETDATE());

    -- Archive service requests
    INSERT INTO ServiceRequestsArchive (
        OriginalRequestID, UserID, ServiceID, RequestDate, ScheduledPickupDate,
        ScheduledDeliveryDate, ActualPickupDate, ActualDeliveryDate, Status,
        TotalAmount, SpecialInstructions, CreatedDate, ModifiedDate, ArchiveReason
    )
    SELECT TOP (@BatchSize)
        RequestID, UserID, ServiceID, RequestDate, ScheduledPickupDate,
        ScheduledDeliveryDate, ActualPickupDate, ActualDeliveryDate, Status,
        TotalAmount, SpecialInstructions, CreatedDate, ModifiedDate,
        'Age-based archival'
    FROM ServiceRequests
    WHERE Status IN ('Completed', 'Cancelled')
    AND ModifiedDate < @CutoffDate
    AND RequestID NOT IN (SELECT OriginalRequestID FROM ServiceRequestsArchive WHERE OriginalRequestID IS NOT NULL);

    SET @RecordsArchived = @@ROWCOUNT;

    -- Archive clothing items for archived requests
    INSERT INTO ClothingItemsArchive (
        OriginalItemID, RequestID, ItemName, Color, Quantity, ItemDescription, CreatedDate
    )
    SELECT
        ci.ItemID, sra.ArchiveID, ci.ItemName, ci.Color, ci.Quantity, ci.ItemDescription, ci.CreatedDate
    FROM ClothingItems ci
    INNER JOIN ServiceRequestsArchive sra ON ci.RequestID = sra.OriginalRequestID
    WHERE sra.ArchivedDate >= DATEADD(MINUTE, -5, GETDATE()); -- Only archive items for recently archived requests

    -- Delete archived records from active tables
    DELETE FROM ClothingItems
    WHERE RequestID IN (
        SELECT OriginalRequestID
        FROM ServiceRequestsArchive
        WHERE ArchivedDate >= DATEADD(MINUTE, -5, GETDATE())
    );

    DELETE FROM ServiceRequests
    WHERE RequestID IN (
        SELECT OriginalRequestID
        FROM ServiceRequestsArchive
        WHERE ArchivedDate >= DATEADD(MINUTE, -5, GETDATE())
    );

    -- Update archive settings
    UPDATE ArchiveSettings
    SET LastArchiveRun = GETDATE(),
        NextArchiveRun = DATEADD(DAY, 30, GETDATE())
    WHERE ArchiveEnabled = 1;

    SELECT @RecordsArchived as RecordsArchived;
END;

GO

-- Stored procedure for retrieving service history (active + archived)
CREATE PROCEDURE sp_GetServiceHistory
    @UserID INT,
    @IncludeArchived BIT = 1,
    @StartDate DATETIME2 = NULL,
    @EndDate DATETIME2 = NULL
AS
BEGIN
    IF @IncludeArchived = 1
    BEGIN
        SELECT * FROM vw_AllServiceRequests
        WHERE UserID = @UserID
        AND (@StartDate IS NULL OR RequestDate >= @StartDate)
        AND (@EndDate IS NULL OR RequestDate <= @EndDate)
        ORDER BY RequestDate DESC;
    END
    ELSE
    BEGIN
        SELECT * FROM ServiceRequests
        WHERE UserID = @UserID
        AND (@StartDate IS NULL OR RequestDate >= @StartDate)
        AND (@EndDate IS NULL OR RequestDate <= @EndDate)
        ORDER BY RequestDate DESC;
    END
END;

GO

-- Stored procedure for generating monthly reports (includes archived data)
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
        FROM vw_AllServiceRequests
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

-- Add clothing items to the requests
INSERT INTO ClothingItems (RequestID, ItemName, Color, Quantity) VALUES
(1, 'Shirt', 'White', 3),
(1, 'Pants', 'Black', 2),
(2, 'Suit', 'Navy Blue', 1),
(2, 'Dress', 'Red', 1);

-- Create some completed orders for archiving demonstration
INSERT INTO ServiceRequests (UserID, ServiceID, RequestDate, Status, TotalAmount, ActualDeliveryDate, ModifiedDate)
VALUES
(1, 1, '2023-01-15', 'Completed', 150.00, '2023-01-16', '2023-01-16'),
(1, 2, '2023-02-20', 'Completed', 220.00, '2023-02-22', '2023-02-22');

INSERT INTO ClothingItems (RequestID, ItemName, Color, Quantity)
SELECT RequestID, 'Shirt', 'Blue', 2 FROM ServiceRequests WHERE RequestDate < '2024-01-01';

PRINT 'Executive Laundry Verdant database with archiving created successfully!';
PRINT 'Database includes: Users, Services, ServiceRequests, ServiceRequestsArchive, ClothingItems, ClothingItemsArchive';
PRINT 'ArchiveSettings table manages automatic archival of old completed orders';
PRINT 'Views: vw_AllServiceRequests, vw_UserDashboard, vw_MonthlyUsage';
PRINT 'Stored procedures: sp_ArchiveOldServiceRequests, sp_GetServiceHistory, sp_GenerateMonthlyReport';
