const express = require('express');
const router = express.Router();
const favoritesController = require('../controllers/favoritesController');
const { verifyToken } = require('../middleware/auth');

// All routes require authentication
router.use(verifyToken);

// GET /api/favorites
router.get('/', favoritesController.getFavorites);

// POST /api/favorites
router.post('/', favoritesController.addFavorite);

// DELETE /api/favorites/:itemId
router.delete('/:itemId', favoritesController.removeFavorite);

// GET /api/favorites/check/:itemId
router.get('/check/:itemId', favoritesController.checkFavorite);

module.exports = router;