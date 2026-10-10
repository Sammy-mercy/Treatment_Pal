const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const db = require('../config/db');

function issueAdminToken(email) {
  if (!process.env.ADMIN_TOKEN_SECRET) {
    throw { statusCode: 503, message: 'Admin authentication is not configured' };
  }
  return jwt.sign({
    uid: `admin:${email.toLowerCase()}`,
    id: `admin:${email.toLowerCase()}`,
    email,
    name: 'Therapy Pal Admin',
    role: 'admin',
  }, process.env.ADMIN_TOKEN_SECRET, { expiresIn: '12h' });
}

function safeEqual(left, right) {
  const a = Buffer.from(left || '');
  const b = Buffer.from(right || '');
  return a.length === b.length && crypto.timingSafeEqual(a, b);
}

function toPublicUser(document) {
  if (!document) return null;
  const { _id, ...user } = document;
  return { ...user, id: user.id || user.firebaseUid };
}

class AuthService {
  async loginAdmin(email, password) {
    const configuredEmail = process.env.ADMIN_EMAIL || '';
    if (!configuredEmail || email.toLowerCase() !== configuredEmail.toLowerCase() ||
        !safeEqual(password, process.env.ADMIN_PASSWORD)) {
      throw { statusCode: 401, message: 'Invalid credentials' };
    }

    const user = {
      id: `admin:${configuredEmail.toLowerCase()}`,
      name: 'Therapy Pal Admin',
      email: configuredEmail,
      role: 'admin',
    };
    return { user, token: issueAdminToken(configuredEmail) };
  }

  async getFirebaseUser(firebaseIdentity) {
    const firebaseUid = firebaseIdentity.uid || firebaseIdentity.sub;
    if (!firebaseUid) throw { statusCode: 401, message: 'Firebase identity has no user id' };
    const document = await db.findUserById(firebaseUid);
    if (!document) throw { statusCode: 404, message: 'Profile not found; complete account registration first' };
    return toPublicUser(document);
  }

  async register(data, firebaseIdentity) {
    const firebaseUid = firebaseIdentity.uid || firebaseIdentity.sub;
    const email = (firebaseIdentity.email || '').toLowerCase();
    if (!firebaseUid || !email) throw { statusCode: 401, message: 'Verified Firebase email identity is required' };

    const existing = await db.findUserById(firebaseUid);
    if (existing) throw { statusCode: 409, message: 'Profile already exists for this account' };
    const existingEmail = await db.findUserByEmail(email);
    if (existingEmail) throw { statusCode: 409, message: 'A profile already exists for this email' };

    const user = {
      id: firebaseUid,
      firebaseUid,
      name: data.name.trim(),
      email,
      role: data.role,
      phone: data.phone || '',
      dob: data.dob || '',
      npi: data.npi || null,
      specialization: data.specialization || null,
      assignedClinicianId: null,
      createdAt: new Date(),
      lastActiveAt: null,
      totalVisits: 0,
    };
    await db.createUser(user);
    return toPublicUser(user);
  }
}

module.exports = new AuthService();