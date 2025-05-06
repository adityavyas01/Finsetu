const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const authMiddleware = require('../middleware/authMiddleware');

// Get all users
router.get('/', authMiddleware, async (req, res) => {
  try {
    const users = await prisma.user.findMany({
      select: {
        id: true,
        username: true,
        phoneNumber: true,
        isPhoneVerified: true,
      },
    });

    // Convert IDs to strings
    const formattedUsers = users.map(user => ({
      ...user,
      id: user.id.toString()
    }));

    res.json({
      success: true,
      data: formattedUsers,
    });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch users',
    });
  }
});

module.exports = router; 