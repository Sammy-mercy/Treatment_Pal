import { MongoClient } from 'mongodb';

let db = null;
let client = null;

export async function connectDB() {
  const uri = process.env.DATABASE_URL;
  if (!uri) {
    console.warn('[db] DATABASE_URL not set. Using in-memory fallback.');
    return;
  }
  try {
    client = new MongoClient(uri);
    await client.connect();
    db = client.db();
    
    // Create indexes
    await db.collection('users').createIndex({ email: 1 }, { unique: true, sparse: true });
    await db.collection('users').createIndex({ firebaseUid: 1 }, { unique: true, sparse: true });
    await db.collection('regimens').createIndex({ patientId: 1 });
    await db.collection('regimen_items').createIndex({ regimenId: 1 });
    await db.collection('adherence_logs').createIndex({ patientId: 1, scheduledAt: -1 });
    await db.collection('adherence_logs').createIndex({ regimenItemId: 1, scheduledAt: -1 });
    await db.collection('notifications').createIndex({ userId: 1, createdAt: -1 });
    await db.collection('notifications').createIndex({ dedupeKey: 1 }, { unique: true, sparse: true });
    await db.collection('messages').createIndex({ patientId: 1, clinicianId: 1, createdAt: 1 });
    await db.collection('messages').createIndex({ recipientId: 1, read: 1 });
    await db.collection('history').createIndex({ patientId: 1, date: -1 });
    await db.collection('analytics_visits').createIndex({ visitorId: 1 });
    await db.collection('analytics_visits').createIndex({ userId: 1 }, { sparse: true });
    
    console.log('[db] Connected to MongoDB');
  } catch (err) {
    console.error('[db] MongoDB connection error:', err.message);
    throw err;
  }
}

export function getDB() {
  return db;
}

export function getCollection(name) {
  if (!db) return null;
  return db.collection(name);
}

export async function findOne(collection, query) {
  const col = getCollection(collection);
  if (!col) return null;
  return col.findOne(query);
}

export async function findMany(collection, query, options = {}) {
  const col = getCollection(collection);
  if (!col) return [];
  return col.find(query, options).toArray();
}

export async function insertOne(collection, doc) {
  const col = getCollection(collection);
  if (!col) return null;
  const result = await col.insertOne(doc);
  return { ...doc, _id: result.insertedId };
}

export async function updateOne(collection, query, update) {
  const col = getCollection(collection);
  if (!col) return null;
  return col.updateOne(query, update);
}

export async function deleteOne(collection, query) {
  const col = getCollection(collection);
  if (!col) return null;
  return col.deleteOne(query);
}

export async function countDocs(collection, query) {
  const col = getCollection(collection);
  if (!col) return 0;
  return col.countDocuments(query);
}

export async function disconnectDB() {
  if (client) {
    await client.close();
    db = null;
    client = null;
  }
}

export const connect = connectDB;
export const disconnect = disconnectDB;
