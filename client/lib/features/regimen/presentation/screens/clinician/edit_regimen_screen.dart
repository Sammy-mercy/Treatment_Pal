// features/regimen/presentation/screens/clinician/edit_regimen_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:therapy_pal/core/theme/app_colors.dart';
import 'package:therapy_pal/shared/widgets/app_text_field.dart';
import 'package:therapy_pal/shared/widgets/primary_button.dart';
import 'package:therapy_pal/features/regimen/logic/regimen_provider.dart';

class ClinicianEditRegimenScreen extends StatefulWidget {
  final String regimenId;

  const ClinicianEditRegimenScreen({super.key, required this.regimenId});

  @override
  State<ClinicianEditRegimenScreen> createState() => _ClinicianEditRegimenScreenState();
}

class _ClinicianEditRegimenScreenState extends State<ClinicianEditRegimenScreen> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  String _status = 'active';

  @override
  void initState() {
    super.initState();
    final provider = context.read<RegimenProvider>();
    final regimen = provider.regimens.firstWhere((r) => r.id == widget.regimenId, orElse: () => provider.regimens.first);
    _titleController = TextEditingController(text: regimen.title);
    _notesController = TextEditingController(text: regimen.notes);
    _status = regimen.status;
  }

  void _update() {
    final provider = context.read<RegimenProvider>();
    final regimen = provider.regimens.firstWhere((r) => r.id == widget.regimenId);
    regimen.status = _status;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: AppBar(title: const Text('Edit Regimen')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppTextField(label: 'Regimen Title', controller: _titleController),
          const SizedBox(height: 16),
          AppTextField(label: 'Clinical Notes', controller: _notesController, maxLines: 3),
          const SizedBox(height: 20),
          const Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.ink2)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(),
            items: const [
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'paused', child: Text('Paused')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
            ],
            onChanged: (val) => setState(() => _status = val ?? 'active'),
          ),
          const SizedBox(height: 28),
          PrimaryButton(label: 'Save Changes', onPressed: _update),
        ],
      ),
    );
  }
}
