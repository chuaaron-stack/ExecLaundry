const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const PORT = 8000;
const JWT_SECRET = 'your-secret-key'; // In production, use environment variable

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(express.static('SAD asf')); // Serve static files from the SAD asf directory

// Database configuration for MySQL
const dbConfig = {
  host: 'localhost',
  user: 'root',
  password: '', // No password for default XAMPP installation
  database: 'laundry_db',
  port: 3309
};

// Create connection pool
let pool;

async function connectDB() {
  try {
    pool = mysql.createPool(dbConfig);
    console.log('Connected to MySQL');
  } catch (err) {
    console.error('Database connection failed:', err);
  }
}

connectDB();

// Middleware to verify JWT token
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ success: false, message: 'Access token required' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ success: false, message: 'Invalid token' });
    }
    req.user = user;
    next();
  });
}

// Login endpoint
app.post('/api/login', async (req, res) => {
  try {
    console.log('Login request received:', req.body);
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ success: false, message: 'Username and password are required' });
    }

    // Query the database directly (MySQL doesn't support stored procedures the same way)
    const [rows] = await pool.execute(
      'SELECT UserID, Username, FullName, Email, PasswordHash FROM Users WHERE Username = ?',
      [username]
    );

    console.log('Database query result:', rows);

    if (rows.length > 0) {
      const user = rows[0];
      console.log('User found:', user);
      console.log('Password check:', password, 'vs', user.PasswordHash);
      // Check password using plain text comparison
      const isValidPassword = password === user.PasswordHash;
      if (isValidPassword) {
        const token = jwt.sign(
          { userId: user.UserID, username: user.Username },
          JWT_SECRET,
          { expiresIn: '24h' }
        );

        res.json({
          success: true,
          message: 'Login successful',
          token: token,
          user: {
            userId: user.UserID,
            username: user.Username,
            fullName: user.FullName,
            email: user.Email
          }
        });
      } else {
        res.status(401).json({ success: false, message: 'Invalid username or password' });
      }
    } else {
      res.status(401).json({ success: false, message: 'Invalid username or password' });
    }
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Logout endpoint
app.post('/api/logout', (req, res) => {
  // In a stateless JWT system, logout is handled client-side by removing the token
  res.json({ success: true, message: 'Logged out successfully' });
});

// Welcome endpoint
app.get('/api/welcome', (req, res) => {
  console.log(`Request logged: Method=${req.method}, Path=${req.path}`);
  res.json({ message: 'Welcome to the API Service!' });
});

// Protected route example - Get user profile
app.get('/api/profile', authenticateToken, async (req, res) => {
  try {
    const [rows] = await pool.execute(
      'SELECT UserID, Username, FullName, Email, Phone, CreatedDate, LastLoginDate FROM Users WHERE UserID = ?',
      [req.user.userId]
    );

    if (rows.length > 0) {
      res.json({ success: true, user: rows[0] });
    } else {
      res.status(404).json({ success: false, message: 'User not found' });
    }
  } catch (error) {
    console.error('Profile error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Users endpoint
app.get('/api/users', authenticateToken, async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT UserID, Username, FullName, Email FROM Users');
    res.json({ success: true, users: rows });
  } catch (error) {
    console.error('Users error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Services endpoint
app.get('/api/services', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM services');
    res.json({ success: true, services: rows });
  } catch (error) {
    console.error('Services error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Requests endpoint
app.get('/api/requests', authenticateToken, async (req, res) => {
  try {
    const [rows] = await pool.execute(
      'SELECT r.*, s.ServiceName FROM ServiceRequests r JOIN Services s ON r.ServiceID = s.ServiceID WHERE r.UserID = ? ORDER BY r.RequestDate DESC',
      [req.user.userId]
    );
    res.json({ success: true, requests: rows });
  } catch (error) {
    console.error('Requests error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Reports endpoint
app.get('/api/reports', authenticateToken, async (req, res) => {
  try {
    const [rows] = await pool.execute(
      'SELECT r.*, s.ServiceName FROM ServiceRequests r JOIN Services s ON r.ServiceID = s.ServiceID WHERE r.UserID = ? AND r.Status = ? ORDER BY r.CompletionDate DESC',
      [req.user.userId, 'Completed']
    );
    res.json({ success: true, reports: rows });
  } catch (error) {
    console.error('Reports error:', error);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
