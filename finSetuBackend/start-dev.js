const { spawn } = require('child_process');
const express = require('express');
const app = express();

// Start the backend server
const server = spawn('node', ['server.js'], {
  stdio: 'inherit',
  shell: true
});

// Start ngrok tunnel
const ngrok = spawn('ngrok', ['http', '3000'], {
  stdio: 'inherit',
  shell: true
});

// Handle process termination
process.on('SIGINT', () => {
  server.kill();
  ngrok.kill();
  process.exit();
});

process.on('SIGTERM', () => {
  server.kill();
  ngrok.kill();
  process.exit();
}); 