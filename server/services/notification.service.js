// services/notification.service.js

const notificationsStore = [
  {
    id: 'n1',
    kind: 'reminder',
    title: 'Take Ibuprofen in 30 min',
    body: 'Scheduled dose at 1:00 PM with food.',
    time: '12:30 PM',
    read: false,
    userId: 'usr_patient_01'
  },
  {
    id: 'n2',
    kind: 'regimen',
    title: 'New regimen assigned by Dr. Carter',
    body: 'Ankle Exercises (15 min set) added to your recovery plan.',
    time: 'Today · 09:12 AM',
    read: false,
    userId: 'usr_patient_01'
  },
  {
    id: 'n3',
    kind: 'message',
    title: 'Message from Dr. Carter',
    body: 'How is the ankle feeling after the new set of resistance exercises?',
    time: 'Today · 08:40 AM',
    read: false,
    userId: 'usr_patient_01'
  }
];

class NotificationService {
  async getNotifications(userId) {
    return notificationsStore.filter((n) => n.userId === userId || userId === 'usr_patient_01');
  }

  async markAllRead(userId) {
    notificationsStore.forEach((n) => {
      if (n.userId === userId || userId === 'usr_patient_01') {
        n.read = true;
      }
    });
    return { success: true };
  }

  async registerDeviceToken(userId, token) {
    console.log(`Registered device token for user ${userId}: ${token.substring(0, 10)}...`);
    return { success: true, registeredAt: new Date().toISOString() };
  }
}

module.exports = new NotificationService();
