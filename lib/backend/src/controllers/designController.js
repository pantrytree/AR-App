const { db } = require('../config/firebase');

// Get user's designs
exports.getDesigns = async (req, res) => {
  try {
    const userId = req.user.uid;

    const snapshot = await db.collection('designs')
      .where('userId', '==', userId)
      .orderBy('createdAt', 'desc')
      .get();

    const designs = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    res.json(designs);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get single design
exports.getDesign = async (req, res) => {
  try {
    const { designId } = req.params;
    const userId = req.user.uid;

    const doc = await db.collection('designs').doc(designId).get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Design not found' });
    }

    if (doc.data().userId !== userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    res.json({ id: doc.id, ...doc.data() });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Create design
exports.createDesign = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { name, projectId, objects, imageUrl } = req.body;

    const designRef = await db.collection('designs').add({
      userId,
      projectId,
      name,
      objects: objects || [],
      imageUrl: imageUrl || null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    });

    res.status(201).json({
      success: true,
      message: 'Design created',
      designId: designRef.id,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Update design
exports.updateDesign = async (req, res) => {
  try {
    const { designId } = req.params;
    const userId = req.user.uid;
    const updates = req.body;

    const doc = await db.collection('designs').doc(designId).get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Design not found' });
    }

    if (doc.data().userId !== userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    await db.collection('designs').doc(designId).update({
      ...updates,
      updatedAt: new Date().toISOString(),
    });

    res.json({ success: true, message: 'Design updated' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Delete design
exports.deleteDesign = async (req, res) => {
  try {
    const { designId } = req.params;
    const userId = req.user.uid;

    const doc = await db.collection('designs').doc(designId).get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Design not found' });
    }

    if (doc.data().userId !== userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    await db.collection('designs').doc(designId).delete();

    res.json({ success: true, message: 'Design deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get designs by project
exports.getDesignsByProject = async (req, res) => {
  try {
    const { projectId } = req.params;
    const userId = req.user.uid;

    // Verify user has access to project
    const projectDoc = await db.collection('projects').doc(projectId).get();

    if (!projectDoc.exists) {
      return res.status(404).json({ error: 'Project not found' });
    }

    const projectData = projectDoc.data();

    if (projectData.userId !== userId &&
        !projectData.collaborators?.includes(userId)) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const snapshot = await db.collection('designs')
      .where('projectId', '==', projectId)
      .orderBy('createdAt', 'desc')
      .get();

    const designs = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    res.json(designs);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};