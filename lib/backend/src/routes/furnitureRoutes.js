const express = require('express');
const router = express.Router();
const furnitureController = require('../controllers/furnitureController');
const { verifyToken } = require('../middleware/auth');

// Public routes
// GET /api/furniture
router.get('/', furnitureController.getAllFurniture);

// GET /api/furniture/featured
router.get('/featured', furnitureController.getFeaturedFurniture);

// GET /api/furniture/search
router.get('/search', furnitureController.searchFurniture);

// GET /api/furniture/room/:roomType
router.get('/room/:roomType', furnitureController.getFurnitureByRoom);

// GET /api/furniture/:id
router.get('/:id', furnitureController.getFurnitureById);

// Protected routes
// GET /api/furniture/user/recently-viewed
router.get('/user/recently-viewed', verifyToken, furnitureController.getRecentlyViewed);

// POST /api/furniture/user/track-view
router.post('/user/track-view', verifyToken, furnitureController.trackView);

module.exports = router;