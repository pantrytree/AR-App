const { db } = require('../config/firebase');

// Get user's projects
exports.getProjects = async (req, res) => {
  try {
    const userId = req.user.uid;

    const snapshot = await db.collection('projects')
      .where('userId', '==', userId)
      .orderBy('createdAt', 'desc')
      .get();

    const projects = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    res.json(projects);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get single project
exports.getProject = async (req, res) => {
  try {
    const { projectId } = req.params;
    const userId = req.user.uid;

    const doc = await db.collection('projects').doc(projectId).get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Project not found' });
    }

    const projectData = doc.data();

    // Check if user owns project or is a collaborator
    if (projectData.userId !== userId &&
        !projectData.collaborators?.includes(userId)) {
      return res.status(403).json({ error: 'Access denied' });
    }

    res.json({ id: doc.id, ...projectData });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Create project
exports.createProject = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { name, roomType, description } = req.body;

    const projectRef = await db.collection('projects').add({
      userId,
      name,
      roomType,
      description: description || '',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      collaborators: [],
      items: [],
    });

    res.status(201).json({
      success: true,
      message: 'Project created',
      projectId: projectRef.id,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Update project
exports.updateProject = async (req, res) => {
  try {
    const { projectId } = req.params;
    const userId = req.user.uid;
    const updates = req.body;

    const doc = await db.collection('projects').doc(projectId).get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Project not found' });
    }

    if (doc.data().userId !== userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    await db.collection('projects').doc(projectId).update({
      ...updates,
      updatedAt: new Date().toISOString(),
    });

    res.json({ success: true, message: 'Project updated' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Delete project
exports.deleteProject = async (req, res) => {
  try {
    const { projectId } = req.params;
    const userId = req.user.uid;

    const doc = await db.collection('projects').doc(projectId).get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Project not found' });
    }

    if (doc.data().userId !== userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    await db.collection('projects').doc(projectId).delete();

    res.json({ success: true, message: 'Project deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Add item to project
exports.addItemToProject = async (req, res) => {
  try {
    const { projectId } = req.params;
    const { itemId } = req.body;
    const userId = req.user.uid;

    const doc = await db.collection('projects').doc(projectId).get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Project not found' });
    }

    const projectData = doc.data();

    if (projectData.userId !== userId &&
        !projectData.collaborators?.includes(userId)) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const items = projectData.items || [];
    if (!items.includes(itemId)) {
      items.push(itemId);
    }

    await db.collection('projects').doc(projectId).update({
      items,
      updatedAt: new Date().toISOString(),
    });

    res.json({ success: true, message: 'Item added to project' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Remove item from project
exports.removeItemFromProject = async (req, res) => {
  try {
    const { projectId, itemId } = req.params;
    const userId = req.user.uid;

    const doc = await db.collection('projects').doc(projectId).get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Project not found' });
    }

    const projectData = doc.data();

    if (projectData.userId !== userId &&
        !projectData.collaborators?.includes(userId)) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const items = (projectData.items || []).filter(id => id !== itemId);

    await db.collection('projects').doc(projectId).update({
      items,
      updatedAt: new Date().toISOString(),
    });

    res.json({ success: true, message: 'Item removed from project' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get project items
exports.getProjectItems = async (req, res) => {
  try {
    const { projectId } = req.params;
    const userId = req.user.uid;

    const doc = await db.collection('projects').doc(projectId).get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Project not found' });
    }

    const projectData = doc.data();

    if (projectData.userId !== userId &&
        !projectData.collaborators?.includes(userId)) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const itemIds = projectData.items || [];

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

// Share project with another user
exports.shareProject = async (req, res) => {
  try {
    const { projectId } = req.params;
    const { email } = req.body;
    const userId = req.user.uid;

    const doc = await db.collection('projects').doc(projectId).get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Project not found' });
    }

    if (doc.data().userId !== userId) {
      return res.status(403).json({ error: 'Only owner can share project' });
    }

    // Find user by email
    const userSnapshot = await db.collection('users')
      .where('email', '==', email)
      .get();

    if (userSnapshot.empty) {
      return res.status(404).json({ error: 'User not found' });
    }

    const collaboratorId = userSnapshot.docs[0].id;
    const collaborators = doc.data().collaborators || [];

    if (!collaborators.includes(collaboratorId)) {
      collaborators.push(collaboratorId);
    }

    await db.collection('projects').doc(projectId).update({
      collaborators,
      updatedAt: new Date().toISOString(),
    });

    res.json({ success: true, message: 'Project shared successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Get project collaborators
exports.getCollaborators = async (req, res) => {
  try {
    const { projectId } = req.params;
    const userId = req.user.uid;

    const doc = await db.collection('projects').doc(projectId).get();

    if (!doc.exists) {
      return res.status(404).json({ error: 'Project not found' });
    }

    const projectData = doc.data();

    if (projectData.userId !== userId &&
        !projectData.collaborators?.includes(userId)) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const collaboratorIds = projectData.collaborators || [];

    if (collaboratorIds.length === 0) {
      return res.json([]);
    }

    const collaborators = [];
    for (const collaboratorId of collaboratorIds) {
      const userDoc = await db.collection('users').doc(collaboratorId).get();
      if (userDoc.exists) {
        const userData = userDoc.data();
        collaborators.push({
          uid: userData.uid,
          displayName: userData.displayName,
          email: userData.email,
          photoUrl: userData.photoUrl,
        });
      }
    }

    res.json(collaborators);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};