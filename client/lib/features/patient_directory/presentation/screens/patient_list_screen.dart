// features/patient_directory/presentation/screens/patient_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../logic/patient_directory_provider.dart';

class PatientListScreen extends StatelessWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PatientDirectoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: AppBar(
        title: const Text('Patient Directory'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...provider.patients.map((p) {
            final rate = p['rate'] as int;
            final isGood = rate >= 80;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(p['initials'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(p['regimen'] as String, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                trailing: Chip(
                  label: Text('$rate%', style: TextStyle(fontWeight: FontWeight.bold, color: isGood ? AppColors.success : AppColors.danger)),
                  backgroundColor: isGood ? AppColors.successBg : AppColors.dangerBg,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
