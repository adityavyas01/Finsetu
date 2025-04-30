const path = require('path');
const fs = require('fs');

// Try to load .env from different possible locations
const envPaths = [
  path.resolve(__dirname, '../.env'),
  path.resolve(__dirname, '../../.env'),
  path.resolve(__dirname, '.env')
];

let envLoaded = false;
for (const envPath of envPaths) {
  if (fs.existsSync(envPath)) {
    require('dotenv').config({ path: envPath });
    console.log('Successfully loaded .env from:', envPath);
    envLoaded = true;
    break;
  }
}

if (!envLoaded) {
  console.error('No .env file found in any of these locations:', envPaths);
  process.exit(1);
}

// Get database configuration from environment variables or defaults
const dbConfig = {
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'finsetu',
  password: process.env.DB_PASSWORD || 'postgres',
  port: parseInt(process.env.DB_PORT) || 5432,
};

// Construct DATABASE_URL
const DATABASE_URL = `postgresql://${dbConfig.user}:${dbConfig.password}@${dbConfig.host}:${dbConfig.port}/${dbConfig.database}?schema=public`;

// Set the DATABASE_URL in process.env
process.env.DATABASE_URL = DATABASE_URL;

console.log('Using DATABASE_URL:', DATABASE_URL); 