// controllers/adherence.controller.js
const adherenceService = require('../services/adherence.service');

async function getLogs(req, res, next) {
  try {
    const patientId = req.query.patientId || req.user.id;
    const logs = await adherenceService.getLogsForPatient(patientId);
    res.status(200).json(logs);
  } catch (error) {
    next(error);
  }
}

async function logDose(req, res, next) {
  try {
    const patientId = req.user.role === 'patient' ? req.user.id : req.body.patientId;
    const log = await adherenceService.logDose(req.body, patientId);
    res.status(201).json(log);
  } catch (error) {
    next(error);
  }
}

async function getCompliance(req, res, next) {
  try {
    const patientId = req.params.patientId || req.user.id;
    const stats = await adherenceService.calculateCompliance(patientId);
    res.status(200).json(stats);
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getLogs,
  logDose,
  getCompliance
};
