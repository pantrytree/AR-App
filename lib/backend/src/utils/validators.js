const { body, param, query, validationResult } = require('express-validator');

const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array(),
    });
  }
  next();
};

const userValidation = {
  createUser: [
    body('email')
      .isEmail()
      .withMessage('Please provide a valid email')
      .normalizeEmail(),
    body('firstName')
      .trim()
      .notEmpty()
      .withMessage('First name is required')
      .isLength({ min: 2, max: 50 })
      .withMessage('First name must be between 2 and 50 characters'),
    body('lastName')
      .trim()
      .notEmpty()
      .withMessage('Last name is required')
      .isLength({ min: 2, max: 50 })
      .withMessage('Last name must be between 2 and 50 characters'),
    validate,
  ],

  updateProfile: [
    body('firstName')
      .optional()
      .trim()
      .isLength({ min: 2, max: 50 })
      .withMessage('First name must be between 2 and 50 characters'),
    body('lastName')
      .optional()
      .trim()
      .isLength({ min: 2, max: 50 })
      .withMessage('Last name must be between 2 and 50 characters'),
    body('phoneNumber')
      .optional()
      .isMobilePhone()
      .withMessage('Please provide a valid phone number'),
    validate,
  ],
};

const projectValidation = {
  createProject: [
    body('name')
      .trim()
      .notEmpty()
      .withMessage('Project name is required')
      .isLength({ min: 3, max: 100 })
      .withMessage('Project name must be between 3 and 100 characters'),
    body('description')
      .trim()
      .notEmpty()
      .withMessage('Project description is required')
      .isLength({ min: 10, max: 1000 })
      .withMessage('Description must be between 10 and 1000 characters'),
    body('isPublic')
      .optional()
      .isBoolean()
      .withMessage('isPublic must be a boolean'),
    body('tags')
      .optional()
      .isArray()
      .withMessage('Tags must be an array'),
    validate,
  ],

  updateProject: [
    body('name')
      .optional()
      .trim()
      .isLength({ min: 3, max: 100 })
      .withMessage('Project name must be between 3 and 100 characters'),
    body('description')
      .optional()
      .trim()
      .isLength({ min: 10, max: 1000 })
      .withMessage('Description must be between 10 and 1000 characters'),
    body('isPublic')
      .optional()
      .isBoolean()
      .withMessage('isPublic must be a boolean'),
    body('tags')
      .optional()
      .isArray()
      .withMessage('Tags must be an array'),
    validate,
  ],

  getProject: [
    param('id')
      .notEmpty()
      .withMessage('Project ID is required'),
    validate,
  ],
};

const designValidation = {
  createDesign: [
    body('projectId')
      .notEmpty()
      .withMessage('Project ID is required'),
    body('name')
      .trim()
      .notEmpty()
      .withMessage('Design name is required')
      .isLength({ min: 3, max: 100 })
      .withMessage('Design name must be between 3 and 100 characters'),
    body('canvasData')
      .optional()
      .isObject()
      .withMessage('Canvas data must be an object'),
    validate,
  ],

  updateDesign: [
    param('id')
      .notEmpty()
      .withMessage('Design ID is required'),
    body('name')
      .optional()
      .trim()
      .isLength({ min: 3, max: 100 })
      .withMessage('Design name must be between 3 and 100 characters'),
    body('canvasData')
      .optional()
      .isObject()
      .withMessage('Canvas data must be an object'),
    validate,
  ],

  getDesign: [
    param('id')
      .notEmpty()
      .withMessage('Design ID is required'),
    validate,
  ],
};

