// features/adherence/presentation/widgets/adherence_status_badge.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/adherence_log_model.dart';

class AdherenceStatusBadge extends StatelessWidget {
  final AdherenceStatus status;

  const AdherenceStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isTaken = status == AdherenceStatus.taken;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isTaken ? AppColors.successBg : AppColors.dangerBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isTaken ? Icons.check_circle : Icons.error_outline,
            size: 14,
            color: isTaken ? AppColors.success : AppColors.danger,
          ),
          const SizedBox(width: 4),
          Text(
            isTaken ? 'Taken' : 'Missed',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isTaken ? AppColors.success : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}
