const { db, auth } = require('../config/firebase');

// Get current user profile
exports.getProfile = async (req, res) => {
  try {
    const userDoc = await db.collection('users').doc(req.user.uid).get();

    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    res.json({
      success: true,
      data: userDoc.data()
    });
  } catch (error) {
    console.error('Error getting profile:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Update user profile
exports.updateProfile = async (req, res) => {
  try {
    const { displayName, profileImageUrl, preferences } = req.body;
    const updates = {};

    // Validate and add fields to update
    if (displayName !== undefined) {
      if (typeof displayName !== 'string' || displayName.trim().length === 0) {
        return res.status(400).json({
          success: false,
          error: 'Display name must be a non-empty string'
        });
      }
      updates.displayName = displayName.trim();
    }

    if (profileImageUrl !== undefined) {
      if (profileImageUrl !== null && typeof profileImageUrl !== 'string') {
        return res.status(400).json({
          success: false,
          error: 'Profile image URL must be a string or null'
        });
      }
      updates.profileImageUrl = profileImageUrl;
    }

    if (preferences !== undefined) {
      if (typeof preferences !== 'object' || Array.isArray(preferences)) {
        return res.status(400).json({
          success: false,
          error: 'Preferences must be an object'
        });
      }
      updates.preferences = preferences;
    }

    // Add timestamp
    updates.updatedAt = new Date().toISOString();

    // Update in Firestore
    await db.collection('users').doc(req.user.uid).update(updates);

    // Update display name in Firebase Auth if changed
    if (displayName !== undefined) {
      await auth.updateUser(req.user.uid, {
        displayName: updates.displayName,
      });
    }

    // Update photo URL in Firebase Auth if changed
    if (profileImageUrl !== undefined && profileImageUrl !== null) {
      await auth.updateUser(req.user.uid, {
        photoURL: profileImageUrl,
      });
    }

    res.json({
      success: true,
      message: 'Profile updated successfully'
    });
  } catch (error) {
    console.error('Error updating profile:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Get user preferences

exports.getPreferences = async (req, res) => {
  try {
    const userDoc = await db.collection('users').doc(req.user.uid).get();

    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    const preferences = userDoc.data()?.preferences || {};

    res.json({
      success: true,
      data: preferences
    });
  } catch (error) {
    console.error('Error getting preferences:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};


// Update user preferences
exports.updatePreferences = async (req, res) => {
  try {
    const preferences = req.body;

    // Validate preferences object
    if (typeof preferences !== 'object' || Array.isArray(preferences)) {
      return res.status(400).json({
        success: false,
        error: 'Preferences must be an object'
      });
    }

    await db.collection('users').doc(req.user.uid).update({
      preferences: preferences,
      updatedAt: new Date().toISOString(),
    });

    res.json({
      success: true,
      message: 'Preferences updated successfully'
    });
  } catch (error) {
    console.error('Error updating preferences:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Update specific preference value
exports.updatePreference = async (req, res) => {
  try {
    const { key, value } = req.body;

    if (!key || typeof key !== 'string') {
      return res.status(400).json({
        success: false,
        error: 'Preference key is required and must be a string'
      });
    }

    // Get current preferences
    const userDoc = await db.collection('users').doc(req.user.uid).get();
    const preferences = userDoc.data()?.preferences || {};

    // Update specific key
    preferences[key] = value;

    await db.collection('users').doc(req.user.uid).update({
      preferences: preferences,
      updatedAt: new Date().toISOString(),
    });

    res.json({
      success: true,
      message: `Preference '${key}' updated successfully`
    });
  } catch (error) {
    console.error('Error updating preference:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Get user by ID (public profile)
exports.getUserById = async (req, res) => {
  try {
    const { userId } = req.params;

    const userDoc = await db.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    // Return only public information
    const userData = userDoc.data();
    const publicData = {
      uid: userData.uid,
      displayName: userData.displayName,
      profileImageUrl: userData.profileImageUrl,
    };

    res.json({
      success: true,
      data: publicData
    });
  } catch (error) {
    console.error('Error getting user by ID:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Get user by email
exports.getUserByEmail = async (req, res) => {
  try {
    const { email } = req.query;

    if (!email) {
      return res.status(400).json({
        success: false,
        error: 'Email is required'
      });
    }

    const snapshot = await db.collection('users')
      .where('email', '==', email)
      .limit(1)
      .get();

    if (snapshot.empty) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    const userData = snapshot.docs[0].data();

    // Return only public information
    const publicData = {
      uid: userData.uid,
      displayName: userData.displayName,
      email: userData.email,
      profileImageUrl: userData.profileImageUrl,
    };

    res.json({
      success: true,
      data: publicData
    });
  } catch (error) {
    console.error('Error getting user by email:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Search users by display name
exports.searchUsers = async (req, res) => {
  try {
    const { query, limit = 10 } = req.query;

    if (!query || query.trim().length < 2) {
      return res.status(400).json({
        success: false,
        error: 'Search query must be at least 2 characters'
      });
    }

    const searchQuery = query.trim();
    const snapshot = await db.collection('users')
      .where('displayName', '>=', searchQuery)
      .where('displayName', '<=', searchQuery + '\uf8ff')
      .limit(parseInt(limit))
      .get();

    const users = snapshot.docs.map(doc => {
      const data = doc.data();
      return {
        uid: data.uid,
        displayName: data.displayName,
        email: data.email,
        profileImageUrl: data.profileImageUrl,
      };
    });

    res.json({
      success: true,
      data: users,
      count: users.length
    });
  } catch (error) {
    console.error('Error searching users:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};


// Get multiple users by IDs
exports.getUsersByIds = async (req, res) => {
  try {
    const { userIds } = req.body;

    if (!Array.isArray(userIds) || userIds.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'User IDs array is required'
      });
    }

    if (userIds.length > 10) {
      return res.status(400).json({
        success: false,
        error: 'Maximum 10 user IDs allowed per request'
      });
    }

    const users = [];

    // Fetch users in batch (Firestore 'in' query supports max 10 items)
    const snapshot = await db.collection('users')
      .where('__name__', 'in', userIds)
      .get();

    snapshot.forEach(doc => {
      const data = doc.data();
      users.push({
        uid: data.uid,
        displayName: data.displayName,
        email: data.email,
        profileImageUrl: data.profileImageUrl,
      });
    });

    res.json({
      success: true,
      data: users,
      count: users.length
    });
  } catch (error) {
    console.error('Error getting users by IDs:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Update last login timestamp
exports.updateLastLogin = async (req, res) => {
  try {
    await db.collection('users').doc(req.user.uid).update({
      lastLogin: new Date().toISOString(),
    });

    res.json({
      success: true,
      message: 'Last login updated'
    });
  } catch (error) {
    console.error('Error updating last login:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Check if user exists
exports.checkUserExists = async (req, res) => {
  try {
    const { userId } = req.params;

    const userDoc = await db.collection('users').doc(userId).get();

    res.json({
      success: true,
      exists: userDoc.exists
    });
  } catch (error) {
    console.error('Error checking user exists:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};

// Get user statistics
exports.getUserStats = async (req, res) => {
  try {
    const userId = req.user.uid;

    // Get counts from various collections
    const [projectsSnapshot, designsSnapshot, favoritesSnapshot] = await Promise.all([
      db.collection('projects').where('userId', '==', userId).count().get(),
      db.collection('designs').where('userId', '==', userId).count().get(),
      db.collection('users').doc(userId).collection('favorites').count().get(),
    ]);

    const stats = {
      projectsCount: projectsSnapshot.data().count || 0,
      designsCount: designsSnapshot.data().count || 0,
      favoritesCount: favoritesSnapshot.data().count || 0,
    };

    res.json({
      success: true,
      data: stats
    });
  } catch (error) {
    console.error('Error getting user stats:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};


// Delete user account (CAUTION!)
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

    // Delete user's favorites subcollection
    const favoritesSnapshot = await db.collection('users')
      .doc(userId)
      .collection('favorites')
      .get();

    const favoriteDeletions = favoritesSnapshot.docs.map(doc => doc.ref.delete());
    await Promise.all(favoriteDeletions);

    // Delete user's recently viewed subcollection
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

    res.json({
      success: true,
      message: 'Account deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting account:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};