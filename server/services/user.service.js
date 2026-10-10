const db = require('../config/db');

function toPublicUser(document) {
  if (!document) return null;
  const { _id, ...user } = document;
  return { ...user, id: user.id || user.firebaseUid };
}

class UserService {
  async getUsersByRole(role) {
    const users = await db.findUsersByRole(role);
    return users.map(toPublicUser);
  }

  async getUserById(id) {
    const user = await db.findUserByAnyId(id);
    if (!user) throw { statusCode: 404, message: 'User not found' };
    return toPublicUser(user);
  }

  async updateProfile(id, updates) {
    const user = await db.findUserByAnyId(id);
    if (!user) throw { statusCode: 404, message: 'User not found' };
    const allowedUpdates = {};
    for (const field of ['name', 'phone', 'dob', 'specialization']) {
      if (typeof updates[field] === 'string') allowedUpdates[field] = updates[field];
    }
    await db.collection('users').updateOne({ firebaseUid: user.firebaseUid }, { $set: allowedUpdates });
    return toPublicUser({ ...user, ...allowedUpdates });
  }
}

module.exports = new UserService();