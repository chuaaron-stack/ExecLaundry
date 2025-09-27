# Executive Laundry Verdant - Database Schema with Archiving

## Overview
This enhanced database schema includes comprehensive archiving functionality for managing historical service requests and past services. The system automatically archives old completed orders to maintain optimal performance while preserving all historical data.

## New Archiving Features

### Archive Tables

#### ServiceRequestsArchive
Stores archived service requests that are older than the specified retention period.
- **ArchiveID**: Primary key for archived records
- **OriginalRequestID**: Reference to the original request ID
- **ArchivedDate**: When the record was archived
- **ArchiveReason**: Reason for archival (default: "Age-based archival")

#### ClothingItemsArchive
Stores archived clothing items from completed orders.
- **ArchiveItemID**: Primary key for archived items
- **OriginalItemID**: Reference to the original item ID
- **RequestID**: Reference to the archived request

#### ArchiveSettings
Manages archive configuration and scheduling.
- **ArchiveAgeDays**: How old orders must be before archiving (default: 365 days)
- **ArchiveEnabled**: Enable/disable automatic archiving
- **LastArchiveRun**: Timestamp of last archive operation
- **NextArchiveRun**: Scheduled next archive run
- **ArchiveRetentionYears**: How long to keep archived data (default: 5 years)

### Archive Views

#### vw_AllServiceRequests
Unified view combining active and archived service requests.
- Provides seamless access to all service history
- Includes data source indicator ('Active' or 'Archive')
- Used by dashboard and reporting functions

### Archive Stored Procedures

#### sp_ArchiveOldServiceRequests
Archives old completed orders.
**Parameters:**
- @DaysOld: Override default archive age (optional)
- @BatchSize: Number of records to archive per batch (default: 100)

**Usage:**
```sql
-- Archive orders older than 1 year (default)
EXEC sp_ArchiveOldServiceRequests;

-- Archive orders older than 6 months
EXEC sp_ArchiveOldServiceRequests @DaysOld = 180;

-- Archive in batches of 50
EXEC sp_ArchiveOldServiceRequests @BatchSize = 50;
```

#### sp_GetServiceHistory
Retrieves service history with option to include archived data.
**Parameters:**
- @UserID: Customer ID
- @IncludeArchived: Include archived records (default: 1)
- @StartDate/@EndDate: Date range filter (optional)

**Usage:**
```sql
-- Get all service history (active + archived)
EXEC sp_GetServiceHistory @UserID = 1;

-- Get only active service history
EXEC sp_GetServiceHistory @UserID = 1, @IncludeArchived = 0;

-- Get service history for specific date range
EXEC sp_GetServiceHistory @UserID = 1, @StartDate = '2024-01-01', @EndDate = '2024-12-31';
```

## Archive Process

### Automatic Archiving
1. **Scheduled Execution**: Archive runs automatically based on ArchiveSettings.NextArchiveRun
2. **Age-based Selection**: Orders older than ArchiveAgeDays are selected for archival
3. **Batch Processing**: Archives records in configurable batches to avoid performance impact
4. **Data Preservation**: All data is preserved in archive tables
5. **Cleanup**: Original records are removed from active tables after successful archival

### Manual Archiving
You can trigger archiving manually:
```sql
-- Run archive process
EXEC sp_ArchiveOldServiceRequests;

-- Check how many records were archived
SELECT * FROM ArchiveSettings;
```

## Benefits of Archiving

### Performance Benefits
- **Faster Queries**: Active tables contain only recent/current orders
- **Reduced Storage**: Historical data is organized separately
- **Optimized Indexes**: Indexes work more efficiently on smaller active datasets
- **Better Reporting**: Historical data remains accessible through views

### Data Management Benefits
- **Complete History**: All service history is preserved
- **Configurable Retention**: Control how long data is kept
- **Audit Trail**: Archive operations are logged
- **Flexible Access**: Views provide unified access to all data

## Configuration

### Archive Settings
```sql
-- View current archive settings
SELECT * FROM ArchiveSettings;

-- Update archive age (archive orders older than 2 years)
UPDATE ArchiveSettings SET ArchiveAgeDays = 730 WHERE ArchiveSettingID = 1;

-- Disable automatic archiving
UPDATE ArchiveSettings SET ArchiveEnabled = 0 WHERE ArchiveSettingID = 1;

-- Schedule next archive run
UPDATE ArchiveSettings SET NextArchiveRun = '2025-01-01 02:00:00' WHERE ArchiveSettingID = 1;
```

### Archive Schedule
- **Default**: Archives orders older than 1 year
- **Frequency**: Runs every 30 days by default
- **Batch Size**: Processes 100 records per batch
- **Timing**: Can be scheduled during off-peak hours

## Integration with Website

### Past Services Page
The `past-services.html` page can use the archiving system:
```sql
-- Get user's complete service history
EXEC sp_GetServiceHistory @UserID = @CurrentUserID;
```

### Reports
Reports automatically include archived data:
```sql
-- Generate monthly report (includes archived data)
EXEC sp_GenerateMonthlyReport @UserID = @UserID, @Year = 2024, @Month = 1;
```

### Dashboard
Dashboard statistics include all historical data:
```sql
-- Get dashboard data (includes archived orders)
SELECT * FROM vw_UserDashboard WHERE UserID = @UserID;
```

## Maintenance

### Archive Cleanup
Periodically clean up very old archived data:
```sql
-- Remove archived records older than 5 years
DELETE FROM ServiceRequestsArchive
WHERE ArchivedDate < DATEADD(YEAR, -5, GETDATE());

DELETE FROM ClothingItemsArchive
WHERE ArchivedDate < DATEADD(YEAR, -5, GETDATE());
```

### Index Maintenance
Rebuild indexes periodically for optimal performance:
```sql
-- Rebuild archive table indexes
ALTER INDEX IX_ServiceRequestsArchive_RequestDate ON ServiceRequestsArchive REBUILD;
ALTER INDEX IX_ClothingItemsArchive_RequestID ON ClothingItemsArchive REBUILD;
```

## Best Practices

### 1. Archive Scheduling
- Schedule archiving during low-traffic periods
- Monitor archive performance and adjust batch sizes
- Set up alerts for failed archive operations

### 2. Data Retention
- Balance data retention needs with storage costs
- Consider legal requirements for data retention
- Implement backup procedures before major archive operations

### 3. Performance Monitoring
- Monitor query performance on archive views
- Track archive table growth
- Set up monitoring for archive process completion

### 4. User Communication
- Inform users about data archival policies
- Provide clear access to historical data
- Consider user preferences for data retention

## Troubleshooting

### Common Issues

**Archive process fails:**
- Check available disk space
- Verify database permissions
- Review error logs

**Performance issues:**
- Adjust batch size in ArchiveSettings
- Consider index optimization
- Check for lock contention

**Missing historical data:**
- Verify IncludeArchived parameter in queries
- Check archive table for data
- Review archive logs

## File Structure
- `laundry_database_with_archiving.sql`: Enhanced database schema with archiving
- `README_Database_Archiving.md`: This documentation file
- `laundry_database_schema_corrected.sql`: Basic schema without archiving

## Support
For questions about the archiving system or integration with the Executive Laundry Verdant website, please refer to the application documentation or contact the development team.
