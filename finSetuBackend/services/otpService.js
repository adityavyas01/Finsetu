// services/otpService.js
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const { otpExpiryTime } = require('../config/environment');

// Generate and save OTP
async function generateOtp(userId) {
  try {
    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Save OTP to database
    await prisma.otp.create({
      data: {
        userId: parseInt(userId),
        code: otp,
        expiresAt: new Date(Date.now() + otpExpiryTime)
      }
    });
    
    return otp;
  } catch (error) {
    console.error('Error generating OTP:', error);
    throw new Error('Failed to generate OTP');
  }
}

// Verify OTP
async function verifyOtp(userId, otp) {
  try {
    // Find the most recent OTP for the user
    const otpRecord = await prisma.otp.findFirst({
      where: {
        userId: parseInt(userId),
        code: otp.toString(),
        expiresAt: {
          gt: new Date()
        }
      },
      orderBy: {
        createdAt: 'desc'
      }
    });
    
    if (!otpRecord) {
      return false;
    }
    
    // Delete the OTP after successful verification
    await prisma.otp.delete({
      where: {
        id: otpRecord.id
      }
    });
    
    return true;
  } catch (error) {
    console.error('Error verifying OTP:', error);
    throw new Error('Failed to verify OTP');
  }
}

module.exports = {
  generateOtp,
  verifyOtp
};
