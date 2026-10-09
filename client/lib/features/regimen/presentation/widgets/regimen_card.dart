// features/regimen/presentation/widgets/regimen_card.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/regimen_item_model.dart';

class RegimenCard extends StatefulWidget {
  final RegimenItemModel item;
  final VoidCallback? onLogDose;
  final VoidCallback? onToggleActive;
  final bool showActions;

  const RegimenCard({
    super.key,
    required this.item,
    this.onLogDose,
    this.onToggleActive,
    this.showActions = true,
  });

  @override
  State<RegimenCard> createState() => _RegimenCardState();
}

class _RegimenCardState extends State<RegimenCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isTherapy = widget.item.type == RegimenItemType.therapy;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isTherapy ? const Color(0xFFEAF3FB) : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isTherapy ? Icons.fitness_center : Icons.medication,
                      color: isTherapy ? const Color(0xFF1D5E8F) : AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.item.drugName} ${widget.item.dosage}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.ink),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.item.frequency,
                          style: const TextStyle(fontSize: 12, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      widget.item.active ? 'Active' : 'Paused',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: widget.item.active ? AppColors.success : AppColors.muted,
                      ),
                    ),
                    backgroundColor: widget.item.active ? AppColors.successBg : const Color(0xFFECF1F2),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.muted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1, color: AppColors.line),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              color: const Color(0xFFF9FBFC),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.item.instructions.isNotEmpty) ...[
                    const Text('Instructions:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ink2)),
                    const SizedBox(height: 4),
                    Text(widget.item.instructions, style: const TextStyle(fontSize: 12, color: AppColors.muted, height: 1.4)),
                    const SizedBox(height: 10),
                  ],
                  Text(
                    'Times: ${widget.item.times.join(" · ")}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                  ),
                  if (widget.showActions) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (widget.onLogDose != null)
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: widget.onLogDose,
                              child: const Text('Log a dose', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        if (widget.onLogDose != null && widget.onToggleActive != null)
                          const SizedBox(width: 8),
                        if (widget.onToggleActive != null)
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: widget.onToggleActive,
                              child: Text(widget.item.active ? 'Pause' : 'Resume', style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
