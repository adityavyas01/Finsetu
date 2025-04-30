const app = require('./app');
const PORT = process.env.PORT || 3000;

// Start the server
app.listen(PORT, () => {
  console.log(`Server running in development mode on port ${PORT}`);
});