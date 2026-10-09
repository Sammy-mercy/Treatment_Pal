// controllers/notification.controller.js
const notificationService = require('../services/notification.service');

async function getNotifications(req, res, next) {
  try {
    const list = await notificationService.getNotifications(req.user.id);
    res.status(200).json(list);
  } catch (error) {
    next(error);
  }
}

async function markAllRead(req, res, next) {
  try {
    const result = await notificationService.markAllRead(req.user.id);
    res.status(200).json(result);
  } catch (error) {
    next(error);
  }
}

async function registerToken(req, res, next) {
  try {
    const { token } = req.body;
    const result = await notificationService.registerDeviceToken(req.user.id, token);
    res.status(200).json(result);
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getNotifications,
  markAllRead,
  registerToken
};
