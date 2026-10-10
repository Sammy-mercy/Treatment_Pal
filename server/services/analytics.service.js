const db = require('../config/db');

class AnalyticsService {
  async recordAnonymousVisit(visitorId, userAgent) {
    await db.recordVisit({
      visitorId,
      kind: 'anonymous',
      userAgent: String(userAgent || '').slice(0, 300),
      visitedAt: new Date(),
    });
    return { recorded: true };
  }

  async recordUserVisit(user) {
    if (!user || !user.id) throw { statusCode: 401, message: 'Authenticated user id is required' };
    const visitedAt = new Date();
    await db.updateUserVisit(user.id, {
      id: user.id,
      firebaseUid: user.id,
      email: user.email || null,
      name: user.name || null,
      role: user.role || null,
    }, visitedAt);
    await db.recordVisit({
      userId: user.id,
      kind: 'authenticated',
      visitedAt,
    });
    return { recorded: true, lastActiveAt: visitedAt.toISOString() };
  }

  async getDashboardStats() {
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);
    const [users, visits] = await Promise.all([db.getUsers(), db.getAnonymousVisits()]);
    const anonymousFrequency = new Map();
    const anonymousToday = new Set();

    for (const visit of visits) {
      anonymousFrequency.set(visit.visitorId, (anonymousFrequency.get(visit.visitorId) || 0) + 1);
      if (new Date(visit.visitedAt) >= todayStart) anonymousToday.add(visit.visitorId);
    }

    const registeredUsers = users.filter((user) => user.role !== 'admin');
    return {
      totalUsers: registeredUsers.length,
      activeToday: registeredUsers.filter((user) => user.lastActiveAt && new Date(user.lastActiveAt) >= todayStart).length,
      returningUsers: registeredUsers.filter((user) => (user.totalVisits || 0) > 1).length,
      anonymousVisits: visits.length,
      anonymousActiveToday: anonymousToday.size,
      returningAnonymousVisitors: [...anonymousFrequency.values()].filter((count) => count > 1).length,
      storage: 'mongodb',
    };
  }
}

module.exports = new AnalyticsService();