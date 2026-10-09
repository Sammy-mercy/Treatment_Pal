// controllers/user.controller.js
const userService = require('../services/user.service');

async function getUsers(req, res, next) {
  try {
    const role = req.query.role || 'patient';
    const users = await userService.getUsersByRole(role);
    res.status(200).json(users);
  } catch (error) {
    next(error);
  }
}

async function getUserById(req, res, next) {
  try {
    const user = await userService.getUserById(req.params.id);
    res.status(200).json(user);
  } catch (error) {
    next(error);
  }
}

async function updateProfile(req, res, next) {
  try {
    const id = req.params.id || req.user.id;
    const updated = await userService.updateProfile(id, req.body);
    res.status(200).json(updated);
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getUsers,
  getUserById,
  updateProfile
};
