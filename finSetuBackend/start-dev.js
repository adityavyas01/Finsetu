const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const { PrismaClient } = require('@prisma/client');

// Load environment variables and get database configuration
const { DATABASE_URL, dbConfig } = require('./prisma-env');

// Set DATABASE_URL in process.env
process.env.DATABASE_URL = DATABASE_URL;

// Initialize Prisma client
const prisma = new PrismaClient();

// Test database connection
async function testDatabaseConnection() {
  try {
    await prisma.$connect();
    console.log('Database connection successful');
    return true;
  } catch (error) {
    console.error('Database connection failed:', error);
    return false;
  }
}

// Start the server
async function startServer() {
  const server = spawn('node', ['server.js'], {
    stdio: 'inherit',
    shell: true,
    env: {
      ...process.env,
      DATABASE_URL: DATABASE_URL
    }
  });

  // Handle server errors
  server.on('error', (err) => {
    console.error('Failed to start server:', err);
  });

  // Handle server exit
  server.on('exit', (code) => {
    console.log(`Server exited with code ${code}`);
  });

  return server;
}

// Start ngrok tunnel
function startNgrok() {
  // Kill any existing ngrok processes
  spawn('taskkill', ['/F', '/IM', 'ngrok.exe'], {
    stdio: 'inherit',
    shell: true
  });

  // Wait a bit for the process to be killed
  setTimeout(() => {
    const ngrok = spawn('ngrok', ['http', '3000'], {
      stdio: 'inherit',
      shell: true
    });

    // Handle ngrok errors
    ngrok.on('error', (err) => {
      console.error('Failed to start ngrok:', err);
    });

    // Handle ngrok exit
    ngrok.on('exit', (code) => {
      console.log(`Ngrok exited with code ${code}`);
    });

    return ngrok;
  }, 2000);
}

// Main function
async function main() {
  // Test database connection
  const dbConnected = await testDatabaseConnection();
  if (!dbConnected) {
    console.error('Failed to connect to database. Exiting...');
    process.exit(1);
  }

  // Start server and ngrok
  const server = await startServer();
  const ngrok = startNgrok();

  // Handle process termination
  process.on('SIGINT', async () => {
    console.log('Shutting down...');
    server.kill();
    spawn('taskkill', ['/F', '/IM', 'ngrok.exe'], {
      stdio: 'inherit',
      shell: true
    });
    await prisma.$disconnect();
    process.exit();
  });

  process.on('SIGTERM', async () => {
    server.kill();
    spawn('taskkill', ['/F', '/IM', 'ngrok.exe'], {
      stdio: 'inherit',
      shell: true
    });
    await prisma.$disconnect();
    process.exit();
  });
}

// Start the application
main().catch((error) => {
  console.error('Application failed to start:', error);
  process.exit(1);
}); 