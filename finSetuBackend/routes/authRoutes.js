const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { validateOtpVerification } = require('../middleware/validation');

// Register a new user - no validation middleware since frontend already validates
router.post('/register', authController.register);

// Verify OTP
router.post('/verify-otp', validateOtpVerification, authController.verifyOtp);

// Resend OTP
router.post('/resend-otp', authController.resendOtp);

module.exports = router;