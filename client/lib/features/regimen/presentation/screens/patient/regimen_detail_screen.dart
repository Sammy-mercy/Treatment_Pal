// features/regimen/presentation/screens/patient/regimen_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:therapy_pal/core/theme/app_colors.dart';
import 'package:therapy_pal/features/regimen/logic/regimen_provider.dart';
import 'package:therapy_pal/features/regimen/presentation/widgets/regimen_card.dart';

class PatientRegimenDetailScreen extends StatelessWidget {
  final String regimenId;

  const PatientRegimenDetailScreen({super.key, required this.regimenId});

  @override
  Widget build(BuildContext context) {
    final regimenProvider = context.watch<RegimenProvider>();
    final regimen = regimenProvider.regimens.firstWhere(
      (r) => r.id == regimenId,
      orElse: () => regimenProvider.regimens.first,
    );

    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: AppBar(title: Text(regimen.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Plan Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(regimen.notes, style: const TextStyle(fontSize: 13, color: AppColors.muted, height: 1.4)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text('Started: ${regimen.startDate}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Prescribed Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.ink)),
          const SizedBox(height: 8),
          ...regimen.items.map((item) => RegimenCard(item: item, showActions: false)),
        ],
      ),
    );
  }
}
