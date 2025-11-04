const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { verifyToken } = require('../middleware/auth');

// All routes require authentication
router.use(verifyToken);

// Profile Management

// GET /api/users/profile - Get current user's profile
router.get('/profile', userController.getProfile);
// PUT /api/users/profile - Update current user's profile
router.put('/profile', userController.updateProfile);

// Preferences Management

// GET /api/users/preferences - Get user preferences
router.get('/preferences', userController.getPreferences);
// PUT /api/users/preferences - Update all user preferences
router.put('/preferences', userController.updatePreferences);
// PATCH /api/users/preferences - Update single preference
router.patch('/preferences', userController.updatePreference);

// User Information

// PUT /api/users/last-login - Update last login timestamp
router.put('/last-login', userController.updateLastLogin);

// User Search & Discovery

// GET /api/users/search?query=name - Search users by display name
router.get('/search', userController.searchUsers);
// GET /api/users/by-email?email=user@example.com - Get user by email
router.get('/by-email', userController.getUserByEmail);
// POST /api/users/batch - Get multiple users by IDs
router.post('/batch', userController.getUsersByIds);


// Public User Information

// GET /api/users/:userId/exists - Check if user exists
router.get('/:userId/exists', userController.checkUserExists);
// GET /api/users/:userId - Get user by ID (public info only)
router.get('/:userId', userController.getUserById);

// Account Management

// DELETE /api/users/account - Delete user account (DANGEROUS!)
router.delete('/account', userController.deleteAccount);

module.exports = router;