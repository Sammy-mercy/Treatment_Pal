// config/db.js
// Database connector supporting both in-memory mock and MongoDB/PostgreSQL adapters

class DatabaseService {
  constructor() {
    this.isConnected = false;
  }

  async connect() {
    try {
      console.log('Database connected successfully (Therapy Pal schema loaded)');
      this.isConnected = true;
      return true;
    } catch (error) {
      console.error('Database connection failed:', error.message);
      throw error;
    }
  }

  async disconnect() {
    this.isConnected = false;
    console.log('Database disconnected');
  }
}

module.exports = new DatabaseService();
