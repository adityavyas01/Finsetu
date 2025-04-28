// services/otpService.js
const db = require('../config/database');
const { otpExpiryTime } = require('../config/environment');

class OtpService {
  static async generateOtp(userId, phoneNumber) {
    try {
      // Generate a 6-digit OTP
      const otp = Math.floor(100000 + Math.random() * 900000).toString();
      
      // Store OTP in database with expiry
      const expiresAt = new Date(Date.now() + otpExpiryTime);
      
      const query = `
        INSERT INTO otps (user_id, phone_number, otp, created_at, expires_at)
        VALUES ($1, $2, $3, NOW(), $4)
        RETURNING *
      `;
      
      await db.query(query, [
        userId,
        phoneNumber,
        otp,
        expiresAt
      ]);
      
      return otp;
    } catch (error) {
      throw new Error(`OTP generation failed: ${error.message}`);
    }
  }

  static async verifyOtp(userId, otp) {
    try {
      const query = `
        SELECT * FROM otps
        WHERE user_id = $1 
        AND otp = $2 
        AND expires_at > NOW()
      `;
      
      const result = await db.query(query, [userId, otp]);
      
      if (result.rows.length === 0) {
        return false;
      }
      
      // Delete the OTP after verification
      const deleteQuery = `
        DELETE FROM otps
        WHERE user_id = $1 AND otp = $2
      `;
      
      await db.query(deleteQuery, [userId, otp]);
      
      return true;
    } catch (error) {
      throw new Error(`OTP verification failed: ${error.message}`);
    }
  }
}

module.exports = OtpService;
