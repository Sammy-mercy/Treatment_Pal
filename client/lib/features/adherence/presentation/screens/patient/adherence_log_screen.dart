// features/adherence/presentation/screens/patient/adherence_log_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:therapy_pal/core/theme/app_colors.dart';
import 'package:therapy_pal/core/utils/date_formatter.dart';
import 'package:therapy_pal/features/adherence/logic/adherence_provider.dart';
import 'package:therapy_pal/features/adherence/presentation/widgets/adherence_status_badge.dart';

class PatientAdherenceLogScreen extends StatelessWidget {
  const PatientAdherenceLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adherenceProvider = context.watch<AdherenceProvider>();
    final logs = adherenceProvider.logs;

    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adherence History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.ink)),
            Text('Track dose compliance over time', style: TextStyle(fontSize: 12, color: AppColors.muted)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statCol('${adherenceProvider.complianceRate}%', 'Overall Rate', AppColors.primary),
                  _statCol('11', 'Day Streak', AppColors.ink),
                  _statCol('${logs.length}', 'Logged Events', AppColors.ink),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Recent Entries', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.ink)),
          const SizedBox(height: 8),
          ...logs.map(
            (log) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(log.regimenItemId == 'item_02' ? 'Ankle Exercises' : 'Ibuprofen 200 mg', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(DateFormatter.formatTimestamp(log.loggedAt), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                trailing: AdherenceStatusBadge(status: log.status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCol(String val, String label, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
