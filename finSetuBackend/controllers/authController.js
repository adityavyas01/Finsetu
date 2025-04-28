const bcrypt = require('bcrypt');
const User = require('../models/userModel');
const OtpService = require('../services/otpService');
const SmsService = require('../services/smsService');
const { bcryptSaltRounds } = require('../config/environment');

// Register a new user
exports.register = async (req, res) => {
  try {
    const { username, phoneNumber, password } = req.body;
    
    // Check if all required fields are present
    if (!username || !phoneNumber || !password) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields'
      });
    }
    
    // Check if user already exists
    const existingUser = await User.findByPhone(phoneNumber);
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'User with this phone number already exists'
      });
    }
    
    // Hash the password
    const hashedPassword = await bcrypt.hash(password, bcryptSaltRounds);
    
    // Create new user
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
        otp: process.env.NODE_ENV === 'development' ? otp : undefined // Only return OTP in development
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

// Verify OTP for phone verification
exports.verifyOtp = async (req, res) => {
  try {
    const { userId, otp } = req.body;
    
    // Verify OTP
    const isValid = await OtpService.verifyOtp(userId, otp);
    
    if (!isValid) {
      return res.status(400).json({
        success: false,
        message: 'Invalid or expired OTP'
      });
    }
    
    // Update user verification status
    await User.updateById(userId, { isPhoneVerified: true });
    
    return res.status(200).json({
      success: true,
      message: 'Phone number verified successfully'
    });
  } catch (error) {
    console.error('OTP verification error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error during verification',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};