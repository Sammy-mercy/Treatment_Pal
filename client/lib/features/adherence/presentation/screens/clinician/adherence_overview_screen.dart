// features/adherence/presentation/screens/clinician/adherence_overview_screen.dart
import 'package:flutter/material.dart';
import 'package:therapy_pal/core/theme/app_colors.dart';

class ClinicianAdherenceOverviewScreen extends StatelessWidget {
  const ClinicianAdherenceOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: AppBar(title: const Text('Panel Compliance Overview')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Panel Adherence Benchmark (80%)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  _patientBar('Alex Rivera', 92, AppColors.success),
                  _patientBar('Maya Chen', 88, AppColors.success),
                  _patientBar('Jordan Blake', 55, AppColors.danger),
                  _patientBar('Priya Nair', 76, AppColors.warn),
                  _patientBar('Sam Okafor', 81, AppColors.success),
                  _patientBar('Lena Fischer', 64, AppColors.danger),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('When Doses Slip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 8),
                  Text('• Evening (4:00 PM - 9:00 PM): 47% of missed doses', style: TextStyle(fontSize: 13, height: 1.5)),
                  Text('• Midday (11:00 AM - 4:00 PM): 29% of missed doses', style: TextStyle(fontSize: 13, height: 1.5)),
                  Text('• Morning (6:00 AM - 11:00 AM): 24% of missed doses', style: TextStyle(fontSize: 13, height: 1.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _patientBar(String name, int rate, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('$rate%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: rate / 100.0,
            backgroundColor: const Color(0xFFE3ECEE),
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
