import { Router } from 'express';
import { authenticateRequired } from '../middleware/authenticateRequired.js';
import { getThreads, getThread, sendMessage } from '../services/message.service.js';
import { z } from 'zod';

const router = Router();
router.use(authenticateRequired);

const sendSchema = z.object({ text: z.string().trim().min(1, 'Write a message first').max(2000) });

router.get('/threads', async (req, res, next) => {
  try {
    const result = await getThreads(req.user);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

router.get('/threads/:patientId', async (req, res, next) => {
  try {
    const result = await getThread(req.user, req.params.patientId);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

router.post('/threads/:patientId', async (req, res, next) => {
  try {
    const { text } = sendSchema.parse(req.body);
    const result = await sendMessage(req.user, req.params.patientId, text);
    res.status(201).json(result);
  } catch (err) {
    if (err.issues) {
      const e = new Error(err.issues[0].message);
      e.status = 400;
      return next(e);
    }
    next(err);
  }
});

export default router;
