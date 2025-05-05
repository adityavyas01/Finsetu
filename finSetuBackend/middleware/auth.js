const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const auth = async (req, res, next) => {
  try {
    console.log('=== Auth Middleware ===');
    console.log('Headers:', req.headers);
    
    const phoneNumber = req.headers['x-phone-number'];
    console.log('Phone Number from header:', phoneNumber);
    
    if (!phoneNumber) {
      console.log('No phone number provided in headers');
      return res.status(401).json({
        success: false,
        message: 'Authentication required. Phone number not provided.'
      });
    }

    // Verify user exists
    const user = await prisma.user.findUnique({
      where: { phoneNumber: phoneNumber }
    });
    console.log('Found user:', user ? 'Yes' : 'No');

    if (!user) {
      console.log('Invalid phone number:', phoneNumber);
      return res.status(401).json({
        success: false,
        message: 'Invalid phone number'
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