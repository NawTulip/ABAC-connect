// Import Required Packages
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');
dotenv.config();

// Initialize Express App
const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Database Connection
const pool = new Pool({
  user: process.env.PG_USER,
  host: process.env.PG_HOST,
  database: process.env.PG_DATABASE,
  password: process.env.PG_PASSWORD,
  port: process.env.PG_PORT,
});

// JWT Secret
const JWT_SECRET = process.env.JWT_SECRET;

// Home Route
app.get('/', (req, res) => {
  res.send('Welcome to the ABAC Connect API!');
});

// ✅ Register a User (Admin or Student)
app.post('/api/users/register', async (req, res) => {
  const { name, email, password, role } = req.body;
  const hashedPassword = await bcrypt.hash(password, 10);

  try {
    let result;
    if (role === 'admin') {
      result = await pool.query(
        'INSERT INTO admin (name, email, password) VALUES ($1, $2, $3) RETURNING admin_id, name, email',
        [name, email, hashedPassword]
      );
    } else if (role === 'student') {
      result = await pool.query(
        'INSERT INTO student (name, email, password) VALUES ($1, $2, $3) RETURNING user_id, name, email',
        [name, email, hashedPassword]
      );
    } else {
      return res.status(400).json({ message: 'Invalid role' });
    }

    res.status(201).json({ user: result.rows[0] });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// ✅ User Login (Admin or Student)
app.post('/api/users/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    let result = await pool.query('SELECT * FROM admin WHERE email = $1', [email]);

    // Check if the user is an admin first
    let user = result.rows[0];
    
    if (!user) {
      // If not admin, check for student
      result = await pool.query('SELECT * FROM student WHERE email = $1', [email]);
      user = result.rows[0];
    }

    if (!user) {
      return res.status(400).json({ message: 'User not found' });
    }

    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) return res.status(400).json({ message: 'Invalid password' });

    // Generate JWT Token
    const token = jwt.sign(
      { id: user.admin_id || user.user_id, role: user.email.includes('@admin') ? 'admin' : 'student' },
      JWT_SECRET,
      { expiresIn: '1h' }
    );

    res.json({ token });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ Middleware to Verify JWT Token
const verifyToken = (req, res, next) => {
  const token = req.header('Authorization')?.split(' ')[1];
  if (!token) return res.status(403).json({ message: 'Access denied' });

  try {
    const verified = jwt.verify(token, JWT_SECRET);
    req.user = verified;
    next();
  } catch (err) {
    res.status(400).json({ message: 'Invalid token' });
  }
};

// ✅ Create a Booking (Student)
app.post('/api/bookings', verifyToken, async (req, res) => {
  if (req.user.role !== 'student') return res.status(403).json({ message: 'Only students can book' });

  const { route_id, van_id, driver_id, booking_date, pickup_location, dropoff_location, status } = req.body;
  const user_id = req.user.id;

  try {
    const result = await pool.query(
      'INSERT INTO booking (user_id, route_id, van_id, driver_id, booking_date, pickup_location, dropoff_location, status) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *',
      [user_id, route_id, van_id, driver_id, booking_date, pickup_location, dropoff_location, status]
    );
    res.status(201).json({ booking: result.rows[0] });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// ✅ Get All Bookings (Admin)
app.get('/api/bookings', verifyToken, async (req, res) => {
  if (req.user.role !== 'admin') return res.status(403).json({ message: 'Only admins can view bookings' });

  try {
    const result = await pool.query(`
      SELECT b.booking_id, s.name AS student_name, v.van_number, r.start_location, r.end_location, b.booking_date, b.status
      FROM booking b
      JOIN student s ON b.user_id = s.user_id
      JOIN van v ON b.van_id = v.van_id
      JOIN route r ON b.route_id = r.route_id
    `);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ Add New Driver (Admin)
app.post('/api/drivers', verifyToken, async (req, res) => {
  if (req.user.role !== 'admin') return res.status(403).json({ message: 'Only admins can add drivers' });

  const { name, contract, assigned_van_id } = req.body;

  try {
    const result = await pool.query(
      'INSERT INTO driver (name, contract, assigned_van_id) VALUES ($1, $2, $3) RETURNING *',
      [name, contract, assigned_van_id]
    );
    res.status(201).json({ driver: result.rows[0] });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// ✅ Get All Drivers
app.get('/api/drivers', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM driver');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ Get All Routes
app.get('/api/routes', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM route');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ Get Available Vans
app.get('/api/vans', async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM van WHERE status = 'Available'");
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ Get All Payments (Admin)
app.get('/api/payments', verifyToken, async (req, res) => {
  if (req.user.role !== 'admin') return res.status(403).json({ message: 'Only admins can view payments' });

  try {
    const result = await pool.query(`
      SELECT p.payment_id, b.booking_id, s.name AS student_name, p.amount, p.method, p.status
      FROM payment p
      JOIN booking b ON p.booking_id = b.booking_id
      JOIN student s ON b.user_id = s.user_id
    `);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ Delete Booking (Admin)
app.delete('/api/bookings/:id', verifyToken, async (req, res) => {
  if (req.user.role !== 'admin') return res.status(403).json({ message: 'Only admins can delete bookings' });

  const { id } = req.params;
  try {
    await pool.query('DELETE FROM booking WHERE booking_id = $1', [id]);
    res.json({ message: 'Booking deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Start Server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
