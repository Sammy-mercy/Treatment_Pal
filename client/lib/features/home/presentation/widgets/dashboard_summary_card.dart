// features/home/presentation/widgets/dashboard_summary_card.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DashboardSummaryCard extends StatelessWidget {
  final String title;
  final String primaryMetric;
  final String subtitle;
  final double progressPercent;
  final Widget? trailing;

  const DashboardSummaryCard({
    super.key,
    required this.title,
    required this.primaryMetric,
    required this.subtitle,
    required this.progressPercent,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppColors.muted),
                ),
                Text(
                  '${(progressPercent * 100).round()}%',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(primaryMetric, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.ink)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: progressPercent.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFE3ECEE),
              color: progressPercent >= 0.8 ? AppColors.primary : AppColors.warn,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            if (trailing != null) ...[
              const SizedBox(height: 12),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
