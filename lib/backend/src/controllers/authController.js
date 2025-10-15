const { auth, db } = require('../config/firebase');

// Signup (Register) new user
exports.signup = async (req, res) => {
  try {
    const { email, password, displayName } = req.body;

    // Validate input
    if (!email || !password || !displayName) {
      return res.status(400).json({
        success: false,
        error: 'Email, password, and display name are required',
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        error: 'Password must be at least 6 characters',
      });
    }

    // Create Firebase Auth user
    const userRecord = await auth.createUser({
      email,
      password,
      displayName,
    });

    // Create user document in Firestore - matching User model
    await db.collection('users').doc(userRecord.uid).set({
      uid: userRecord.uid,
      email,
      displayName,
      profileImageUrl: null,
      preferences: {},
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      lastLogin: new Date().toISOString(),
    });

    console.log(`User signed up: ${email}`);

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        uid: userRecord.uid,
        email,
        displayName,
      },
    });
  } catch (error) {
    console.error('Signup error:', error);

    if (error.code === 'auth/email-already-exists') {
      return res.status(400).json({
        success: false,
        error: 'Email already in use',
      });
    }

    if (error.code === 'auth/invalid-email') {
      return res.status(400).json({
        success: false,
        error: 'Invalid email address',
      });
    }

    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Login (record login event)

exports.login = async (req, res) => {
  try {
    const { uid } = req.body;

    if (!uid) {
      return res.status(400).json({
        success: false,
        error: 'User ID is required',
      });
    }

    // Update last login timestamp
    await db.collection('users').doc(uid).update({
      lastLogin: new Date().toISOString(),
    });

    console.log(`User logged in: ${uid}`);

    res.json({
      success: true,
      message: 'Login recorded successfully'
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Logout

exports.logout = async (req, res) => {
  try {
    res.json({
      success: true,
      message: 'Logged out successfully'
    });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Forgot password

exports.forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        error: 'Email is required',
      });
    }

    const link = await auth.generatePasswordResetLink(email);

    console.log(`Password reset link generated for: ${email}`);

    res.json({
      success: true,
      message: 'Password reset email sent',
      link,
    });
  } catch (error) {
    console.error('Password reset error:', error);

    if (error.code === 'auth/user-not-found') {
      return res.status(404).json({
        success: false,
        error: 'No user found with this email',
      });
    }

    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Reset password
exports.resetPassword = async (req, res) => {
  try {
    const { oobCode, newPassword } = req.body;

    if (!oobCode || !newPassword) {
      return res.status(400).json({
        success: false,
        error: 'Reset code and new password are required',
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        error: 'Password must be at least 6 characters',
      });
    }

    const email = await auth.verifyPasswordResetCode(oobCode);
    await auth.confirmPasswordReset(oobCode, newPassword);

    console.log(`Password reset for: ${email}`);

    res.json({
      success: true,
      message: 'Password reset successfully'
    });
  } catch (error) {
    console.error('Reset password error:', error);

    if (error.code === 'auth/invalid-action-code') {
      return res.status(400).json({
        success: false,
        error: 'Invalid or expired reset code',
      });
    }

    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Get profile (protected)

exports.getProfile = async (req, res) => {
  try {
    const userDoc = await db.collection('users').doc(req.user.uid).get();

    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        error: 'User profile not found'
      });
    }

    res.json({
      success: true,
      data: userDoc.data()
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Update profile (protected)

exports.updateProfile = async (req, res) => {
  try {
    const { displayName, profileImageUrl, preferences } = req.body;
    const updates = {};

    if (displayName !== undefined) {
      updates.displayName = displayName;
      await auth.updateUser(req.user.uid, { displayName });
    }

    if (profileImageUrl !== undefined) {
      updates.profileImageUrl = profileImageUrl;
      if (profileImageUrl) {
        await auth.updateUser(req.user.uid, { photoURL: profileImageUrl });
      }
    }

    if (preferences !== undefined) {
      updates.preferences = preferences;
    }

    updates.updatedAt = new Date().toISOString();

    await db.collection('users').doc(req.user.uid).update(updates);

    console.log(`Profile updated for UID: ${req.user.uid}`);

    res.json({
      success: true,
      message: 'Profile updated successfully'
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Delete account (protected)
exports.deleteAccount = async (req, res) => {
  try {
    const userId = req.user.uid;

    // Delete user's projects
    const projectsSnapshot = await db.collection('projects')
      .where('userId', '==', userId)
      .get();
    const projectDeletions = projectsSnapshot.docs.map(doc => doc.ref.delete());
    await Promise.all(projectDeletions);

    // Delete user's designs
    const designsSnapshot = await db.collection('designs')
      .where('userId', '==', userId)
      .get();
    const designDeletions = designsSnapshot.docs.map(doc => doc.ref.delete());
    await Promise.all(designDeletions);

    // Delete favorites subcollection
    const favoritesSnapshot = await db.collection('users')
      .doc(userId)
      .collection('favorites')
      .get();
    const favoriteDeletions = favoritesSnapshot.docs.map(doc => doc.ref.delete());
    await Promise.all(favoriteDeletions);

    // Delete recently viewed subcollection
    const recentlyViewedSnapshot = await db.collection('users')
      .doc(userId)
      .collection('recently_viewed')
      .get();
    const recentlyViewedDeletions = recentlyViewedSnapshot.docs.map(doc => doc.ref.delete());
    await Promise.all(recentlyViewedDeletions);

    // Delete user document
    await db.collection('users').doc(userId).delete();

    // Delete Firebase Auth user
    await auth.deleteUser(userId);

    console.log(`Account deleted for UID: ${userId}`);

    res.json({
      success: true,
      message: 'Account deleted successfully'
    });
  } catch (error) {
    console.error('Delete account error:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Change password (protected)
exports.changePassword = async (req, res) => {
  try {
    const { newPassword } = req.body;

    if (!newPassword) {
      return res.status(400).json({
        success: false,
        error: 'New password is required',
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        error: 'Password must be at least 6 characters',
      });
    }

    await auth.updateUser(req.user.uid, {
      password: newPassword,
    });

    console.log(`Password changed for UID: ${req.user.uid}`);

    res.json({
      success: true,
      message: 'Password changed successfully'
    });
  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Verify token (for testing)

exports.verifyToken = async (req, res) => {
  try {
    res.json({
      success: true,
      message: 'Token is valid',
      user: {
        uid: req.user.uid,
        email: req.user.email,
      }
    });
  } catch (error) {
    console.error('Verify token error:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};