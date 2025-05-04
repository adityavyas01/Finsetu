// services/otpService.js
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const { otpExpiryTime } = require('../config/environment');

// Generate and save OTP
async function generateOtp(userId) {
  try {
    // Delete any existing OTPs for this user
    await prisma.otp.deleteMany({
      where: {
        userId: parseInt(userId)
      }
    });
    
    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Save OTP to database
    const otpRecord = await prisma.otp.create({
      data: {
        userId: parseInt(userId),
        phoneNumber: (await prisma.user.findUnique({ where: { id: parseInt(userId) } })).phoneNumber,
        otp: otp,
        expiresAt: new Date(Date.now() + otpExpiryTime)
      }
    });
    
    console.log('Generated OTP:', {
      userId: otpRecord.userId,
      otp: otpRecord.otp,
      expiresAt: otpRecord.expiresAt
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
    console.log('Verifying OTP:', { userId, otp });
    
    // Find the most recent OTP for the user
    const otpRecord = await prisma.otp.findFirst({
      where: {
        userId: parseInt(userId),
        otp: otp.toString(),
        expiresAt: {
          gt: new Date()
        }
      },
      orderBy: {
        createdAt: 'desc'
      }
    });
    
    console.log('Found OTP record:', otpRecord);
    
    if (!otpRecord) {
      console.log('No valid OTP found');
      return false;
    }
    
    // Delete the OTP after successful verification
    await prisma.otp.delete({
      where: {
        id: otpRecord.id
      }
    });
    
    console.log('OTP verified successfully');
    return true;
  } catch (error) {
    console.error('Error verifying OTP:', error);
    throw new Error('Failed to verify OTP');
  }
}

// Resend OTP
async function resendOtp(userId) {
  try {
    // Delete any existing OTPs
    await prisma.otp.deleteMany({
      where: {
        userId: parseInt(userId)
      }
    });
    
    // Generate and save new OTP
    return await generateOtp(userId);
  } catch (error) {
    console.error('Error resending OTP:', error);
    throw new Error('Failed to resend OTP');
  }
}

module.exports = {
  generateOtp,
  verifyOtp,
  resendOtp
};
