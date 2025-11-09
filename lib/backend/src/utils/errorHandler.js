// Base error class for application-specific errors with HTTP status codes
class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode; // HTTP status code for error responses
    this.isOperational = true; // Marks error as expected/handled vs programmer error

    Error.captureStackTrace(this, this.constructor); // Clean stack trace excluding constructor
  }
}

// Specific error types for common HTTP status codes
class ValidationError extends AppError { 
  constructor(message) { 
    super(message, 400); // 400 Bad Request
    this.name = 'ValidationError'; 
  } 
}

class AuthenticationError extends AppError { 
  constructor(message) { 
    super(message, 401); // 401 Unauthorized
    this.name = 'AuthenticationError'; 
  } 
}

class AuthorizationError extends AppError { 
  constructor(message) { 
    super(message, 403); // 403 Forbidden
    this.name = 'AuthorizationError'; 
  } 
}

class NotFoundError extends AppError { 
  constructor(message) { 
    super(message, 404); // 404 Not Found
    this.name = 'NotFoundError'; 
  } 
}

class ConflictError extends AppError { 
  constructor(message) { 
    super(message, 409); // 409 Conflict
    this.name = 'ConflictError'; 
  } 
}

class InternalServerError extends AppError { 
  constructor(message) { 
    super(message, 500); // 500 Internal Server Error
    this.name = 'InternalServerError'; 
  } 
}

// Wraps async route handlers to automatically catch and forward errors
const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

// Centralized error handling middleware for consistent error responses
const errorHandler = (err, req, res, next) => {
  let error = { ...err };
  error.message = err.message;

  // Log error details for debugging
  console.error('Error:', {
    name: err.name,
    message: err.message,
    stack: err.stack,
    statusCode: err.statusCode,
  });

  // Handle specific error types
  if (err.name === 'CastError') {
    const message = 'Resource not found';
    error = new NotFoundError(message); // Handle MongoDB CastErrors as not found
  }

  if (err.code === 11000) {
    const message = 'Duplicate field value entered';
    error = new ConflictError(message); // Handle MongoDB duplicate key errors
  }

  if (err.name === 'ValidationError') {
    const message = Object.values(err.errors).map((val) => val.message);
    error = new ValidationError(message); // Handle Mongoose validation errors
  }

  if (err.code && err.code.startsWith('auth/')) {
    error = new AuthenticationError(err.message); // Handle Firebase auth errors
  }

  // Send error response to client
  const statusCode = error.statusCode || 500;
  const message = error.message || 'Internal Server Error';

  res.status(statusCode).json({
    success: false,
    error: message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }), // Include stack trace only in development
  });
};

// 404 handler for undefined routes
const notFound = (req, res, next) => {
  const error = new NotFoundError(`Route not found - ${req.originalUrl}`);
  next(error);
};

// Utility function for sending error responses
const sendError = (res, statusCode, message) => {
  return res.status(statusCode).json({
    success: false,
    message,
  });
};

// Utility function for sending success responses with optional data
const sendSuccess = (res, statusCode, message, data = null) => {
  const response = {
    success: true,
    message,
  };

  if (data) {
    response.data = data; // Include data if provided
  }

  return res.status(statusCode).json(response);
};

module.exports = {
  AppError,
  ValidationError,
  AuthenticationError,
  AuthorizationError,
  NotFoundError,
  ConflictError,
  InternalServerError,
  asyncHandler,
  errorHandler,
  notFound,
  sendError,
  sendSuccess,
};
