// services/otpService.js
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const { otpExpiryTime } = require('../config/environment');

class OtpService {
  static async generateOtp(userId, phoneNumber) {
    try {
      const otp = Math.floor(100000 + Math.random() * 900000).toString();
      const expiresAt = new Date(Date.now() + otpExpiryTime);
      
      await prisma.otp.create({
        data: {
          userId: parseInt(userId),
          phoneNumber,
          otp,
          expiresAt
        }
      });
      
      return otp;
    } catch (error) {
      throw new Error(`OTP generation failed: ${error.message}`);
    }
  }

  static async verifyOtp(userId, otp) {
    try {
      const validOtp = await prisma.otp.findFirst({
        where: {
          userId: parseInt(userId),
          otp,
          expiresAt: {
            gt: new Date()
          }
        },
        orderBy: {
          createdAt: 'desc'
        }
      });
      
      if (!validOtp) {
        return false;
      }
      
      // Delete used OTP
      await prisma.otp.delete({
        where: {
          id: validOtp.id
        }
      });
      
      return true;
    } catch (error) {
      throw new Error(`OTP verification failed: ${error.message}`);
    }
  }

  static async resendOtp(userId, phoneNumber) {
    try {
      // Verify user exists
      const user = await prisma.user.findFirst({
        where: {
          id: parseInt(userId),
          phoneNumber
        }
      });
      
      if (!user) {
        throw new Error('User not found');
      }
      
      // Generate new OTP
      return await this.generateOtp(userId, phoneNumber);
    } catch (error) {
      throw new Error(`OTP resend failed: ${error.message}`);
    }
  }
}

module.exports = OtpService;
