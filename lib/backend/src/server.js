const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const furnitureRoutes = require('./routes/furnitureRoutes');
const favoritesRoutes = require('./routes/favoritesRoutes');
const projectRoutes = require('./routes/projectRoutes');
const designRoutes = require('./routes/designRoutes');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Server is running' });
});

// Mount routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/furniture', furnitureRoutes);
app.use('/api/favorites', favoritesRoutes);
app.use('/api/projects', projectRoutes);
app.use('/api/designs', designRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log('\nAvailable routes:');
  console.log('  Auth:      /api/auth/*');
  console.log('  Users:     /api/users/*');
  console.log('  Furniture: /api/furniture/*');
  console.log('  Favorites: /api/favorites/*');
  console.log('  Projects:  /api/projects/*');
  console.log('  Designs:   /api/designs/*');
});

module.exports = app;