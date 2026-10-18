import { after, before, test } from 'node:test';
import assert from 'node:assert/strict';
import jwt from 'jsonwebtoken';
import { connectDB, disconnectDB } from '../config/db.js';
import app from '../app.js';

process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-only-secret-long-enough-for-hmac-signing';
process.env.ADMIN_EMAIL = 'admin@test.local';
process.env.ADMIN_PASSWORD = 'test-admin-password-strong';
process.env.ADMIN_TOKEN_SECRET = 'test-only-admin-secret-different-from-jwt-secret';
process.env.TEST_FIREBASE_TOKEN_SECRET = 'test-only-firebase-token-secret';

let server;
let baseUrl;

before(async () => {
  await connectDB();
  server = app.listen(0, '127.0.0.1');
  await new Promise((resolve) => server.once('listening', resolve));
  baseUrl = `http://127.0.0.1:${server.address().port}`;
});

after(async () => {
  if (server) await new Promise((resolve) => server.close(resolve));
  await disconnectDB();
});

async function request(path, { method = 'GET', body, token } = {}) {
  const response = await fetch(`${baseUrl}${path}`, {
    method,
    headers: {
      ...(body ? { 'Content-Type': 'application/json' } : {}),
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  return { status: response.status, body: await response.json() };
}

test('anonymous and registered visits are recorded; admin stats are restricted', async () => {
  const anonymous = await request('/api/analytics/visits', {
    method: 'POST',
    body: { visitorId: 'visitor_test_123' },
  });
  assert.equal(anonymous.status, 202);
  await request('/api/analytics/visits', {
    method: 'POST',
    body: { visitorId: 'visitor_test_123' },
  });

  const publicAdminSignup = await request('/api/auth/register', {
    method: 'POST',
    body: {
      name: 'Public Admin Attempt',
      email: 'public-admin@test.local',
      password: 'password123',
      role: 'admin',
    },
  });
  assert.equal(publicAdminSignup.status, 401);

  const firebaseIdentityToken = jwt.sign({
    uid: `firebase-user-${Date.now()}`,
    email: `analytics-${Date.now()}@test.local`,
  }, process.env.TEST_FIREBASE_TOKEN_SECRET);

  const signup = await request('/api/auth/register', {
    method: 'POST',
    body: {
      name: 'Analytics Test User',
      role: 'patient',
    },
    token: firebaseIdentityToken,
  });
  assert.equal(signup.status, 201);

  const session = await request('/api/auth/session', { method: 'POST', body: {}, token: firebaseIdentityToken });
  assert.equal(session.status, 200);
  assert.equal(session.body.user.role, 'patient');

  for (let visit = 0; visit < 2; visit++) {
    const tracked = await request('/api/analytics/visit', {
      method: 'POST',
      body: {},
      token: firebaseIdentityToken,
    });
    assert.equal(tracked.status, 200);
  }

  const unauthenticated = await request('/api/admin/dashboard-stats');
  assert.equal(unauthenticated.status, 401);

  const forbidden = await request('/api/admin/dashboard-stats', { token: firebaseIdentityToken });
  assert.equal(forbidden.status, 403);

  const forgedAdminToken = jwt.sign({ uid: 'attacker', role: 'admin' }, process.env.JWT_SECRET);
  const forgedAdmin = await request('/api/admin/dashboard-stats', { token: forgedAdminToken });
  assert.equal(forgedAdmin.status, 401);

  const badAdminLogin = await request('/api/auth/login', {
    method: 'POST',
    body: { email: process.env.ADMIN_EMAIL, password: 'wrong-password' },
  });
  assert.equal(badAdminLogin.status, 401);

  const adminLogin = await request('/api/auth/login', {
    method: 'POST',
    body: { email: process.env.ADMIN_EMAIL, password: process.env.ADMIN_PASSWORD },
  });
  assert.equal(adminLogin.status, 200);
  assert.equal(adminLogin.body.user.role, 'admin');

  const stats = await request('/api/admin/dashboard-stats', { token: adminLogin.body.token });
  assert.equal(stats.status, 200);
  assert.equal(stats.body.totalUsers, 1);
  assert.equal(stats.body.activeToday, 1);
  assert.equal(stats.body.returningUsers, 1);
  assert.equal(stats.body.anonymousVisits, 2);
  assert.equal(stats.body.anonymousActiveToday, 1);
  assert.equal(stats.body.returningAnonymousVisitors, 1);
  assert.equal(stats.body.storage, 'mongodb');
});