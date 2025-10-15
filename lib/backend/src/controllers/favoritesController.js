const { db } = require('../config/firebase');

// Get user's favorites
exports.getFavorites = async (req, res) => {
  try {
    const userId = req.user.uid;

    const snapshot = await db.collection('users')
      .doc(userId)
      .collection('favorites')
      .orderBy('createdAt', 'desc')
      .get();

    const itemIds = snapshot.docs.map(doc => doc.data().itemId);

    if (itemIds.length === 0) {
      return res.json([]);
    }

    const items = [];
    for (const itemId of itemIds) {
      const itemDoc = await db.collection('furniture_items').doc(itemId).get();
      if (itemDoc.exists) {
        items.push({ id: itemDoc.id, ...itemDoc.data() });
      }
    }

    res.json(items);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Add to favorites
exports.addFavorite = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { itemId } = req.body;

    await db.collection('users')
      .doc(userId)
      .collection('favorites')
      .doc(itemId)
      .set({
        itemId,
        createdAt: new Date().toISOString()
      });

    res.json({ success: true, message: 'Added to favorites' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Remove from favorites
exports.removeFavorite = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { itemId } = req.params;

    await db.collection('users')
      .doc(userId)
      .collection('favorites')
      .doc(itemId)
      .delete();

    res.json({ success: true, message: 'Removed from favorites' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Check if item is favorite
exports.checkFavorite = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { itemId } = req.params;

    const doc = await db.collection('users')
      .doc(userId)
      .collection('favorites')
      .doc(itemId)
      .get();

    res.json({ isFavorite: doc.exists });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};