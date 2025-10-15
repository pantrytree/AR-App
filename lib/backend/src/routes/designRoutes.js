const express = require('express');
const router = express.Router();
const designController = require('../controllers/designController');
const { verifyToken } = require('../middleware/auth');

// All routes require authentication
router.use(verifyToken);

// GET /api/designs
router.get('/', designController.getDesigns);

// POST /api/designs
router.post('/', designController.createDesign);

// GET /api/designs/project/:projectId
router.get('/project/:projectId', designController.getDesignsByProject);

// GET /api/designs/:designId
router.get('/:designId', designController.getDesign);

// PUT /api/designs/:designId
router.put('/:designId', designController.updateDesign);

// DELETE /api/designs/:designId
router.delete('/:designId', designController.deleteDesign);

module.exports = router;