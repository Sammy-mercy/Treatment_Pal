// features/regimen/presentation/screens/clinician/create_regimen_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:therapy_pal/core/theme/app_colors.dart';
import 'package:therapy_pal/models/regimen_model.dart';
import 'package:therapy_pal/models/regimen_item_model.dart';
import 'package:therapy_pal/shared/widgets/app_text_field.dart';
import 'package:therapy_pal/shared/widgets/primary_button.dart';
import 'package:therapy_pal/features/regimen/logic/regimen_provider.dart';

class ClinicianCreateRegimenScreen extends StatefulWidget {
  const ClinicianCreateRegimenScreen({super.key});

  @override
  State<ClinicianCreateRegimenScreen> createState() => _ClinicianCreateRegimenScreenState();
}

class _ClinicianCreateRegimenScreenState extends State<ClinicianCreateRegimenScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _drugController = TextEditingController();
  final _dosageController = TextEditingController();
  RegimenItemType _type = RegimenItemType.medication;

  void _save() {
    if (_titleController.text.isEmpty || _drugController.text.isEmpty) return;

    final newRegimen = RegimenModel(
      id: 'reg_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      clinicianId: 'usr_clinician_01',
      patientId: 'usr_patient_01',
      status: 'active',
      notes: _notesController.text.trim(),
      startDate: DateTime.now().toIso8601String().split('T')[0],
      items: [
        RegimenItemModel(
          id: 'item_${DateTime.now().millisecondsSinceEpoch}',
          regimenId: 'reg_new',
          drugName: _drugController.text.trim(),
          dosage: _dosageController.text.trim().isEmpty ? '200 mg' : _dosageController.text.trim(),
          type: _type,
          frequency: '2 times daily',
          times: ['08:00', '20:00'],
          instructions: 'As directed by physician',
        )
      ],
    );

    context.read<RegimenProvider>().addRegimen(newRegimen);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: AppBar(title: const Text('Prescribe New Regimen')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppTextField(label: 'Regimen Title', controller: _titleController, hintText: 'e.g. Post-Op Shoulder Recovery'),
          const SizedBox(height: 16),
          AppTextField(label: 'Clinical Notes', controller: _notesController, hintText: 'Precautions or dietary guidance', maxLines: 2),
          const SizedBox(height: 20),
          const Text('First Treatment Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          AppTextField(label: 'Medication or Exercise Name', controller: _drugController, hintText: 'e.g. Naproxen'),
          const SizedBox(height: 12),
          AppTextField(label: 'Dosage / Duration', controller: _dosageController, hintText: 'e.g. 500 mg or 20 min set'),
          const SizedBox(height: 16),
          DropdownButtonFormField<RegimenItemType>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: const [
              DropdownMenuItem(value: RegimenItemType.medication, child: Text('Medication')),
              DropdownMenuItem(value: RegimenItemType.therapy, child: Text('Physical Therapy')),
            ],
            onChanged: (val) => setState(() => _type = val ?? RegimenItemType.medication),
          ),
          const SizedBox(height: 28),
          PrimaryButton(label: 'Create & Assign to Patient', onPressed: _save),
        ],
      ),
    );
  }
}