const designObjectValidation = {
  addDesignObject: [
    body('designId')
      .notEmpty()
      .withMessage('Design ID is required'),
    body('furnitureItemId')
      .notEmpty()
      .withMessage('Furniture item ID is required'),
    body('position')
      .optional()
      .isObject()
      .withMessage('Position must be an object'),
    body('position.x')
      .optional()
      .isFloat()
      .withMessage('Position x must be a number'),
    body('position.y')
      .optional()
      .isFloat()
      .withMessage('Position y must be a number'),
    body('position.z')
      .optional()
      .isFloat()
      .withMessage('Position z must be a number'),
    body('rotation')
      .optional()
      .isObject()
      .withMessage('Rotation must be an object'),
    body('scale')
      .optional()
      .isObject()
      .withMessage('Scale must be an object'),
    validate,
  ],

  updateDesignObject: [
    param('id')
      .notEmpty()
      .withMessage('Object ID is required'),
    body('position')
      .optional()
      .isObject()
      .withMessage('Position must be an object'),
    body('rotation')
      .optional()
      .isObject()
      .withMessage('Rotation must be an object'),
    body('scale')
      .optional()
      .isObject()
      .withMessage('Scale must be an object'),
    validate,
  ],
};

const furnitureValidation = {
  createFurniture: [
    body('name')
      .trim()
      .notEmpty()
      .withMessage('Furniture name is required')
      .isLength({ min: 3, max: 100 })
      .withMessage('Name must be between 3 and 100 characters'),
    body('description')
      .trim()
      .notEmpty()
      .withMessage('Description is required')
      .isLength({ min: 10, max: 1000 })
      .withMessage('Description must be between 10 and 1000 characters'),
    body('category')
      .trim()
      .notEmpty()
      .withMessage('Category is required'),
    body('price')
      .isFloat({ min: 0 })
      .withMessage('Price must be a positive number'),
    body('tags')
      .optional()
      .isArray()
      .withMessage('Tags must be an array'),
    validate,
  ],

  getFurniture: [
    param('id')
      .notEmpty()
      .withMessage('Furniture ID is required'),
    validate,
  ],

  searchFurniture: [
    query('query')
      .optional()
      .trim()
      .isLength({ min: 2 })
      .withMessage('Search query must be at least 2 characters'),
    validate,
  ],
};

const favoriteValidation = {
  addFavorite: [
    body('furnitureItemId')
      .notEmpty()
      .withMessage('Furniture item ID is required'),
    validate,
  ],

  removeFavorite: [
    param('furnitureItemId')
      .notEmpty()
      .withMessage('Furniture item ID is required'),
    validate,
  ],

  checkFavorite: [
    param('furnitureItemId')
      .notEmpty()
      .withMessage('Furniture item ID is required'),
    validate,
  ],
};

const collaborationValidation = {
  addCollaborator: [
    body('projectId')
      .notEmpty()
      .withMessage('Project ID is required'),
    body('userId')
      .notEmpty()
      .withMessage('User ID is required'),
    body('role')
      .optional()
      .isIn(['viewer', 'editor', 'admin'])
      .withMessage('Role must be viewer, editor, or admin'),
    validate,
  ],

  updateRole: [
    param('id')
      .notEmpty()
      .withMessage('Collaboration ID is required'),
    body('role')
      .notEmpty()
      .withMessage('Role is required')
      .isIn(['viewer', 'editor', 'admin'])
      .withMessage('Role must be viewer, editor, or admin'),
    validate,
  ],

  getCollaborators: [
    param('projectId')
      .notEmpty()
      .withMessage('Project ID is required'),
    validate,
  ],
};

const idValidation = {
  validateId: [
    param('id')
      .notEmpty()
      .withMessage('ID is required'),
    validate,
  ],
};

const isValidEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

const isValidUrl = (url) => {
  try {
    new URL(url);
    return true;
  } catch (error) {
    return false;
  }
};

const sanitizeString = (str) => {
  return str.trim().replace(/[<>]/g, '');
};

const validateObjectId = (id) => {
  return id && id.length > 0;
};

module.exports = {
  validate,
  userValidation,
  projectValidation,
  designValidation,
  designObjectValidation,
  furnitureValidation,
  favoriteValidation,
  collaborationValidation,
  idValidation,
  isValidEmail,
  isValidUrl,
  sanitizeString,
  validateObjectId,
};