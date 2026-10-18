import { Router } from 'express';
import { authenticateRequired } from '../middleware/authenticateRequired.js';
import { authorize } from '../middleware/authorize.js';
import { createRegimenSchema, updateRegimenSchema, logDoseSchema, parse } from '../validators/regimen.validator.js';
import { getRegimens, createRegimen, updateRegimen } from '../services/regimen.service.js';
import { buildSlots, logDose, adherenceFor, streakDays, weeklyTrend, missedByPeriod, summarize } from '../services/adherence.service.js';

const router = Router();
router.use(authenticateRequired);

function clientNow(query = {}) {
  const now = new Date();
  const pad = n => String(n).padStart(2, '0');
  return {
    day: query.day || `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}`,
    time: query.time || `${pad(now.getHours())}:${pad(now.getMinutes())}`,
  };
}

// Patient: list own regimens
router.get('/', async (req, res, next) => {
  try {
    const patientId = req.user.role === 'clinician' && req.query.patientId ? req.query.patientId : req.user.id;
    const regimens = await getRegimens(patientId);
    res.json({ regimens });
  } catch (err) {
    next(err);
  }
});

// Patient: create own regimen
router.post('/', async (req, res, next) => {
  try {
    const data = parse(createRegimenSchema, req.body);
    const patientId = data.patientId || req.user.id;
    const prescriberId = data.patientId ? req.user.id : null;
    const regimen = await createRegimen(patientId, prescriberId, data);
    res.status(201).json({ regimen });
  } catch (err) {
    next(err);
  }
});

// Patient: update regimen
router.patch('/:id', async (req, res, next) => {
  try {
    const data = parse(updateRegimenSchema, req.body);
    const regimen = await updateRegimen(req.params.id, req.user.id, data);
    res.json({ regimen });
  } catch (err) {
    next(err);
  }
});

// Patient: today's doses
router.get('/today', async (req, res, next) => {
  try {
    const now = clientNow(req.query);
    const doses = await buildSlots(req.user.id, now.day, now.day, now);
    const taken = doses.filter(s => s.status === 'taken').length;
    const next2 = doses.find(s => s.status === 'due' || s.status === 'upcoming') || null;
    res.json({ day: now.day, doses, taken, total: doses.length, next: next2 });
  } catch (err) {
    next(err);
  }
});

// Patient: log a dose
router.post('/doses', async (req, res, next) => {
  try {
    const data = parse(logDoseSchema, req.body);
    const now = clientNow(req.query);
    const result = await logDose(req.user.id, data.regimenId, data.slot, now);
    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
});

// Patient: adherence stats
router.get('/adherence', async (req, res, next) => {
  try {
    const now = clientNow(req.query);
    const { slots, taken, missed, scheduled, rate } = await adherenceFor(req.user.id, now, 30);
    const todaySlots = await buildSlots(req.user.id, now.day, now.day, now);
    const todayStats = summarize(todaySlots);
    res.json({
      rate, taken, missed, scheduled,
      streak: streakDays(slots, now.day),
      dosesToday: todaySlots.length,
      weekly: weeklyTrend(slots, 6, now.day),
      slips: missedByPeriod(slots),
      todayTaken: todayStats.taken,
    });
  } catch (err) {
    next(err);
  }
});

// Patient: dose logs (14 day history)
router.get('/logs', async (req, res, next) => {
  try {
    const now = clientNow(req.query);
    const { addDays } = await import('../services/adherence.service.js');
    const slots = await buildSlots(req.user.id, addDays(now.day, -13), now.day, now);
    const logs = slots
      .filter(s => s.status === 'taken' || s.status === 'missed')
      .sort((a, b) => (a.day + (a.loggedTime || a.slot) < b.day + (b.loggedTime || b.slot) ? 1 : -1))
      .map(s => ({ day: s.day, label: s.label, time: s.loggedTime || s.slot, status: s.status }));
    res.json({ logs });
  } catch (err) {
    next(err);
  }
});

export default router;
