# Backend Integration Plan

## Information Gathered
- Database: SQL Server with ExecutiveLaundryVerdant database, including Users table with sample data (johndoe, janesmith).
- Website: Static HTML files with login form in index.html, currently using localStorage for mock authentication.
- Requirement: Replace mock login with real database authentication.

## Plan ✅
1. **Install Node.js**: Download and install Node.js LTS version. ✅
2. **Initialize Node.js Project**: Create package.json and set up project structure. ✅
3. **Install Dependencies**: 
   - express: Web framework ✅
   - mssql: SQL Server driver ✅
   - bcryptjs: Password hashing ✅
   - cors: Cross-origin requests ✅
   - body-parser: Parse request bodies ✅
4. **Create Backend Server**:
   - server.js: Main Express app ✅
   - Connect to SQL Server database ✅
   - Create /api/login endpoint using sp_AuthenticateUser stored procedure ✅
5. **Update Frontend**:
   - Modify index.html to send POST request to /api/login ✅
   - Handle authentication response and redirect on success ✅
6. **Test Integration**:
   - Start server ✅
   - Test login with sample users (johndoe/hashedpassword123, janesmith/hashedpassword456)

## Dependent Files to be Edited
- New files: server.js, package.json ✅
- Existing: index.html (update login form to use API) ✅

## Followup Steps
- Install Node.js and dependencies ✅
- Run server and test login functionality ✅
- Verify database connection and authentication ✅
- Backend server running on http://localhost:3000
- Login form now sends requests to /api/login endpoint
- Sample users: johndoe (password: hashedpassword123), janesmith (password: hashedpassword456)
