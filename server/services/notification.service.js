import crypto from 'crypto';
import { findMany, insertOne, updateOne, getCollection, findOne } from '../config/db.js';
import { HttpError } from '../middleware/errorHandler.js';

export async function createNotification(userId, kind, title, body, dedupeKey = null) {
  if (dedupeKey) {
    const existing = await findOne('notifications', { dedupeKey });
    if (existing) return existing;
  }
  
  return insertOne('notifications', {
    id: crypto.randomUUID(),
    userId,
    kind,
    title,
    body: body || '',
    read: false,
    dedupeKey: dedupeKey || null,
    createdAt: new Date().toISOString(),
  });
}

export async function getNotifications(userId) {
  const notifications = await findMany('notifications', { userId }, { sort: { createdAt: -1 }, limit: 60 });
  const unread = notifications.filter(n => !n.read).length;
  return {
    notifications: notifications.map(n => ({
      id: n.id,
      kind: n.kind,
      title: n.title,
      body: n.body,
      read: !!n.read,
      createdAt: n.createdAt,
    })),
    unread,
  };
}

export async function markAllRead(userId) {
  const col = getCollection('notifications');
  if (col) {
    await col.updateMany({ userId, read: false }, { $set: { read: true } });
  }
}

export async function markOneRead(userId, notificationId) {
  const result = await updateOne('notifications', { id: notificationId, userId }, { $set: { read: true } });
  if (!result?.modifiedCount && !result?.matchedCount) {
    throw new HttpError(404, 'Notification not found');
  }
}

export async function registerDeviceToken(userId, token) {
  await updateOne('users', { id: userId }, { $set: { fcmToken: token } });
  return { success: true };
}

export async function generateDoseNotifications(patientId, now) {
  const user = await findOne('users', { id: patientId });
  if (!user?.prefs) return;
  
  // Import dynamically to avoid circular dependency
  const { buildSlots } = await import('./adherence.service.js');
  const slots = await buildSlots(patientId, now.day, now.day, now);
  
  for (const s of slots) {
    if (s.status === 'due' && user.prefs.doseReminders) {
      await createNotification(patientId, 'reminder', `Time for ${s.label}`, `Scheduled at ${s.slot}`, `dose-reminder-${s.regimenId}-${s.day}-${s.slot}`);
    }
    if (s.status === 'missed' && user.prefs.missedDose) {
      await createNotification(patientId, 'alert', `Missed: ${s.label}`, `Was due at ${s.slot}`, `dose-missed-${s.regimenId}-${s.day}-${s.slot}`);
    }
  }
}
