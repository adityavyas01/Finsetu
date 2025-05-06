const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const authMiddleware = async (req, res, next) => {
  try {
    console.log('=== Auth Middleware ===');
    console.log('Headers:', req.headers);
    
    const userId = req.headers['x-user-id'];
    console.log('User ID from header:', userId);

    if (!userId) {
      console.log('No user ID provided in headers');
      return res.status(401).json({
        success: false,
        message: 'Authentication required. No user ID provided.'
      });
    }

    // Verify user exists
    const user = await prisma.user.findUnique({
      where: { id: parseInt(userId) }
    });

    if (!user) {
      console.log('Invalid user ID:', userId);
      return res.status(401).json({
        success: false,
        message: 'Invalid user ID'
      });
    }

    console.log('User authenticated:', user);
    req.user = user;
    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

module.exports = authMiddleware; 