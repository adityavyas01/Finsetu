const bcrypt = require('bcrypt');
const User = require('../models/userModel');
const OtpService = require('../services/otpService');
const SmsService = require('../services/smsService');
const { bcryptSaltRounds } = require('../config/environment');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

// Register a new user and generate OTP
exports.register = async (req, res) => {
  try {
    const { username, phoneNumber, password } = req.body;
    
    // Validate required fields
    if (!username || !phoneNumber || !password) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields'
      });
    }
    
    // Check if username already exists
    const existingUsername = await prisma.user.findFirst({
      where: {
        username
      }
    });
    
    if (existingUsername) {
      return res.status(400).json({
        success: false,
        message: 'Username already exists'
      });
    }
    
    // Check if phone number already exists
    const existingPhone = await prisma.user.findFirst({
      where: {
        phoneNumber
      }
    });
    
    if (existingPhone) {
      return res.status(400).json({
        success: false,
        message: 'Phone number already registered'
      });
    }
    
    // Hash password
    const hashedPassword = await bcrypt.hash(password, bcryptSaltRounds);
    
    // Create user
    const user = await prisma.user.create({
      data: {
        username,
        phoneNumber,
        password: hashedPassword,
        isPhoneVerified: false
      }
    });
    
    // Generate and send OTP
    const otp = await OtpService.generateOtp(user.id);
    
    return res.status(201).json({
      success: true,
      message: 'Registration initiated. Please verify your phone number.',
      data: {
        userId: user.id.toString(),
        phoneNumber: phoneNumber,
        otp: otp // Return OTP for development/testing
      }
    });
  } catch (error) {
    console.error('Registration error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error during registration',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// Verify OTP
exports.verifyOtp = async (req, res) => {
  try {
    const { userId, phoneNumber, otp } = req.body;
    
    console.log('=== OTP Verification Request ===');
    console.log('Request Body:', req.body);
    
    // Validate required fields
    if (!otp) {
      return res.status(400).json({
        success: false,
        message: 'Missing required field: otp'
      });
    }

    // If userId is null or undefined, try to find user by phoneNumber
    let user;
    if (!userId || userId === 'null') {
      if (!phoneNumber) {
        return res.status(400).json({
          success: false,
          message: 'Either userId or phoneNumber must be provided'
        });
      }
      user = await prisma.user.findFirst({
        where: {
          phoneNumber
        }
      });
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found with the provided phone number'
        });
      }
    } else {
      // Convert userId to integer
      const userIdInt = parseInt(userId);
      if (isNaN(userIdInt)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid userId format'
        });
      }
      user = await prisma.user.findUnique({
        where: {
          id: userIdInt
        }
      });
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found with the provided userId'
        });
      }
    }

    // Verify OTP
    const isValid = await OtpService.verifyOtp(user.id, otp);
    
    if (isValid) {
      // Update user verification status
      await prisma.user.update({
        where: {
          id: user.id
        },
        data: {
          isPhoneVerified: true
        }
      });
      
      return res.status(200).json({
        success: true,
        message: 'OTP verified successfully',
        data: {
          userId: user.id.toString(),
          isPhoneVerified: true
        }
      });
    } else {
      return res.status(400).json({
        success: false,
        message: 'Invalid or expired OTP'
      });
    }
  } catch (error) {
    console.error('OTP verification error:', error);
    
    // Handle specific error cases
    if (error.message.includes('Missing required fields')) {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }
    
    if (error.message.includes('Invalid userId format')) {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }
    
    if (error.message.includes('Invalid or expired OTP')) {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }
    
    if (error.message.includes('User not found')) {
      return res.status(404).json({
        success: false,
        message: error.message
      });
    }
    
    return res.status(500).json({
      success: false,
      message: 'OTP verification failed',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// Resend OTP
exports.resendOtp = async (req, res) => {
  try {
    const { userId, phoneNumber } = req.body;
    
    // Validate required fields
    if (!userId && !phoneNumber) {
      return res.status(400).json({
        success: false,
        message: 'Either userId or phoneNumber must be provided'
      });
    }
    
    // Find user by userId or phoneNumber
    let user;
    if (userId && userId !== 'null') {
      user = await prisma.user.findUnique({
        where: {
          id: parseInt(userId)
        }
      });
    } else if (phoneNumber) {
      user = await prisma.user.findFirst({
        where: {
          phoneNumber
        }
      });
    }
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    // Generate and send new OTP
    const otp = await OtpService.resendOtp(user.id);
    
    return res.status(200).json({
      success: true,
      message: 'OTP resent successfully',
      data: {
        userId: user.id.toString(),
        phoneNumber: user.phoneNumber,
        otp: otp // Return OTP for development/testing
      }
    });
  } catch (error) {
    console.error('OTP resend error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to resend OTP',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};