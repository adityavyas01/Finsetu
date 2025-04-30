const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });

console.log('Loading .env from:', path.resolve(__dirname, '../.env'));
console.log('DATABASE_URL:', process.env.DATABASE_URL);
console.log('All environment variables:', process.env);

module.exports = {
  schema: './prisma/schema.prisma',
  env: {
    DATABASE_URL: process.env.DATABASE_URL
  }
}; 