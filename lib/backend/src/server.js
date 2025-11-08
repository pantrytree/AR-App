const express = require('express');
const cors = require('cors');
require('dotenv').config();

// Route imports for different API modules
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const furnitureRoutes = require('./routes/furnitureRoutes');
const favoritesRoutes = require('./routes/favoritesRoutes');
const projectRoutes = require('./routes/projectRoutes');
const designRoutes = require('./routes/designRoutes');

const app = express();

// Middleware setup
app.use(cors()); // Enable Cross-Origin Resource Sharing for frontend access
app.use(express.json()); // Parse incoming JSON request bodies

// Health check endpoint to verify server status
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Server is running' });
});

// Mount all API route modules to their respective base paths
app.use('/api/auth', authRoutes); // Authentication routes (login, register, etc.)
app.use('/api/users', userRoutes); // User profile and management routes
app.use('/api/furniture', furnitureRoutes); // Furniture catalog and search routes
app.use('/api/favorites', favoritesRoutes); // User favorite items management
app.use('/api/projects', projectRoutes); // Project creation and collaboration routes
app.use('/api/designs', designRoutes); // Design creation and manipulation routes

// 404 handler for undefined routes
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Global error handler for uncaught exceptions
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// Server startup configuration
const PORT = process.env.PORT || 3000; // Use environment port or default to 3000
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log('\nAvailable routes:'); // Log all available API endpoints on startup
  console.log('  Auth:      /api/auth/*');
  console.log('  Users:     /api/users/*');
  console.log('  Furniture: /api/furniture/*');
  console.log('  Favorites: /api/favorites/*');
  console.log('  Projects:  /api/projects/*');
  console.log('  Designs:   /api/designs/*');
});

module.exports = app; // Export app for testing purposes
