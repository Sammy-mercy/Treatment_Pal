// features/notifications/presentation/screens/notification_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/logic/auth_provider.dart';
import '../../logic/notification_provider.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Missed dose alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Notify when a scheduled dose is missed', style: TextStyle(fontSize: 12)),
                  value: provider.missedDoseAlerts,
                  activeThumbColor: AppColors.primary,
                  onChanged: provider.toggleMissedAlerts,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Dose reminders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Receive reminders 30 mins before scheduled dose', style: TextStyle(fontSize: 12)),
                  value: provider.doseReminders,
                  activeThumbColor: AppColors.primary,
                  onChanged: provider.toggleDoseReminders,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Clinician messages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Instant alerts for patient inquiries', style: TextStyle(fontSize: 12)),
                  value: provider.clinicianMessages,
                  activeThumbColor: AppColors.primary,
                  onChanged: provider.toggleMessages,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Weekly summary email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Send weekly compliance reports via email', style: TextStyle(fontSize: 12)),
                  value: provider.weeklySummary,
                  activeThumbColor: AppColors.primary,
                  onChanged: provider.toggleWeeklySummary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.danger),
              title: const Text(
                'Log out',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text('Sign out of your Therapy Pal account'),
              onTap: () => context.read<AuthProvider>().logout(),
            ),
          ),
        ],
      ),
    );
  }
}
