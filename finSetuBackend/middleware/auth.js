const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const auth = async (req, res, next) => {
  try {
    console.log('=== Auth Middleware ===');
    console.log('Headers:', req.headers);
    
    const userId = req.headers['x-user-id'];
    console.log('User ID from header:', userId);
    
    if (!userId) {
      console.log('No user ID provided in headers');
      return res.status(401).json({
        success: false,
        message: 'Authentication required. User ID not provided.'
      });
    }

    // Verify user exists
    const user = await prisma.user.findUnique({
      where: { id: parseInt(userId) }
    });
    console.log('Found user:', user ? 'Yes' : 'No');

    if (!user) {
      console.log('Invalid user ID:', userId);
      return res.status(401).json({
        success: false,
        message: 'Invalid user ID'
      });
    }

    // Add user to request object
    req.user = user;
    console.log('Authentication successful for user:', user.id);
    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error during authentication'
    });
  }
};

module.exports = auth; 