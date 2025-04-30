const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

// Start the server
const server = spawn('node', ['server.js'], {
  stdio: 'inherit',
  shell: true
});

// Handle server errors
server.on('error', (err) => {
  console.error('Failed to start server:', err);
});

// Handle server exit
server.on('exit', (code) => {
  console.log(`Server exited with code ${code}`);
});

// Start ngrok in a separate process
const ngrok = spawn('ngrok', ['http', '3001'], {
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

// Handle process termination
process.on('SIGINT', () => {
  console.log('Shutting down...');
  server.kill();
  ngrok.kill();
  process.exit();
});

process.on('SIGTERM', () => {
  server.kill();
  ngrok.kill();
  process.exit();
}); 