import { findOne, insertOne, updateOne, countDocs } from '../config/db.js';
import crypto from 'crypto';

export async function recordAnonymousVisit(visitorId) {
  const existing = await findOne('analytics_visits', { visitorId });
  if (existing) {
    await updateOne('analytics_visits', { visitorId }, {
      $inc: { visitCount: 1 },
      $set: { lastVisitAt: new Date().toISOString() },
    });
    return { returning: true };
  }
  await insertOne('analytics_visits', {
    id: crypto.randomUUID(),
    visitorId,
    visitCount: 1,
    lastVisitAt: new Date().toISOString(),
    createdAt: new Date().toISOString(),
  });
  return { returning: false };
}

export async function recordAuthenticatedVisit(userId) {
  await updateOne('users', { id: userId }, {
    $inc: { totalVisits: 1 },
    $set: { lastActiveAt: new Date().toISOString() },
  });
  return { ok: true };
}

export async function recordUserVisit(userOrId) {
  const userId = typeof userOrId === 'object' && userOrId !== null ? (userOrId.id || userOrId.uid) : userOrId;
  return recordAuthenticatedVisit(userId);
}

export async function getDashboardStats() {
  const totalUsers = await countDocs('users', {});
  const today = new Date().toISOString().slice(0, 10);
  const activeToday = await countDocs('users', {
    lastActiveAt: { $gte: today },
  });
  const returningUsers = await countDocs('users', { totalVisits: { $gt: 1 } });
  const anonymousVisits = await countDocs('analytics_visits', {});
  const anonymousActiveToday = await countDocs('analytics_visits', {
    lastVisitAt: { $gte: today },
  });
  const returningAnonymous = await countDocs('analytics_visits', { visitCount: { $gt: 1 } });
  
  return {
    totalUsers,
    activeToday,
    returningUsers,
    anonymousVisits,
    anonymousActiveToday,
    returningAnonymous,
    returningAnonymousVisitors: returningAnonymous,
    storage: 'mongodb',
  };
}