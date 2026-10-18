import { Router } from 'express';
import { authenticateRequired } from '../middleware/authenticateRequired.js';
import { recordAnonymousVisit, recordUserVisit } from '../services/analytics.service.js';

const router = Router();

// POST /api/analytics/visits - Anonymous visits
router.post('/visits', async (req, res, next) => {
  try {
    const { visitorId } = req.body || {};
    if (typeof visitorId !== 'string' || !/^[a-zA-Z0-9_-]{8,100}$/.test(visitorId)) {
      return res.status(400).json({ error: 'A valid visitorId is required' });
    }
    const result = await recordAnonymousVisit(visitorId);
    return res.status(202).json(result);
  } catch (err) {
    return next(err);
  }
});

// POST /api/analytics/visit - Authenticated user visit
router.post('/visit', authenticateRequired, async (req, res, next) => {
  try {
    const result = await recordUserVisit(req.user);
    return res.status(200).json(result);
  } catch (err) {
    return next(err);
  }
});

export default router;