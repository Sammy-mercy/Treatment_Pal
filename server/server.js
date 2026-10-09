// server.js
// Server entry point: loads environment, establishes database connection, starts listening
require('dotenv').config();
const app = require('./app');
const db = require('./config/db');

const PORT = process.env.PORT || 5000;

async function startServer() {
  try {
    await db.connect();

    app.listen(PORT, () => {
      console.log(`===============================================`);
      console.log(`  Therapy Pal API Server running on port ${PORT}`);
      console.log(`  Environment: ${process.env.NODE_ENV || 'development'}`);
      console.log(`  Healthcheck: http://localhost:${PORT}/health`);
      console.log(`===============================================`);
    });
  } catch (error) {
    console.error('Fatal error starting server:', error);
    process.exit(1);
  }
}

startServer();
