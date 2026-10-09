// controllers/regimen.controller.js
const regimenService = require('../services/regimen.service');

async function getRegimens(req, res, next) {
  try {
    const regimens = await regimenService.getRegimensForUser(req.user);
    res.status(200).json(regimens);
  } catch (error) {
    next(error);
  }
}

async function getRegimenById(req, res, next) {
  try {
    const regimen = await regimenService.getRegimenById(req.params.id);
    res.status(200).json(regimen);
  } catch (error) {
    next(error);
  }
}

async function createRegimen(req, res, next) {
  try {
    const newRegimen = await regimenService.createRegimen(req.body, req.user.id);
    res.status(201).json(newRegimen);
  } catch (error) {
    next(error);
  }
}

async function updateRegimen(req, res, next) {
  try {
    const updated = await regimenService.updateRegimen(req.params.id, req.body);
    res.status(200).json(updated);
  } catch (error) {
    next(error);
  }
}

async function toggleItem(req, res, next) {
  try {
    const { id, itemId } = req.params;
    const item = await regimenService.toggleItemActive(id, itemId);
    res.status(200).json(item);
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getRegimens,
  getRegimenById,
  createRegimen,
  updateRegimen,
  toggleItem
};
