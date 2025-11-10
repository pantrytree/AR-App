const { body, param, query, validationResult } = require('express-validator');
const DOMPurify = require('dompurify');
const { JSDOM } = require('jsdom');

// Initialize DOMPurify
const window = new JSDOM('').window;
const domPurify = DOMPurify(window);

// Middleware to check validation results and send error response if validation fails
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

const sanitizeString = (str) => {
  if (typeof str !== 'string') return '';

  return domPurify.sanitize(
    str.trim()
      .replace(/[<>'"`;|&${}\[\]()\\\/%=?]/g, '')
      .substring(0, 1000)
  );
};

const sanitizeHtml = (html) => {
  if (typeof html !== 'string') return '';

  return domPurify.sanitize(html, {
    ALLOWED_TAGS: [], 
    ALLOWED_ATTR: [], 
    FORBID_TAGS: ['style', 'script', 'iframe', 'object', 'embed', 'link'],
    FORBID_ATTR: ['style', 'onerror', 'onload', 'onclick']
  });
};

const sanitizeArray = (arr) => {
  if (!Array.isArray(arr)) return [];
  return arr.map(item =>
    typeof item === 'string' ? sanitizeString(item) : item
  ).filter(item => item !== '').slice(0, 20); // Limit array size
};

const isValidSafeUrl = (url) => {
  try {
    const parsed = new URL(url);

    //Only allow HTTP/HTTPS URLs
    if (!['http:', 'https:'].includes(parsed.protocol)) {
      return false;
    }

    //Prevent internal URLs in production
    if (process.env.NODE_ENV === 'production') {
      const hostname = parsed.hostname;
      const forbiddenHosts = [
        'localhost', '127.0.0.1', '0.0.0.0',
        '192.168.', '10.', '172.16.', '172.31.',
        '169.254.', '::1', 'fc00:', 'fd00:'
      ];

      if (forbiddenHosts.some(forbidden => hostname.startsWith(forbidden)) ||
          hostname.endsWith('.local') ||
          hostname.endsWith('.internal')) {
        return false;
      }
    }

    //Validate URL length and structure
    if (url.length > 2048) return false;
    if (!parsed.hostname.includes('.')) return false;

    return true;
  } catch (error) {
    return false;
  }
};

const validateObjectSize = (obj, maxSizeKB = 10) => {
  try {
    const jsonSize = Buffer.byteLength(JSON.stringify(obj), 'utf8');
    return jsonSize <= (maxSizeKB * 1024);
  } catch {
    return false;
  }
};

const sanitizeObject = (obj, maxDepth = 5) => {
  const sanitizeRecursive = (currentObj, depth) => {
    if (depth > maxDepth) return '[DEPTH_LIMIT_EXCEEDED]';

    if (typeof currentObj === 'string') {
      return sanitizeString(currentObj);
    } else if (Array.isArray(currentObj)) {
      return sanitizeArray(currentObj);
    } else if (currentObj && typeof currentObj === 'object') {
      const sanitized = {};
      for (const [key, value] of Object.entries(currentObj)) {
        const safeKey = sanitizeString(key);
        if (safeKey) {
          sanitized[safeKey] = sanitizeRecursive(value, depth + 1);
        }
      }
      return sanitized;
    }
    return currentObj;
  };

  return sanitizeRecursive(obj, 0);
};

//Security headers middleware
const securityHeaders = (req, res, next) => {
  //Prevent XSS
  res.setHeader('X-XSS-Protection', '1; mode=block');
  //Prevent MIME type sniffing
  res.setHeader('X-Content-Type-Options', 'nosniff');
  //Prevent clickjacking
  res.setHeader('X-Frame-Options', 'DENY');
  //Referrer policy
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  //Content Security Policy
  res.setHeader(
    'Content-Security-Policy',
    "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:;"
  );
  next();
};

//Validation rules for user-related operations
const userValidation = {
  createUser: [
    body('email')
      .isEmail()
      .withMessage('Please provide a valid email')
      .normalizeEmail()
      .customSanitizer(email => email.toLowerCase())
      .isLength({ max: 254 })
      .withMessage('Email too long'),
    body('firstName')
      .trim()
      .notEmpty()
      .withMessage('First name is required')
      .isLength({ min: 2, max: 50 })
      .withMessage('First name must be between 2 and 50 characters')
      .customSanitizer(sanitizeString)
      .escape(),
    body('lastName')
      .trim()
      .notEmpty()
      .withMessage('Last name is required')
      .isLength({ min: 2, max: 50 })
      .withMessage('Last name must be between 2 and 50 characters')
      .customSanitizer(sanitizeString)
      .escape(),
  ],

  updateProfile: [
    body('firstName')
      .optional()
      .trim()
      .isLength({ min: 2, max: 50 })
      .withMessage('First name must be between 2 and 50 characters')
      .customSanitizer(sanitizeString)
      .escape(),
    body('lastName')
      .optional()
      .trim()
      .isLength({ min: 2, max: 50 })
      .withMessage('Last name must be between 2 and 50 characters')
      .customSanitizer(sanitizeString)
      .escape(),
    body('avatar')
      .optional()
      .custom(isValidSafeUrl)
      .withMessage('Please provide a valid avatar URL'),
    validate,
  ],
};

//Validation rules for project management operations
const projectValidation = {
  createProject: [
    body('name')
      .trim()
      .notEmpty()
      .withMessage('Project name is required')
      .isLength({ min: 3, max: 100 })
      .withMessage('Project name must be between 3 and 100 characters')
      .customSanitizer(sanitizeString)
      .escape(),
    body('description')
      .trim()
      .notEmpty()
      .withMessage('Project description is required')
      .isLength({ min: 10, max: 1000 })
      .withMessage('Description must be between 10 and 1000 characters')
      .customSanitizer(sanitizeString)
      .escape(),
    body('isPublic')
      .optional()
      .isBoolean()
      .withMessage('isPublic must be a boolean'),
    body('tags')
      .optional()
      .isArray()
      .withMessage('Tags must be an array')
      .custom((tags) => {
        if (tags && tags.length > 10) {
          throw new Error('Maximum 10 tags allowed');
        }
        return true;
      })
      .customSanitizer(sanitizeArray),
    body('thumbnail')
      .optional()
      .custom(isValidSafeUrl)
      .withMessage('Please provide a valid thumbnail URL'),
    validate,
  ],

  updateProject: [
    body('name')
      .optional()
      .trim()
      .isLength({ min: 3, max: 100 })
      .withMessage('Project name must be between 3 and 100 characters')
      .customSanitizer(sanitizeString)
      .escape(),
    body('description')
      .optional()
      .trim()
      .isLength({ min: 10, max: 1000 })
      .withMessage('Description must be between 10 and 1000 characters')
      .customSanitizer(sanitizeString)
      .escape(),
    body('isPublic')
      .optional()
      .isBoolean()
      .withMessage('isPublic must be a boolean'),
    body('tags')
      .optional()
      .isArray()
      .withMessage('Tags must be an array')
      .custom((tags) => {
        if (tags && tags.length > 10) {
          throw new Error('Maximum 10 tags allowed');
        }
        return true;
      })
      .customSanitizer(sanitizeArray),
    validate,
  ],

  getProject: [
    param('id')
      .notEmpty()
      .withMessage('Project ID is required')
      .withMessage('Invalid project ID format'),
    validate,
  ],
};

//Validation rules for design creation and management
const designValidation = {
  createDesign: [
    body('projectId')
      .notEmpty()
      .withMessage('Project ID is required')
      .withMessage('Invalid project ID format'),
    body('name')
      .trim()
      .notEmpty()
      .withMessage('Design name is required')
      .isLength({ min: 3, max: 100 })
      .withMessage('Design name must be between 3 and 100 characters')
      .customSanitizer(sanitizeString)
      .escape(),
    body('description')
      .optional()
      .trim()
      .isLength({ max: 500 })
      .withMessage('Description must be less than 500 characters')
      .customSanitizer(sanitizeString)
      .escape(),
    body('canvasData')
      .optional()
      .isObject()
      .withMessage('Canvas data must be an object')
      .custom((obj) => {
        if (!validateObjectSize(obj, 100)) {
          throw new Error('Canvas data too large');
        }
        return true;
      })
      .customSanitizer(sanitizeObject),
    validate,
  ],

  updateDesign: [
    param('id')
      .notEmpty()
      .withMessage('Design ID is required')
      .withMessage('Invalid design ID format'),
    body('name')
      .optional()
      .trim()
      .isLength({ min: 3, max: 100 })
      .withMessage('Design name must be between 3 and 100 characters')
      .customSanitizer(sanitizeString)
      .escape(),
    body('description')
      .optional()
      .trim()
      .isLength({ max: 500 })
      .withMessage('Description must be less than 500 characters')
      .customSanitizer(sanitizeString)
      .escape(),
    body('canvasData')
      .optional()
      .isObject()
      .withMessage('Canvas data must be an object')
      .custom((obj) => {
        if (!validateObjectSize(obj, 100)) {
          throw new Error('Canvas data too large');
        }
        return true;
      })
      .customSanitizer(sanitizeObject),
    validate,
  ],

  getDesign: [
    param('id')
      .notEmpty()
      .withMessage('Design ID is required')
      .withMessage('Invalid design ID format'),
    validate,
  ],
};

// Validation rules for 3D design object positioning and manipulation
const designObjectValidation = {
  addDesignObject: [
    body('designId')
      .notEmpty()
      .withMessage('Design ID is required')
      .withMessage('Invalid design ID format'),
    body('furnitureItemId')
      .notEmpty()
      .withMessage('Furniture item ID is required')
      .withMessage('Invalid furniture item ID format'),
    body('position')
      .optional()
      .isObject()
      .withMessage('Position must be an object')
      .custom((pos) => {
        const maxValue = 1000000;
        if (pos.x && (typeof pos.x !== 'number' || !isFinite(pos.x) || Math.abs(pos.x) > maxValue)) {
          throw new Error('Invalid position x coordinate');
        }
        if (pos.y && (typeof pos.y !== 'number' || !isFinite(pos.y) || Math.abs(pos.y) > maxValue)) {
          throw new Error('Invalid position y coordinate');
        }
        if (pos.z && (typeof pos.z !== 'number' || !isFinite(pos.z) || Math.abs(pos.z) > maxValue)) {
          throw new Error('Invalid position z coordinate');
        }
        return true;
      }),
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
      .withMessage('Object ID is required')
      .withMessage('Invalid object ID format'),
    body('position')
      .optional()
      .isObject()
      .withMessage('Position must be an object')
      .custom((pos) => {
        const maxValue = 1000000;
        if (pos.x && (typeof pos.x !== 'number' || !isFinite(pos.x) || Math.abs(pos.x) > maxValue)) {
          throw new Error('Invalid position x coordinate');
        }
        if (pos.y && (typeof pos.y !== 'number' || !isFinite(pos.y) || Math.abs(pos.y) > maxValue)) {
          throw new Error('Invalid position y coordinate');
        }
        if (pos.z && (typeof pos.z !== 'number' || !isFinite(pos.z) || Math.abs(pos.z) > maxValue)) {
          throw new Error('Invalid position z coordinate');
        }
        return true;
      }),
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

//Validation rules for furniture catalogue management
const furnitureValidation = {
  createFurniture: [
    body('name')
      .trim()
      .notEmpty()
      .withMessage('Furniture name is required')
      .isLength({ min: 3, max: 100 })
      .withMessage('Name must be between 3 and 100 characters')
      .customSanitizer(sanitizeString)
      .escape(),
    body('description')
      .trim()
      .notEmpty()
      .withMessage('Description is required')
      .isLength({ min: 10, max: 1000 })
      .withMessage('Description must be between 10 and 1000 characters')
      .customSanitizer(sanitizeString)
      .escape(),
    body('category')
      .trim()
      .notEmpty()
      .withMessage('Category is required')
      .customSanitizer(sanitizeString)
      .escape(),
   body('dimensions')
      .optional()
      .isObject()
      .withMessage('Dimensions must be an object'),
    body('modelUrl')
      .optional()
      .custom(isValidSafeUrl)
      .withMessage('Please provide a valid model URL'),
    body('thumbnailUrl')
      .optional()
      .custom(isValidSafeUrl)
      .withMessage('Please provide a valid thumbnail URL'),
    body('tags')
      .optional()
      .isArray()
      .withMessage('Tags must be an array')
      .customSanitizer(sanitizeArray),
    validate,
  ],

  updateFurniture: [
    param('id')
      .notEmpty()
      .withMessage('Furniture ID is required')
      .withMessage('Invalid furniture ID format'),
    body('name')
      .optional()
      .trim()
      .isLength({ min: 3, max: 100 })
      .withMessage('Name must be between 3 and 100 characters')
      .customSanitizer(sanitizeString)
      .escape(),
    body('description')
      .optional()
      .trim()
      .isLength({ min: 10, max: 1000 })
      .withMessage('Description must be between 10 and 1000 characters')
      .customSanitizer(sanitizeString)
      .escape(),
    body('category')
      .optional()
      .trim()
      .notEmpty()
      .withMessage('Category is required')
      .customSanitizer(sanitizeString)
      .escape(),
   body('tags')
      .optional()
      .isArray()
      .withMessage('Tags must be an array')
      .customSanitizer(sanitizeArray),
    validate,
  ],

  getFurniture: [
    param('id')
      .notEmpty()
      .withMessage('Furniture ID is required')
      .withMessage('Invalid furniture ID format'),
    validate,
  ],

  searchFurniture: [
    query('query')
      .optional()
      .trim()
      .isLength({ min: 2, max: 100 })
      .withMessage('Search query must be between 2 and 100 characters')
      .customSanitizer(sanitizeString),
    query('category')
      .optional()
      .trim()
      .isLength({ max: 50 })
      .withMessage('Category filter too long')
      .customSanitizer(sanitizeString),
    query('page')
      .optional()
      .isInt({ min: 1, max: 1000 })
      .withMessage('Page must be a positive integer'),
    query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .withMessage('Limit must be between 1 and 100'),
    validate,
  ],
};

//Validation rules for user favorite management
const favoriteValidation = {
  addFavorite: [
    body('furnitureItemId')
      .notEmpty()
      .withMessage('Furniture item ID is required')
      .withMessage('Invalid furniture item ID format'),
    validate,
  ],

  removeFavorite: [
    param('furnitureItemId')
      .notEmpty()
      .withMessage('Furniture item ID is required')
      .withMessage('Invalid furniture item ID format'),
    validate,
  ],

  checkFavorite: [
    param('furnitureItemId')
      .notEmpty()
      .withMessage('Furniture item ID is required')
      .withMessage('Invalid furniture item ID format'),
    validate,
  ],
};

//Validation rules for project collaboration features
const collaborationValidation = {
  addCollaborator: [
    body('projectId')
      .notEmpty()
      .withMessage('Project ID is required')
      .withMessage('Invalid project ID format'),
    body('userId')
      .notEmpty()
      .withMessage('User ID is required')
      .withMessage('Invalid user ID format'),
    body('role')
      .optional()
      .isIn(['viewer', 'editor', 'admin'])
      .withMessage('Role must be viewer, editor, or admin'),
    validate,
  ],

  updateRole: [
    param('id')
      .notEmpty()
      .withMessage('Collaboration ID is required')
      .withMessage('Invalid collaboration ID format'),
    body('role')
      .notEmpty()
      .withMessage('Role is required')
      .isIn(['viewer', 'editor', 'admin'])
      .withMessage('Role must be viewer, editor, or admin'),
    validate,
  ],

  removeCollaborator: [
    param('id')
      .notEmpty()
      .withMessage('Collaboration ID is required')
      .withMessage('Invalid collaboration ID format'),
    validate,
  ],

  getCollaborators: [
    param('projectId')
      .notEmpty()
      .withMessage('Project ID is required')
      .withMessage('Invalid project ID format'),
    validate,
  ],
};

//Generic ID validation for route parameters
const idValidation = {
  validateId: [
    param('id')
      .notEmpty()
      .withMessage('ID is required')
      .withMessage('Invalid ID format'),
    validate,
  ],
};

//Enhanced utility validation functions
const isValidEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email) && email.length <= 254;
};

const isValidUrl = isValidSafeUrl;

const createRateLimit = (windowMs, max, message) => ({
  windowMs,
  max,
  message: { success: false, message },
  standardHeaders: true,
  legacyHeaders: false,
});

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
  securityHeaders,
  sanitizeHtml,
  sanitizeArray,
  sanitizeObject,
  validateObjectSize,
  isValidSafeUrl,
  createRateLimit,
};
