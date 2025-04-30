const bcrypt = require('bcrypt');
const User = require('../models/userModel');
const OtpService = require('../services/otpService');
const SmsService = require('../services/smsService');
const { bcryptSaltRounds } = require('../config/environment');

// Register a new user and generate OTP
exports.register = async (req, res) => {
  try {
    const { username, phoneNumber, password } = req.body;
    
    if (!username || !phoneNumber || !password) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields'
      });
    }
    
    const existingUser = await User.findByPhone(phoneNumber);
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'User with this phone number already exists'
      });
    }
    
    const hashedPassword = await bcrypt.hash(password, bcryptSaltRounds);
    
    const user = await User.create({
      username,
      phoneNumber,
      password: hashedPassword
    });
    
    // Generate and send OTP
    const otp = await OtpService.generateOtp(user.id, phoneNumber);
    await SmsService.sendOtp(phoneNumber, otp);
    
    return res.status(201).json({
      success: true,
      message: 'Registration initiated. Please verify your phone number.',
      data: {
        userId: user.id,
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
    const { userId, otp } = req.body;
    
    console.log('=== OTP Verification Request ===');
    console.log('Request Body:', req.body);
    
    // Validate required fields
    if (!userId || !otp) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: userId and otp'
      });
    }

    // Validate userId format
    const userIdInt = parseInt(userId);
    if (isNaN(userIdInt)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid userId format'
      });
    }
    
    const isValid = await OtpService.verifyOtp(userIdInt, otp);
    
    if (isValid) {
      return res.status(200).json({
        success: true,
        message: 'OTP verified successfully',
        data: {
          userId: userIdInt,
          isVerified: true
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
    
    if (!userId || !phoneNumber) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields'
      });
    }
    
    const otp = await OtpService.resendOtp(userId, phoneNumber);
    await SmsService.sendOtp(phoneNumber, otp);
    
    return res.status(200).json({
      success: true,
      message: 'OTP resent successfully',
      data: {
        userId,
        otp: otp // Return OTP for development/testing
      }
    });
  } catch (error) {
    console.error('OTP resend error:', error);
    
    if (error.message.includes('User not found')) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    return res.status(500).json({
      success: false,
      message: 'Server error during OTP resend',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};