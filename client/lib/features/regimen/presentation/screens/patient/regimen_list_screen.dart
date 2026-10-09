// features/regimen/presentation/screens/patient/regimen_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:therapy_pal/core/theme/app_colors.dart';
import 'package:therapy_pal/models/regimen_item_model.dart';
import 'package:therapy_pal/features/adherence/logic/adherence_provider.dart';
import 'package:therapy_pal/features/regimen/logic/regimen_provider.dart';
import 'package:therapy_pal/features/regimen/presentation/widgets/regimen_card.dart';

class PatientRegimenListScreen extends StatefulWidget {
  const PatientRegimenListScreen({super.key});

  @override
  State<PatientRegimenListScreen> createState() => _PatientRegimenListScreenState();
}

class _PatientRegimenListScreenState extends State<PatientRegimenListScreen> {
  String _filter = 'all'; // 'all', 'medication', 'therapy', 'paused'

  @override
  Widget build(BuildContext context) {
    final regimenProvider = context.watch<RegimenProvider>();
    final adherenceProvider = context.read<AdherenceProvider>();

    final allItems = regimenProvider.allItems;
    final filteredItems = allItems.filterItems(_filter);

    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Regimens', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.ink)),
            Text('Scheduled medication and therapies', style: TextStyle(fontSize: 12, color: AppColors.muted)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('all', 'All items'),
                const SizedBox(width: 8),
                _filterChip('medication', 'Medications'),
                const SizedBox(width: 8),
                _filterChip('therapy', 'Physical Therapy'),
                const SizedBox(width: 8),
                _filterChip('paused', 'Paused'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (filteredItems.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: const Text('No regimen items match this filter.', style: TextStyle(color: AppColors.muted)),
            )
          else
            ...filteredItems.map(
              (item) => RegimenCard(
                item: item,
                onLogDose: () {
                  adherenceProvider.logDose(item.id, 'taken');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.drugName} dose logged as taken!')),
                  );
                },
                onToggleActive: () {
                  final reg = regimenProvider.regimens.first;
                  regimenProvider.toggleItemActive(reg.id, item.id);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _filterChip(String id, String label) {
    final active = _filter == id;
    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => setState(() => _filter = id),
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: active ? Colors.white : AppColors.ink2,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

extension on List<RegimenItemModel> {
  List<RegimenItemModel> filterItems(String filter) {
    if (filter == 'medication') return where((i) => i.type == RegimenItemType.medication && i.active).toList();
    if (filter == 'therapy') return where((i) => i.type == RegimenItemType.therapy && i.active).toList();
    if (filter == 'paused') return where((i) => !i.active).toList();
    return this;
  }
}
