class SmsService {
    static async sendOtp(phoneNumber, otp) {
      try {
        // In development, just log the OTP
        if (process.env.NODE_ENV === 'development') {
          console.log(`[DEV SMS] Sending OTP ${otp} to ${phoneNumber}`);
          return true;
        }
        
        // In production, you would integrate with an SMS provider here
        // Example with Twilio (you would need to add the Twilio package):
        /*
        const twilio = require('twilio');
        const client = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
        
        await client.messages.create({
          body: `Your FinSetu verification code is: ${otp}`,
          from: process.env.TWILIO_PHONE_NUMBER,
          to: phoneNumber
        });
        */
        
        return true;
      } catch (error) {
        console.error('SMS sending error:', error);
        throw new Error(`Failed to send SMS: ${error.message}`);
      }
    }
  }
  
  module.exports = SmsService;