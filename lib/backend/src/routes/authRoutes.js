const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { verifyToken } = require('../middleware/auth');

console.log('authController exports:', Object.keys(authController));
console.log('verifyToken:', verifyToken); 
console.log('verifyToken type:', typeof verifyToken); 

// Public routes
router.post('/signup', authController.signup);
router.post('/login', authController.login);
router.post('/logout', authController.logout);
router.post('/forgot-password', authController.forgotPassword);
router.post('/reset-password', authController.resetPassword);

// Protected routes
router.get('/profile', verifyToken, authController.getProfile);
router.put('/profile', verifyToken, authController.updateProfile);
router.delete('/account', verifyToken, authController.deleteAccount);
router.post('/change-password', verifyToken, authController.changePassword);
router.get('/verify-token', verifyToken, authController.verifyToken);

module.exports = router;
