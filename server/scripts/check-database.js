require('dotenv').config();
const db = require('../config/db');

async function checkDatabase() {
  try {
    await db.connect();
    console.log('Database check passed. MongoDB is ready for the API.');
  } catch (error) {
    console.error(`Database check failed: ${error.message}`);
    process.exitCode = 1;
  } finally {
    await db.disconnect();
  }
}

checkDatabase();
