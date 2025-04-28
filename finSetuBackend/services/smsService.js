class SmsService {
    static async sendOtp(phoneNumber, otp) {
      try {
        // Just log the OTP for all environments
        console.log(`[SMS] Sending OTP ${otp} to ${phoneNumber}`);
        return true;
      } catch (error) {
        console.error('SMS sending error:', error);
        throw new Error(`Failed to send SMS: ${error.message}`);
      }
    }
  }
  
  module.exports = SmsService;