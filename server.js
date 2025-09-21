const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Disable X-Powered-By header for security
app.disable('x-powered-by');

// Serve static files from the public directory
app.use(express.static(path.join(__dirname, 'public')));

// Set up middleware for logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Serve the main page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Handle 404 errors
app.use((req, res) => {
  res.status(404).sendFile(path.join(__dirname, 'public', '404.html'));
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Something went wrong!',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Internal server error'
  });
});

// Only start the server if this file is run directly
if (require.main === module) {
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 DevOps Bootcamp Showcase server running on http://0.0.0.0:${PORT}`);
    console.log(`📊 Health check available at http://0.0.0.0:${PORT}/health`);
    console.log(`🌐 Server accessible from external connections on port ${PORT}`);
  });
}

// Export the app for testing
module.exports = app;
