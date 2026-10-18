// controllers/adherence.controller.js
import * as adherenceService from '../services/adherence.service.js';
import { findMany, insertOne } from '../config/db.js';
import crypto from 'crypto';

export async function getLogs(req, res, next) {
  try {
    const patientId = req.query.patientId || req.user.id;
    const logs = await findMany('adherence_logs', { patientId }, { sort: { scheduledAt: -1 } });
    res.status(200).json(logs);
  } catch (error) {
    next(error);
  }
}

export async function logDose(req, res, next) {
  try {
    const patientId = req.user.role === 'patient' ? req.user.id : (req.body.patientId || req.user.id);
    const now = new Date().toISOString();
    const log = {
      id: crypto.randomUUID(),
      regimenItemId: req.body.regimenItemId,
      patientId,
      status: req.body.status,
      scheduledAt: req.body.scheduledAt || now,
      loggedAt: now,
      notes: req.body.notes || '',
    };
    await insertOne('adherence_logs', log);
    res.status(201).json(log);
  } catch (error) {
    next(error);
  }
}

export async function getCompliance(req, res, next) {
  try {
    const patientId = req.params.patientId || req.user.id;
    const patientLogs = await findMany('adherence_logs', { patientId });
    if (!patientLogs.length) return res.status(200).json({ rate: 100, total: 0, taken: 0, missed: 0 });
    const taken = patientLogs.filter((l) => l.status === 'taken').length;
    const missed = patientLogs.filter((l) => l.status === 'missed').length;
    const rate = Math.round((taken / (taken + missed)) * 100);
    res.status(200).json({ rate, total: taken + missed, taken, missed });
  } catch (error) {
    next(error);
  }
}

export default {
  getLogs,
  logDose,
  getCompliance
};
