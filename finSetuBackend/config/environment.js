require('dotenv').config();

module.exports = {
  nodeEnv: process.env.NODE_ENV || 'development',
  port: process.env.PORT || 3000,
  jwtSecret: process.env.JWT_SECRET || 'your-default-jwt-secret',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
  otpExpiryTime: parseInt(process.env.OTP_EXPIRY_TIME) || 10 * 60 * 1000, // 10 minutes in milliseconds
  bcryptSaltRounds: parseInt(process.env.BCRYPT_SALT_ROUNDS) || 10,
  dbConfig: {
    user: process.env.DB_USER || 'postgres',
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'finsetu',
    password: process.env.DB_PASSWORD || 'postgres',
    port: parseInt(process.env.DB_PORT) || 5432,
  }
};