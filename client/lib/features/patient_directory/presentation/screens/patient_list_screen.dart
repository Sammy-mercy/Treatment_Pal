import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/route_paths.dart';
import '../../logic/patient_directory_provider.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PatientDirectoryProvider>();
    final patients = provider.patients;
    final filteredPatients = patients.where((patient) {
      final name = (patient['name'] as String? ?? '').toLowerCase();
      final regimen = (patient['regimen'] as String? ?? '').toLowerCase();
      return name.contains(_query) || regimen.contains(_query);
    }).toList();
    final atRiskCount = patients.where((patient) {
      return ((patient['rate'] as num?)?.toInt() ?? 0) < 80;
    }).length;
    final averageRate = patients.isEmpty
        ? 0
        : (patients.fold<int>(
                  0,
                  (sum, patient) =>
                      sum + ((patient['rate'] as num?)?.toInt() ?? 0),
                ) /
                patients.length)
            .round();

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PATIENT CARE',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Your patients',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Keep track of each care plan and spot who may need support.',
                            style: TextStyle(color: AppColors.muted, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Refresh patient list',
                      onPressed: provider.loadPatients,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 720 ? 3 : 1;
                    final gap = 12.0;
                    final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        SizedBox(
                          width: width,
                          child: _SummaryMetric(
                            icon: Icons.groups_2_outlined,
                            label: 'Active patients',
                            value: '${patients.length}',
                            accent: AppColors.primary,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: _SummaryMetric(
                            icon: Icons.track_changes_outlined,
                            label: 'Average adherence',
                            value: '$averageRate%',
                            accent: const Color(0xFF26734D),
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: _SummaryMetric(
                            icon: Icons.priority_high_rounded,
                            label: 'Needs attention',
                            value: '$atRiskCount',
                            accent: atRiskCount == 0
                                ? const Color(0xFF26734D)
                                : const Color(0xFFB65B25),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Care panel',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${filteredPatients.length} ${filteredPatients.length == 1 ? 'patient' : 'patients'}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search patients or regimens',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close),
                          ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (provider.isLoading && patients.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 72),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (filteredPatients.isEmpty)
                  _EmptyPatients(isSearching: _query.isNotEmpty)
                else
                  ...filteredPatients.map((patient) => _PatientTile(
                        patient: patient,
                        onTap: () => context.go(RoutePaths.clinicianMessages),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accent, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientTile extends StatelessWidget {
  final Map<String, dynamic> patient;
  final VoidCallback onTap;

  const _PatientTile({required this.patient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rate = (patient['rate'] as num?)?.toInt() ?? 0;
    final name = (patient['name'] as String?)?.trim().isNotEmpty == true
        ? patient['name'] as String
        : 'Patient';
    final initials = (patient['initials'] as String?)?.trim().isNotEmpty == true
        ? patient['initials'] as String
        : name.characters.first.toUpperCase();
    final regimen = (patient['regimen'] as String?)?.trim().isNotEmpty == true
        ? patient['regimen'] as String
        : 'Active care plan';
    final lastSeen = patient['last'] as String?;
    final statusColor = rate >= 80
        ? const Color(0xFF26734D)
        : rate >= 60
            ? const Color(0xFF9A6710)
            : const Color(0xFFB4443C);
    final statusLabel = rate >= 80 ? 'On track' : 'Needs review';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primaryLight,
          child: Text(
            initials.toUpperCase(),
            style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w800),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(regimen, style: const TextStyle(color: AppColors.ink2)),
              if (lastSeen != null) ...[
                const SizedBox(height: 4),
                Text('Last activity  $lastSeen', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              ],
            ],
          ),
        ),
        trailing: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 82),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$rate%', style: TextStyle(color: statusColor, fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPatients extends StatelessWidget {
  final bool isSearching;

  const _EmptyPatients({required this.isSearching});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.groups_outlined,
            size: 36,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            isSearching ? 'No matching patients' : 'Your care panel is empty',
            style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            isSearching
                ? 'Try a different name or regimen.'
                : 'Patients assigned to your care will appear here.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
