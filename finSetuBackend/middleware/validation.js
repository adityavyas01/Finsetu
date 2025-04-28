const validateOtpVerification = (req, res, next) => {
    const { userId, otp } = req.body;
    
    if (!userId || !otp) {
      return res.status(400).json({ 
        success: false, 
        message: 'User ID and OTP are required' 
      });
    }
    
    next();
  };
  
  module.exports = {
    validateOtpVerification
  };