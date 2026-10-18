import { Router } from 'express';
import { authenticateRequired } from '../middleware/authenticateRequired.js';
import { authorize } from '../middleware/authorize.js';
import { getDashboardStats } from '../services/analytics.service.js';

const router = Router();

// GET /api/admin/dashboard-stats
router.get('/dashboard-stats', authenticateRequired, authorize('admin'), async (_req, res, next) => {
  try {
    const stats = await getDashboardStats();
    res.json(stats);
  } catch (err) {
    next(err);
  }
});

export default router;