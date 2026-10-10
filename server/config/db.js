//import 'dotenv/config';
// config/db.js
const { MongoClient } = require('mongodb');

function describeConnectionError(error) {
  const code = error.code || error.codeName || error.cause?.code || 'UNKNOWN';
  const message = String(error.message || 'Unknown MongoDB connection error');

  if (code === 8000 || /bad auth|authentication failed/i.test(message)) {
    return {
      stage: 'Atlas authentication',
      code,
      action: 'Check the Atlas Database Access username/password. URL-encode special characters in the password.',
    };
  }
  if (code === 'ECONNREFUSED' || /querySrv|ENOTFOUND|ECONNREFUSED/i.test(message)) {
    return {
      stage: 'DNS or network discovery',
      code,
      action: 'Check the Atlas hostname in DATABASE_URL and whether your network/VPN allows DNS SRV lookups.',
    };
  }
  if (/timed out|ETIMEDOUT|server selection/i.test(message)) {
    return {
      stage: 'Network access/server selection',
      code,
      action: 'Check Atlas Network Access for your current IP and confirm the cluster is available.',
    };
  }
  if (/Invalid scheme|Invalid URL|URI malformed/i.test(message)) {
    return {
      stage: 'Connection string parsing',
      code,
      action: 'Copy a current connection string from Atlas Connect > Drivers and ensure it begins with mongodb+srv:// or mongodb://.',
    };
  }
  return {
    stage: 'MongoDB connection',
    code,
    action: 'Check the server error details and the Atlas driver connection string.',
  };
}

class DatabaseService {
  constructor() {
    this.client = null;
    this.database = null;
    this.isConnected = false;
    this.testCollections = { users: [], analytics_visits: [] };
  }

  async connect() {
    if (process.env.NODE_ENV === 'test') {
      this.isConnected = true;
      return true;
    }

    const connectionString = process.env.DATABASE_URL;
    if (!connectionString) throw new Error('DATABASE_URL must be configured');

    const usesMongoScheme = connectionString.startsWith('mongodb://') ||
      connectionString.startsWith('mongodb+srv://');
    if (!usesMongoScheme) {
      throw new Error('DATABASE_URL must use mongodb:// or mongodb+srv://');
    }

    const scheme = connectionString.startsWith('mongodb+srv://') ? 'mongodb+srv:' : 'mongodb:';
    const authority = connectionString.slice(scheme.length + 2).split(/[/?#]/)[0];
    const host = authority.slice(authority.lastIndexOf('@') + 1).split(':')[0];
    console.log(`MongoDB: starting connection (scheme=${scheme}, host=${host || 'missing'})`);
    try {
      this.client = new MongoClient(connectionString, { serverSelectionTimeoutMS: 10000 });
    } catch (error) {
      const diagnosis = describeConnectionError(error);
      console.error(`MongoDB connection string rejected during ${diagnosis.stage} (code=${diagnosis.code}).`);
      console.error(diagnosis.action);
      throw error;
    }
    try {
      await this.client.connect();
      this.database = this.client.db();
      console.log(`MongoDB: authenticated and connected (database=${this.database.databaseName})`);
      await Promise.all([
        this.database.collection('users').createIndex({ firebaseUid: 1 }, { unique: true, sparse: true }),
        this.database.collection('users').createIndex({ email: 1 }, { unique: true, sparse: true }),
        this.database.collection('analytics_visits').createIndex({ visitorId: 1, visitedAt: -1 }),
        this.database.collection('analytics_visits').createIndex({ userId: 1, visitedAt: -1 }),
      ]);
      this.isConnected = true;
      console.log('MongoDB: application indexes are ready');
      return true;
    } catch (error) {
      const diagnosis = describeConnectionError(error);
      console.error(`MongoDB connection failed during ${diagnosis.stage} (code=${diagnosis.code}).`);
      console.error(diagnosis.action);
      if (this.client) await this.client.close().catch(() => {});
      this.client = null;
      this.database = null;
      this.isConnected = false;
      throw error;
    }
  }

  collection(name) {
    if (!this.isConnected) throw new Error('MongoDB is not connected');
    if (process.env.NODE_ENV === 'test') return new TestCollection(this.testCollections[name]);
    return this.database.collection(name);
  }

  async findUserById(firebaseUid) {
    return this.collection('users').findOne({ firebaseUid });
  }

  async findUserByEmail(email) {
    return this.collection('users').findOne({ email: email.toLowerCase() });
  }

  async findUserByAnyId(id) {
    return (await this.collection('users').findOne({ firebaseUid: id })) ||
      this.collection('users').findOne({ id });
  }

  async findUsersByRole(role) {
    return this.collection('users').find({ role }).toArray();
  }

  async createUser(user) {
    await this.collection('users').insertOne(user);
    return user;
  }

  async updateUserVisit(firebaseUid, userFields, visitedAt) {
    return this.collection('users').updateOne(
      { firebaseUid },
      {
        $set: { ...userFields, lastActiveAt: visitedAt },
        $inc: { totalVisits: 1 },
      },
      { upsert: true },
    );
  }

  async recordVisit(visit) {
    return this.collection('analytics_visits').insertOne(visit);
  }

  async getUsers() {
    return this.collection('users').find({}).toArray();
  }

  async getAnonymousVisits() {
    return this.collection('analytics_visits')
      .find({ kind: 'anonymous' })
      .toArray();
  }

  async disconnect() {
    if (this.client) await this.client.close();
    this.client = null;
    this.database = null;
    this.isConnected = false;
  }
}

class TestCollection {
  constructor(documents) {
    this.documents = documents;
  }

  async findOne(filter) {
    return this.documents.find((document) => Object.entries(filter).every(([key, value]) => document[key] === value)) || null;
  }

  async insertOne(document) {
    this.documents.push({ ...document });
    return { insertedId: document._id || document.firebaseUid };
  }

  async updateOne(filter, update, options = {}) {
    let document = await this.findOne(filter);
    if (!document && options.upsert) {
      document = { ...filter };
      this.documents.push(document);
    }
    if (!document) return { matchedCount: 0, modifiedCount: 0 };
    Object.assign(document, update.$set || {});
    for (const [key, amount] of Object.entries(update.$inc || {})) document[key] = (document[key] || 0) + amount;
    return { matchedCount: 1, modifiedCount: 1 };
  }

  find(filter = {}) {
    return {
      toArray: async () => this.documents.filter((document) => Object.entries(filter).every(([key, value]) => document[key] === value)),
    };
  }

  async createIndex() { return 'test-index'; }
}

module.exports = new DatabaseService();
