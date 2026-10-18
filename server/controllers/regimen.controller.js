// controllers/regimen.controller.js
import * as regimenService from '../services/regimen.service.js';

export async function getRegimens(req, res, next) {
  try {
    const patientId = req.user.role === 'clinician' && req.query.patientId ? req.query.patientId : req.user.id;
    const regimens = await regimenService.getRegimens(patientId);
    res.status(200).json(regimens);
  } catch (error) {
    next(error);
  }
}

export async function getRegimenById(req, res, next) {
  try {
    const regimen = await regimenService.getRegimenById(req.params.id);
    res.status(200).json(regimen);
  } catch (error) {
    next(error);
  }
}

export async function createRegimen(req, res, next) {
  try {
    const patientId = req.body.patientId || req.user.id;
    const prescriberId = req.body.patientId ? req.user.id : null;
    const newRegimen = await regimenService.createRegimen(patientId, prescriberId, req.body);
    res.status(201).json(newRegimen);
  } catch (error) {
    next(error);
  }
}

export async function updateRegimen(req, res, next) {
  try {
    const updated = await regimenService.updateRegimen(req.params.id, req.user.id, req.body);
    res.status(200).json(updated);
  } catch (error) {
    next(error);
  }
}

export default {
  getRegimens,
  getRegimenById,
  createRegimen,
  updateRegimen,
};
