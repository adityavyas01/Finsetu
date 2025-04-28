const app = require('./app');
const { port, nodeEnv } = require('./config/environment');

// Start the server
app.listen(port, () => {
  console.log(`Server running in ${nodeEnv} mode on port ${port}`);
});