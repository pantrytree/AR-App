class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode; // HTTP status code for error responses
    this.isOperational = true; // Marks error as expected/handled vs programmer error
    Error.captureStackTrace(this, this.constructor); // Clean stack trace excluding constructor
  }
}

// Specific error types for common HTTP status codes
class ValidationError extends AppError { constructor(message) { super(message, 400); this.name = 'ValidationError'; } } // Bad request due to invalid data
class AuthenticationError extends AppError { constructor(message) { super(message, 401); this.name = 'AuthenticationError'; } } // Invalid or missing credentials
class AuthorizationError extends AppError { constructor(message) { super(message, 403); this.name = 'AuthorizationError'; } } // Authenticated but insufficient permissions
class NotFoundError extends AppError { constructor(message) { super(message, 404); this.name = 'NotFoundError'; } } // Requested resource not found
class ConflictError extends AppError { constructor(message) { super(message, 409); this.name = 'ConflictError'; } } // Resource conflict (e.g., duplicate entry)
class InternalServerError extends AppError { constructor(message) { super(message, 500); this.name = 'InternalServerError'; } } // Generic server error

// Wraps async route handlers to automatically catch and forward errors
const asyncHandler = (fn) => { return (req, res, next) => { Promise.resolve(fn(req, res, next)).catch(next); }; };

// Centralized error handling middleware for consistent error responses
const errorHandler = (err, req, res, next) => {
  let error = { ...err }; error.message = err.message;
  console.error('Error:', { name: err.name, message: err.message, stack: err.stack, statusCode: err.statusCode }); // Log error details
  
  if (err.name === 'CastError') { const message = 'Resource not found'; error = new NotFoundError(message); } // Handle MongoDB CastErrors as not found
  if (err.code === 11000) { const message = 'Duplicate field value entered'; error = new ConflictError(message); } // Handle MongoDB duplicate key errors
  if (err.name === 'ValidationError') { const message = Object.values(err.errors).map((val) => val.message); error = new ValidationError(message); } // Handle Mongoose validation errors
  if (err.code && err.code.startsWith('auth/')) { error = new AuthenticationError(err.message); } // Handle Firebase auth errors
  
  const statusCode = error.statusCode || 500; const message = error.message || 'Internal Server Error'; // Default to 500 if no status code
  res.status(statusCode).json({ success: false, error: message, ...(process.env.NODE_ENV === 'development' && { stack: err.stack }) }); // Send error response with optional stack trace in development
};

// 404 handler for undefined routes
const notFound = (req, res, next) => { const error = new NotFoundError(`Route not found - ${req.originalUrl}`); next(error); };

// Utility functions for standardized API responses
const sendError = (res, statusCode, message) => { return res.status(statusCode).json({ success: false, message }); }; // Send error response
const sendSuccess = (res, statusCode, message, data = null) => { const response = { success: true, message }; if (data) { response.data = data; } return res.status(statusCode).json(response); }; // Send success response with optional data

module.exports = { AppError, ValidationError, AuthenticationError, AuthorizationError, NotFoundError, ConflictError, InternalServerError, asyncHandler, errorHandler, notFound, sendError, sendSuccess };
