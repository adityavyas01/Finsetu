/**
 * Central error handler for the application
 */
class ErrorHandler {
    static handleError(err, req, res, next) {
      const statusCode = err.statusCode || 500;
      
      res.status(statusCode).json({
        success: false,
        message: err.message || 'Internal server error',
        stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
      });
    }
    
    static notFoundHandler(req, res) {
      res.status(404).json({
        success: false,
        message: `Endpoint not found: ${req.originalUrl}`
      });
    }
  }
  
  module.exports = ErrorHandler;