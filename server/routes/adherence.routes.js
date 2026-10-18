import { Router } from 'express';
import { authenticateRequired } from '../middleware/authenticateRequired.js';
import { logAdherenceSchema, parse } from '../validators/adherence.validator.js';
import { findMany, insertOne } from '../config/db.js';
import crypto from 'crypto';

const router = Router();
router.use(authenticateRequired);

// GET /api/adherence-logs
router.get('/', async (req, res, next) => {
  try {
    const patientId = req.query.patientId || req.user.id;
    const logs = await findMany('adherence_logs', { patientId }, { sort: { scheduledAt: -1 } });
    res.json(logs);
  } catch (err) {
    next(err);
  }
});

// POST /api/adherence-logs - Patient logs dose taken/missed
router.post('/', async (req, res, next) => {
  try {
    const data = parse(logAdherenceSchema, req.body);
    const patientId = req.user.role === 'patient' ? req.user.id : (req.body.patientId || req.user.id);
    const now = new Date().toISOString();
    const log = {
      id: crypto.randomUUID(),
      regimenItemId: data.regimenItemId,
      patientId,
      status: data.status,
      scheduledAt: data.scheduledAt || now,
      loggedAt: now,
      notes: data.notes || '',
    };
    await insertOne('adherence_logs', log);
    res.status(201).json(log);
  } catch (err) {
    next(err);
  }
});

// GET /api/adherence-logs/compliance/:patientId?
router.get('/compliance/:patientId?', async (req, res, next) => {
  try {
    const patientId = req.params.patientId || req.user.id;
    const patientLogs = await findMany('adherence_logs', { patientId });
    if (!patientLogs.length) {
      return res.json({ rate: 100, total: 0, taken: 0, missed: 0 });
    }
    const taken = patientLogs.filter(l => l.status === 'taken').length;
    const missed = patientLogs.filter(l => l.status === 'missed').length;
    const rate = Math.round((taken / (taken + missed)) * 100);
    res.json({ rate, total: taken + missed, taken, missed });
  } catch (err) {
    next(err);
  }
});

export default router;
