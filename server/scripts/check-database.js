import 'dotenv/config';
import { connectDB, disconnectDB } from '../config/db.js';

async function checkDatabase() {
  try {
    await connectDB();
    console.log('Database check passed. MongoDB is ready for the API.');
  } catch (error) {
    console.error(`Database check failed: ${error.message}`);
    process.exitCode = 1;
  } finally {
    await disconnectDB();
  }
}

checkDatabase();
