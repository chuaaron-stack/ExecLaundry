# Database Setup with XAMPP and SSMS - TODO

## Step 1: Install and Configure SQL Server
- [ ] Download and install SQL Server Express (if not already installed)
- [ ] Download and install SQL Server Management Studio (SSMS)
- [ ] Start SQL Server service
- [ ] Connect to SQL Server instance using SSMS

## Step 2: Create Database with SSMS
- [ ] Open SSMS and connect to your SQL Server instance
- [ ] Execute the laundry_database_schema_corrected.sql script to create the ExecutiveLaundryVerdant database
- [ ] Verify database creation and sample data insertion

## Step 3: Configure XAMPP for SQL Server Connectivity
- [ ] Download Microsoft Drivers for PHP for SQL Server (matching your PHP version in XAMPP)
- [ ] Copy php_sqlsrv.dll and php_pdo_sqlsrv.dll to XAMPP's php/ext directory
- [ ] Enable the extensions in php.ini (add extension=php_sqlsrv.dll and extension=php_pdo_sqlsrv.dll)
- [ ] Restart Apache in XAMPP

## Step 4: Update PHP Configuration
- [x] Modify config.php to use SQL Server connection parameters instead of MySQL
- [x] Update database host, username, password, and database name for SQL Server

## Step 5: Test the Setup
- [ ] Start XAMPP Apache server
- [ ] Test PHP connection to SQL Server database
- [ ] Run a sample query from one of the PHP API files (e.g., api/login.php)
- [ ] Verify data retrieval from the database
