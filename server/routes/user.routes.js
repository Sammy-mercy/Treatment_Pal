import { Router } from 'express';
import { authenticateRequired } from '../middleware/authenticateRequired.js';
import { authorize } from '../middleware/authorize.js';
import { getUsers, getUserById, getClinicianPatients, getPatientDetail, linkPatient } from '../services/user.service.js';
import { updateProfile } from '../services/auth.service.js';
import { z } from 'zod';

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

// Clinician: get patient panel
router.get('/patients', authorize('clinician'), async (req, res, next) => {
  try {
    const now = clientNow(req.query);
    const result = await getClinicianPatients(req.user.id, now);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

// Clinician: get single patient detail
router.get('/patients/:patientId', authorize('clinician'), async (req, res, next) => {
  try {
    const now = clientNow(req.query);
    const result = await getPatientDetail(req.user.id, req.params.patientId, now);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

// Clinician: link patient by email
router.post('/patients/link', authorize('clinician'), async (req, res, next) => {
  try {
    const schema = z.object({ email: z.string().email() });
    const { email } = schema.parse(req.body);
    const result = await linkPatient(req.user.id, email);
    res.json(result);
  } catch (err) {
    if (err.issues) {
      const e = new Error(err.issues[0].message);
      e.status = 400;
      return next(e);
    }
    next(err);
  }
});

// GET /api/users
router.get('/', authorize('clinician', 'admin'), async (req, res, next) => {
  try {
    const role = req.query.role;
    if (req.user.role === 'clinician' && role === 'patient') {
      const now = clientNow(req.query);
      const { patients } = await getClinicianPatients(req.user.id, now);
      if (patients.length > 0 || req.query.detailed === 'true') {
        return res.json(patients);
      }
    }
    const users = await getUsers(role);
    res.json(users);
  } catch (err) {
    next(err);
  }
});

// GET /api/users/:id
router.get('/:id', async (req, res, next) => {
  try {
    const user = await getUserById(req.params.id);
    res.json(user);
  } catch (err) {
    next(err);
  }
});

// PUT /api/users/:id/profile
router.put('/:id/profile', async (req, res, next) => {
  try {
    const id = req.params.id || req.user.id;
    const updated = await updateProfile(id, req.body);
    res.json(updated);
  } catch (err) {
    next(err);
  }
});

// PATCH /api/users/:id/profile
router.patch('/:id/profile', async (req, res, next) => {
  try {
    const id = req.params.id || req.user.id;
    const updated = await updateProfile(id, req.body);
    res.json(updated);
  } catch (err) {
    next(err);
  }
});

export default router;
