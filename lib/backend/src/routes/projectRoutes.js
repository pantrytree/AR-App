const express = require('express');
const router = express.Router();
const projectController = require('../controllers/projectController');
const { verifyToken } = require('../middleware/auth');

// All routes require authentication
router.use(verifyToken);

// GET /api/projects
router.get('/', projectController.getProjects);

// POST /api/projects
router.post('/', projectController.createProject);

// GET /api/projects/:projectId
router.get('/:projectId', projectController.getProject);

// PUT /api/projects/:projectId
router.put('/:projectId', projectController.updateProject);

// DELETE /api/projects/:projectId
router.delete('/:projectId', projectController.deleteProject);

// POST /api/projects/:projectId/items
router.post('/:projectId/items', projectController.addItemToProject);

// DELETE /api/projects/:projectId/items/:itemId
router.delete('/:projectId/items/:itemId', projectController.removeItemFromProject);

// GET /api/projects/:projectId/items
router.get('/:projectId/items', projectController.getProjectItems);

// POST /api/projects/:projectId/share
router.post('/:projectId/share', projectController.shareProject);

// GET /api/projects/:projectId/collaborators
router.get('/:projectId/collaborators', projectController.getCollaborators);

module.exports = router;