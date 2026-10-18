import { Router } from 'express';
import { authenticateRequired } from '../middleware/authenticateRequired.js';
import { getNotifications, markAllRead, markOneRead, registerDeviceToken } from '../services/notification.service.js';

const router = Router();
router.use(authenticateRequired);

// GET /api/notifications
router.get('/', async (req, res, next) => {
  try {
    const result = await getNotifications(req.user.id);
    if (req.query.format === 'array') {
      return res.json(result.notifications);
    }
    res.json(result);
  } catch (err) {
    next(err);
  }
});

// POST /api/notifications/read-all
router.post('/read-all', async (req, res, next) => {
  try {
    await markAllRead(req.user.id);
    res.json({ ok: true });
  } catch (err) {
    next(err);
  }
});

// PATCH /api/notifications/:id/read
router.patch('/:id/read', async (req, res, next) => {
  try {
    await markOneRead(req.user.id, req.params.id);
    res.json({ ok: true });
  } catch (err) {
    next(err);
  }
});

// POST /api/notifications/register-token
router.post('/register-token', async (req, res, next) => {
  try {
    const { token } = req.body || {};
    const result = await registerDeviceToken(req.user.id, token);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

export default router;
