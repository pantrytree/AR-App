const { db } = require('../config/firebase');

// Get all furniture with filters
exports.getAllFurniture = async (req, res) => {
  try {
    const { category, roomType, minPrice, maxPrice } = req.query;

    let query = db.collection('furnitureItem');

    if (category) query = query.where('category', '==', category);
    if (roomType) query = query.where('roomType', '==', roomType);

    const snapshot = await query.get();
    const items = [];

    res.json(items);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get furniture by ID
exports.getFurnitureById = async (req, res) => {
  try {
    const doc = await db.collection('furnitureItem').doc(req.params.id).get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Item not found' });
    }

    res.json({ id: doc.id, ...doc.data() });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Search furniture
exports.searchFurniture = async (req, res) => {
  try {
    const { q } = req.query;

    if (!q) {
      return res.status(400).json({ error: 'Search query required' });
    }

    const snapshot = await db.collection('furnitureItem').get();
    const items = [];

    snapshot.forEach(doc => {
      const data = doc.data();
      const searchStr = `${data.name} ${data.description} ${data.category}`.toLowerCase();

      if (searchStr.includes(q.toLowerCase())) {
        items.push({ id: doc.id, ...data });
      }
    });

    res.json(items);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get featured furniture
exports.getFeaturedFurniture = async (req, res) => {
  try {
    const snapshot = await db.collection('furnitureItem')
      .where('featured', '==', true)
      .limit(10)
      .get();

    const items = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

    res.json(items);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get furniture by room type
exports.getFurnitureByRoom = async (req, res) => {
  try {
    const { roomType } = req.params;

    const snapshot = await db.collection('furnitureItem')
      .where('roomType', '==', roomType)
      .get();

    const items = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

    res.json(items);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get recently viewed items
exports.getRecentlyViewed = async (req, res) => {
  try {
    const userId = req.user.uid;

    const recentDocs = await db.collection('users')
      .doc(userId)
      .collection('recently_viewed')
      .orderBy('viewedAt', 'desc')
      .limit(10)
      .get();

    const itemIds = recentDocs.docs.map(doc => doc.data().itemId);

    if (itemIds.length === 0) {
      return res.json([]);
    }

    const items = [];
    for (const itemId of itemIds) {
      const itemDoc = await db.collection('furnitureItem').doc(itemId).get();
      if (itemDoc.exists) {
        items.push({ id: itemDoc.id, ...itemDoc.data() });
      }
    }

    res.json(items);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Track item view
exports.trackView = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { itemId } = req.body;

    await db.collection('users')
      .doc(userId)
      .collection('recently_viewed')
      .doc(itemId)
      .set({
        itemId,
        viewedAt: new Date().toISOString()
      }, { merge: true });

    res.json({ message: 'View tracked' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
