const { auth } = require('../config/firebase');

// Middleware to verify Firebase authentication tokens for protected routes
const verifyToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    // Check if Authorization header exists and uses Bearer format
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: 'No token provided'
      });
    }

    // Extract the token from the Bearer header
    const token = authHeader.split('Bearer ')[1];

    // Validate that token exists after extraction
    if (!token) {
      return res.status(401).json({
        success: false,
        error: 'Invalid token format'
      });
    }

    // Verify the token with Firebase Admin SDK and attach user data to request
    const decodedToken = await auth.verifyIdToken(token);
    req.user = decodedToken;

    next(); // Proceed to the next middleware/route handler
  } catch (error) {
    console.error('Token verification error:', error);
    return res.status(401).json({
      success: false,
      error: 'Invalid or expired token'
    });
  }
};

module.exports = { verifyToken };
