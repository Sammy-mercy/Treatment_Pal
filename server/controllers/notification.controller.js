// controllers/notification.controller.js
import * as notificationService from '../services/notification.service.js';

export async function getNotifications(req, res, next) {
  try {
    const list = await notificationService.getNotifications(req.user.id);
    res.status(200).json(list);
  } catch (error) {
    next(error);
  }
}

export async function markAllRead(req, res, next) {
  try {
    const result = await notificationService.markAllRead(req.user.id);
    res.status(200).json(result || { ok: true });
  } catch (error) {
    next(error);
  }
}

export async function registerToken(req, res, next) {
  try {
    const { token } = req.body;
    const result = await notificationService.registerDeviceToken(req.user.id, token);
    res.status(200).json(result);
  } catch (error) {
    next(error);
  }
}

export default {
  getNotifications,
  markAllRead,
  registerToken
};
