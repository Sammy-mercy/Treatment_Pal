// controllers/analytics.controller.js
import * as analyticsService from '../services/analytics.service.js';

export async function recordAnonymousVisit(req, res, next) {
  try {
    const { visitorId } = req.body || {};
    if (typeof visitorId !== 'string' || !/^[a-zA-Z0-9_-]{8,100}$/.test(visitorId)) {
      return res.status(400).json({ error: 'A valid visitorId is required' });
    }
    const result = await analyticsService.recordAnonymousVisit(visitorId);
    return res.status(202).json(result);
  } catch (error) {
    return next(error);
  }
}

export async function recordUserVisit(req, res, next) {
  try {
    const result = await analyticsService.recordUserVisit(req.user);
    return res.status(200).json(result);
  } catch (error) {
    return next(error);
  }
}

export async function getDashboardStats(req, res, next) {
  try {
    return res.status(200).json(await analyticsService.getDashboardStats());
  } catch (error) {
    return next(error);
  }
}

export default { recordAnonymousVisit, recordUserVisit, getDashboardStats };