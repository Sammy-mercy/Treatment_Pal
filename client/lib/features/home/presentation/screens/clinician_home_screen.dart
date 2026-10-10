// features/home/presentation/screens/clinician_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/route_paths.dart';
import '../../../auth/logic/auth_provider.dart';
import '../../../patient_directory/logic/patient_directory_provider.dart';
import '../widgets/dashboard_summary_card.dart';

class ClinicianHomeScreen extends StatelessWidget {
  const ClinicianHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final patientProvider = context.watch<PatientDirectoryProvider>();
    final patients = patientProvider.patients;

    final atRisk = patients.where((p) => (p['rate'] as int) < 80).length;

    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 18,
              child: Text(
                user?.initials ?? 'SC',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.name ?? 'Dr. Sarah Carter',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text(user?.specialization ?? 'Internal Medicine',
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1152),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Dashboard Summary Card (SHARED)
              DashboardSummaryCard(
                title: "Panel Adherence Benchmark",
                primaryMetric: "78% Avg Compliance",
                subtitle:
                    "$atRisk patients currently below the 80% target threshold",
                progressPercent: 0.78,
              ),
              const SizedBox(height: 20),

              // Patients Needing Attention
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Patients Needing Attention',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.ink)),
                  TextButton(
                    onPressed: () =>
                        context.push(RoutePaths.clinicianDirectory),
                    child: const Text('View All',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ...patients.map((p) {
                final rate = p['rate'] as int;
                final isGood = rate >= 80;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          isGood ? AppColors.successBg : AppColors.dangerBg,
                      child: Text(p['initials'] as String,
                          style: TextStyle(
                              color:
                                  isGood ? AppColors.success : AppColors.danger,
                              fontWeight: FontWeight.bold)),
                    ),
                    title: Text(p['name'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(p['regimen'] as String,
                        style: const TextStyle(fontSize: 12)),
                    trailing: Chip(
                      label: Text('$rate%',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isGood
                                  ? AppColors.success
                                  : AppColors.danger)),
                      backgroundColor:
                          isGood ? AppColors.successBg : AppColors.dangerBg,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
