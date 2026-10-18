import crypto from 'crypto';
import { findOne, findMany, insertOne, updateOne, getCollection, countDocs } from '../config/db.js';
import { HttpError } from '../middleware/errorHandler.js';
import { createNotification } from './notification.service.js';

function initials(name = '') {
  return name.replace(/^Dr\.?\s+/i, '').split(/\s+/).filter(Boolean).slice(0, 2).map(p => p[0].toUpperCase()).join('');
}

function messageDto(m, viewerId) {
  return {
    id: m.id,
    from: m.senderId === viewerId ? 'me' : 'them',
    text: m.text,
    createdAt: m.createdAt,
  };
}

async function resolvePair(user, patientId) {
  if (user.role === 'patient') {
    const p = await findOne('patient_profiles', { userId: user.id });
    if (!p?.clinicianId) throw new HttpError(404, 'You are not linked to a clinician yet');
    return { patientId: user.id, clinicianId: p.clinicianId };
  }
  const p = await findOne('patient_profiles', { userId: patientId, clinicianId: user.id });
  if (!p) throw new HttpError(404, 'Patient not found in your panel');
  return { patientId: p.userId, clinicianId: user.id };
}

export async function getThreads(user) {
  let threads = [];
  
  if (user.role === 'patient') {
    const p = await findOne('patient_profiles', { userId: user.id });
    if (p?.clinicianId) {
      const c = await findOne('users', { id: p.clinicianId });
      if (c) {
        threads = [await threadSummary(user.id, c.id, user, c.name)];
      }
    }
  } else {
    const patients = await findMany('patient_profiles', { clinicianId: user.id });
    for (const p of patients) {
      const u = await findOne('users', { id: p.userId });
      if (u) {
        threads.push(await threadSummary(u.id, user.id, user, u.name));
      }
    }
  }
  
  threads.sort((a, b) => (b.last?.createdAt || '').localeCompare(a.last?.createdAt || ''));
  const unread = threads.reduce((n, t) => n + t.unread, 0);
  return { threads, unread };
}

async function threadSummary(patientId, clinicianId, viewer, displayName) {
  const col = getCollection('messages');
  const last = col ? await col.findOne(
    { patientId, clinicianId },
    { sort: { createdAt: -1 } }
  ) : null;
  
  const unread = await countDocs('messages', {
    patientId, clinicianId,
    senderId: { $ne: viewer.id },
    read: false,
  });
  
  return {
    patientId,
    name: displayName,
    initials: initials(displayName),
    unread,
    last: last ? messageDto(last, viewer.id) : null,
  };
}

export async function getThread(user, patientId) {
  const pair = await resolvePair(user, patientId);
  
  // Mark incoming messages as read
  const col = getCollection('messages');
  if (col) {
    await col.updateMany(
      { patientId: pair.patientId, clinicianId: pair.clinicianId, senderId: { $ne: user.id }, read: false },
      { $set: { read: true } }
    );
  }
  
  const messages = await findMany('messages', 
    { patientId: pair.patientId, clinicianId: pair.clinicianId },
    { sort: { createdAt: 1 } }
  );
  
  const otherId = user.role === 'patient' ? pair.clinicianId : pair.patientId;
  const other = await findOne('users', { id: otherId });
  
  return {
    with: { id: otherId, name: other?.name || '', initials: initials(other?.name || '') },
    messages: messages.map(m => messageDto(m, user.id)),
  };
}

export async function sendMessage(user, patientId, text) {
  const pair = await resolvePair(user, patientId);
  const id = crypto.randomUUID();
  const createdAt = new Date().toISOString();
  
  await insertOne('messages', {
    id,
    patientId: pair.patientId,
    clinicianId: pair.clinicianId,
    senderId: user.id,
    text,
    read: false,
    createdAt,
  });
  
  // Notify recipient
  const recipientId = user.role === 'patient' ? pair.clinicianId : pair.patientId;
  await createNotification(recipientId, 'message', `Message from ${user.name}`, text.length > 90 ? `${text.slice(0, 87)}...` : text);
  
  return { message: { id, from: 'me', text, createdAt } };
}
