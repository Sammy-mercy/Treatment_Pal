import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { findOne, insertOne, updateOne, getCollection } from '../config/db.js';
import { HttpError } from '../middleware/errorHandler.js';

function initials(name = '') {
  return name.replace(/^Dr\.?\s+/i, '').split(/\s+/).filter(Boolean).slice(0, 2).map(p => p[0].toUpperCase()).join('');
}

export async function registerUser(data, firebaseUid = null) {
  const email = (data.email || '').toLowerCase();
  if (email) {
    const existing = await findOne('users', { email });
    if (existing) {
      throw new HttpError(409, 'An account with this email already exists');
    }
  }
  
  const id = crypto.randomUUID();
  const hash = data.password ? bcrypt.hashSync(data.password, 12) : '';
  const now = new Date().toISOString();
  
  const user = {
    id,
    firebaseUid: firebaseUid || null,
    email,
    passwordHash: hash,
    name: data.name,
    role: data.role,
    phone: data.phone || '',
    dob: '',
    prefs: { doseReminders: true, missedDose: true, clinicianMessages: true, weeklySummary: false },
    createdAt: now,
    totalVisits: 0,
    lastActiveAt: now,
  };
  
  await insertOne('users', user);
  
  if (data.role === 'clinician') {
    await insertOne('clinician_profiles', {
      userId: id,
      npi: data.npi || '',
      specialization: data.specialization || '',
      license: data.license || '',
    });
  } else {
    let clinicianId = null;
    if (data.clinicianEmail) {
      const clinician = await findOne('users', { email: data.clinicianEmail.toLowerCase(), role: 'clinician' });
      if (!clinician) throw new HttpError(404, 'No clinician found with that email');
      clinicianId = clinician.id;
    }
    await insertOne('patient_profiles', {
      userId: id,
      clinicianId,
      plan: 'Care plan',
      note: '',
    });
  }
  
  return user;
}

export async function loginUser(email, password, role) {
  const user = await findOne('users', { email: email.toLowerCase() });
  if (!user || !user.passwordHash || !bcrypt.compareSync(password, user.passwordHash)) {
    throw new HttpError(401, 'Incorrect email or password');
  }
  if (role && role !== user.role) {
    throw new HttpError(403, `This account is a ${user.role} account. Choose "${user.role}" to sign in.`);
  }
  return user;
}

export async function loginAdmin(email, password) {
  const adminEmail = process.env.ADMIN_EMAIL;
  const adminPassword = process.env.ADMIN_PASSWORD;
  
  if (!adminEmail || !adminPassword) {
    throw new HttpError(403, 'Admin login not configured');
  }
  
  const emailMatch = email.length === adminEmail.length && crypto.timingSafeEqual(Buffer.from(email), Buffer.from(adminEmail));
  const pwMatch = password.length === adminPassword.length && crypto.timingSafeEqual(Buffer.from(password), Buffer.from(adminPassword));
  
  if (!emailMatch || !pwMatch) {
    throw new HttpError(401, 'Incorrect email or password');
  }
  
  const token = jwt.sign({ role: 'admin', email }, process.env.ADMIN_TOKEN_SECRET || process.env.JWT_SECRET, { expiresIn: '12h' });
  return { token, user: { id: 'admin', role: 'admin', email, name: 'Admin' } };
}

export function signToken(user) {
  return jwt.sign(
    { sub: user.id, role: user.role },
    process.env.JWT_SECRET || 'dev-secret',
    { expiresIn: '7d' }
  );
}

export async function getProfile(userId) {
  const user = await findOne('users', { id: userId });
  if (!user) return null;
  
  const base = {
    id: user.id,
    role: user.role,
    name: user.name,
    initials: initials(user.name),
    email: user.email,
    phone: user.phone || '',
    dob: user.dob || '',
    memberSince: user.createdAt,
    prefs: user.prefs || {},
  };
  
  if (user.role === 'clinician') {
    const profile = await findOne('clinician_profiles', { userId: user.id }) || {};
    const clinics = await (getCollection('clinics')?.find({ clinicianId: user.id }).toArray()) || [];
    return { ...base, npi: profile.npi || '', specialization: profile.specialization || '', license: profile.license || '', clinics };
  }
  
  const profile = await findOne('patient_profiles', { userId: user.id }) || {};
  let clinician = null;
  if (profile.clinicianId) {
    const c = await findOne('users', { id: profile.clinicianId });
    if (c) clinician = { id: c.id, name: c.name };
  }
  return { ...base, plan: profile.plan || '', clinician };
}

export async function updateProfile(userId, data) {
  const updates = {};
  if (data.name) updates.name = data.name;
  if (data.email) {
    const existing = await findOne('users', { email: data.email.toLowerCase() });
    if (existing && existing.id !== userId) throw new HttpError(409, 'That email is already in use');
    updates.email = data.email.toLowerCase();
  }
  if (data.phone !== undefined) updates.phone = data.phone;
  
  if (Object.keys(updates).length > 0) {
    await updateOne('users', { id: userId }, { $set: updates });
  }
  return getProfile(userId);
}

export async function updatePrefs(userId, prefs) {
  const user = await findOne('users', { id: userId });
  const currentPrefs = user?.prefs || {};
  const newPrefs = { ...currentPrefs, ...prefs };
  await updateOne('users', { id: userId }, { $set: { prefs: newPrefs } });
  return getProfile(userId);
}