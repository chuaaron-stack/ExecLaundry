-- Archive Setup and Usage Examples for Executive Laundry Verdant
-- This file demonstrates how to set up and use the archiving functionality

USE ExecutiveLaundryVerdant;
GO

-- =============================================
-- 1. INITIAL ARCHIVE SETUP
-- =============================================

-- Check current archive settings
SELECT * FROM ArchiveSettings;

-- Customize archive settings for your needs
UPDATE ArchiveSettings SET
    ArchiveAgeDays = 180,  -- Archive orders older than 6 months
    ArchiveRetentionYears = 3, -- Keep archived data for 3 years
    NextArchiveRun = '2025-01-01 02:00:00' -- Schedule first run
WHERE ArchiveSettingID = 1;

-- =============================================
-- 2. MANUAL ARCHIVE EXECUTION
-- =============================================

-- Run archive process manually
EXEC sp_ArchiveOldServiceRequests;

-- Check results
SELECT 'Active Orders' as Status, COUNT(*) as Count FROM ServiceRequests
UNION ALL
SELECT 'Archived Orders' as Status, COUNT(*) as Count FROM ServiceRequestsArchive;

-- =============================================
-- 3. VIEWING SERVICE HISTORY
-- =============================================

-- Get all service history for a user (active + archived)
EXEC sp_GetServiceHistory @UserID = 1;

-- Get only active service history
EXEC sp_GetServiceHistory @UserID = 1, @IncludeArchived = 0;

-- Get service history for specific date range
EXEC sp_GetServiceHistory @UserID = 1, @StartDate = '2024-01-01', @EndDate = '2024-12-31';

-- =============================================
-- 4. DASHBOARD AND REPORTING
-- =============================================

-- View user dashboard (includes archived data)
SELECT * FROM vw_UserDashboard WHERE UserID = 1;

-- View monthly usage statistics (includes archived data)
SELECT * FROM vw_MonthlyUsage WHERE Year = 2024 ORDER BY Month;

-- Generate monthly report (includes archived data)
EXEC sp_GenerateMonthlyReport @UserID = 1, @Year = 2024, @Month = 12;

-- =============================================
-- 5. ARCHIVE MONITORING
-- =============================================

-- Check archive table sizes
SELECT
    (SELECT COUNT(*) FROM ServiceRequests) as ActiveOrders,
    (SELECT COUNT(*) FROM ServiceRequestsArchive) as ArchivedOrders,
    (SELECT COUNT(*) FROM ClothingItems) as ActiveItems,
    (SELECT COUNT(*) FROM ClothingItemsArchive) as ArchivedItems;

-- View recent archive activity
SELECT TOP 10
    ArchivedDate,
    COUNT(*) as RecordsArchived,
    ArchiveReason
FROM ServiceRequestsArchive
GROUP BY ArchivedDate, ArchiveReason
ORDER BY ArchivedDate DESC;

-- =============================================
-- 6. ARCHIVE MAINTENANCE
-- =============================================

-- Clean up very old archived data (older than retention period)
DELETE FROM ServiceRequestsArchive
WHERE ArchivedDate < DATEADD(YEAR, -3, GETDATE());

DELETE FROM ClothingItemsArchive
WHERE ArchivedDate < DATEADD(YEAR, -3, GETDATE());

-- Rebuild indexes for better performance
ALTER INDEX ALL ON ServiceRequestsArchive REBUILD;
ALTER INDEX ALL ON ClothingItemsArchive REBUILD;

-- =============================================
-- 7. TESTING THE ARCHIVE SYSTEM
-- =============================================

-- Create test data for archiving
INSERT INTO ServiceRequests (UserID, ServiceID, RequestDate, Status, TotalAmount, ModifiedDate)
VALUES
(1, 1, '2023-06-01', 'Completed', 150.00, '2023-06-02'),
(1, 2, '2023-07-15', 'Completed', 220.00, '2023-07-17'),
(2, 1, '2023-08-10', 'Completed', 100.00, '2023-08-11');

-- Add test clothing items
INSERT INTO ClothingItems (RequestID, ItemName, Color, Quantity)
SELECT RequestID, 'Test Item', 'White', 1 FROM ServiceRequests WHERE RequestDate < '2024-01-01';

-- Test archiving
EXEC sp_ArchiveOldServiceRequests @DaysOld = 30; -- Archive orders older than 30 days

-- Verify test results
SELECT 'Test completed successfully' as Result;

-- =============================================
-- 8. PERFORMANCE OPTIMIZATION
-- =============================================

-- Update archive settings for better performance
UPDATE ArchiveSettings SET
    ArchiveAgeDays = 90,   -- Archive after 3 months
    ArchiveEnabled = 1     -- Enable automatic archiving
WHERE ArchiveSettingID = 1;

-- Schedule regular archive runs (every 14 days)
UPDATE ArchiveSettings SET
    NextArchiveRun = DATEADD(DAY, 14, GETDATE())
WHERE ArchiveSettingID = 1;

-- =============================================
-- 9. BACKUP BEFORE ARCHIVING
-- =============================================

-- Always backup before major archive operations
BACKUP DATABASE ExecutiveLaundryVerdant
TO DISK = 'C:\Backups\ExecutiveLaundryVerdant_Archive.bak'
WITH INIT, COMPRESSION;

-- =============================================
-- 10. INTEGRATION WITH WEBSITE
-- =============================================

-- Example queries for your website's past services page
-- Replace @CurrentUserID with actual user ID from session

DECLARE @CurrentUserID INT = 1;

-- Get recent service history (last 50 orders)
SELECT TOP 50 * FROM vw_AllServiceRequests
WHERE UserID = @CurrentUserID
ORDER BY RequestDate DESC;

-- Get monthly spending summary
SELECT
    YEAR(RequestDate) as Year,
    MONTH(RequestDate) as Month,
    COUNT(*) as OrdersCount,
    SUM(TotalAmount) as MonthlyTotal,
    AVG(TotalAmount) as AverageOrder
FROM vw_AllServiceRequests
WHERE UserID = @CurrentUserID
AND Status = 'Completed'
GROUP BY YEAR(RequestDate), MONTH(RequestDate)
ORDER BY Year DESC, Month DESC;

-- Get service type breakdown
SELECT
    s.ServiceName,
    COUNT(*) as OrderCount,
    SUM(sr.TotalAmount) as TotalSpent
FROM vw_AllServiceRequests sr
JOIN Services s ON sr.ServiceID = s.ServiceID
WHERE sr.UserID = @CurrentUserID
AND sr.Status = 'Completed'
GROUP BY s.ServiceName
ORDER BY TotalSpent DESC;

PRINT 'Archive setup and examples completed!';
PRINT 'Use these examples to integrate archiving with your Executive Laundry Verdant website.';
