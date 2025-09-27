# Executive Laundry Verdant - Database Schema Documentation

## Overview
This database schema is designed for the Executive Laundry Verdant website, a comprehensive laundry service management system. The schema supports user management, service requests, clothing item tracking, reporting, and audit trails.

## Database Structure

### Core Tables

#### 1. Users
Stores customer account information.
- **UserID**: Primary key, auto-increment
- **Username**: Unique username for login
- **PasswordHash**: Hashed password (implement proper hashing in production)
- **Email**: Unique email address
- **Phone**: Contact phone number
- **FullName**: Customer's full name
- **CreatedDate**: Account creation timestamp
- **LastLoginDate**: Last login timestamp
- **IsActive**: Account status flag

#### 2. Services
Defines available laundry services.
- **ServiceID**: Primary key, auto-increment
- **ServiceName**: Name of the service (Wash & Fold, Dry Cleaning, Ironing)
- **Description**: Service description
- **BasePrice**: Standard price for the service
- **EstimatedDurationHours**: Expected completion time
- **IsActive**: Service availability flag
- **CreatedDate**: Service creation timestamp

#### 3. ServiceRequests
Main table for customer orders/service requests.
- **RequestID**: Primary key, auto-increment
- **UserID**: Foreign key to Users table
- **ServiceID**: Foreign key to Services table
- **RequestDate**: When the request was made
- **ScheduledPickupDate**: Planned pickup date/time
- **ScheduledDeliveryDate**: Planned delivery date/time
- **ActualPickupDate**: Actual pickup timestamp
- **ActualDeliveryDate**: Actual delivery timestamp
- **Status**: Current status (Pending, In Progress, Ready for Pickup, Completed, Cancelled)
- **TotalAmount**: Final calculated amount
- **SpecialInstructions**: Customer notes
- **CreatedDate/ModifiedDate**: Audit timestamps

#### 4. ClothingItems
Individual clothing items within each service request.
- **ItemID**: Primary key, auto-increment
- **RequestID**: Foreign key to ServiceRequests table
- **ItemName**: Type of clothing (Shirt, Pants, Dress, etc.)
- **Color**: Color of the item
- **Quantity**: Number of items
- **ItemDescription**: Additional item details
- **CreatedDate**: Item record creation timestamp

### Supporting Tables

#### 5. ServiceRequestHistory
Audit trail for status changes.
- **HistoryID**: Primary key, auto-increment
- **RequestID**: Foreign key to ServiceRequests table
- **OldStatus**: Previous status
- **NewStatus**: Current status
- **ChangedBy**: Who made the change
- **ChangeDate**: When the change occurred
- **Notes**: Additional change notes

#### 6. Reports
Stores generated reports for users.
- **ReportID**: Primary key, auto-increment
- **UserID**: Foreign key to Users table
- **ReportType**: Type of report (Monthly Usage, Spending Summary, etc.)
- **ReportPeriodStart/End**: Date range for the report
- **GeneratedDate**: When the report was created
- **ReportData**: JSON/XML report data
- **FilePath**: Path to saved report file

#### 7. UserSessions
Tracks user login sessions.
- **SessionID**: Unique identifier (GUID)
- **UserID**: Foreign key to Users table
- **LoginDate**: Login timestamp
- **LogoutDate**: Logout timestamp (nullable)
- **IPAddress**: User's IP address
- **UserAgent**: Browser/client information

#### 8. Settings
Application configuration settings.
- **SettingID**: Primary key, auto-increment
- **SettingKey**: Configuration key name
- **SettingValue**: Configuration value
- **Description**: Description of the setting
- **CreatedDate/ModifiedDate**: Audit timestamps

## Views

### vw_UserDashboard
Provides a summary of user activity including:
- Total orders
- Completed orders
- Active orders
- Total spending
- Last order date

### vw_MonthlyUsage
Aggregates monthly usage statistics:
- Total orders per month
- Total revenue per month
- Unique customers per month

## Stored Procedures

### sp_AuthenticateUser
Authenticates user login credentials.
**Parameters:**
- @Username: User's username
- @Password: User's password

### sp_CreateServiceRequest
Creates a new service request.
**Parameters:**
- @UserID: Customer ID
- @ServiceID: Service type ID
- @ScheduledPickupDate: Planned pickup date/time
- @ScheduledDeliveryDate: Planned delivery date/time
- @SpecialInstructions: Optional customer notes

### sp_GenerateMonthlyReport
Generates monthly usage reports.
**Parameters:**
- @UserID: Customer ID
- @Year: Report year
- @Month: Report month

## Indexes
The schema includes optimized indexes on frequently queried columns:
- ServiceRequests: UserID, Status, RequestDate
- ClothingItems: RequestID
- ServiceRequestHistory: RequestID
- Reports: UserID, ReportType
- UserSessions: UserID

## Sample Data
The schema includes sample data for testing:
- 2 sample users (johndoe, janesmith)
- 3 default services (Wash & Fold, Dry Cleaning, Ironing)
- Sample service requests with clothing items
- Default application settings

## Usage Instructions

### 1. Database Setup
1. Connect to your SQL Server instance
2. Execute the SQL script to create the database and all objects
3. The script will automatically create sample data for testing

### 2. Integration with Website
The database is designed to work with the Executive Laundry Verdant website:
- User authentication and session management
- Service request creation and tracking
- Clothing item management
- Report generation
- Dashboard statistics

### 3. Security Considerations
- Implement proper password hashing before using in production
- Consider adding user roles and permissions
- Add input validation and SQL injection protection
- Implement proper session management
- Add audit logging for sensitive operations

### 4. Performance Optimization
- The schema includes appropriate indexes for common queries
- Views are provided for complex dashboard queries
- Consider partitioning large tables if you expect high volume
- Regular maintenance (index rebuilds, statistics updates) recommended

## File Structure
- `laundry_database_schema_corrected.sql`: Main database schema file
- `README_Database_Schema.md`: This documentation file

## Support
For questions about the database schema or integration with the Executive Laundry Verdant website, please refer to the application documentation or contact the development team.
