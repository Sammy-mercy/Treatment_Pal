// controllers/user.controller.js
import * as userService from '../services/user.service.js';
import * as authService from '../services/auth.service.js';

export async function getUsers(req, res, next) {
  try {
    const role = req.query.role || 'patient';
    const users = await userService.getUsers(role);
    res.status(200).json(users);
  } catch (error) {
    next(error);
  }
}

export async function getUserById(req, res, next) {
  try {
    const user = await userService.getUserById(req.params.id);
    res.status(200).json(user);
  } catch (error) {
    next(error);
  }
}

export async function updateProfile(req, res, next) {
  try {
    const id = req.params.id || req.user.id;
    const updated = await authService.updateProfile(id, req.body);
    res.status(200).json(updated);
  } catch (error) {
    next(error);
  }
}

export default {
  getUsers,
  getUserById,
  updateProfile
};
