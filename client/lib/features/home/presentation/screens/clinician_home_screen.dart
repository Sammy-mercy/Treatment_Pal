// features/home/presentation/screens/clinician_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/route_paths.dart';
import '../../../auth/logic/auth_provider.dart';
import '../../../patient_directory/logic/patient_directory_provider.dart';

enum AdherenceTrafficStatus { good, warning, poor }

class ClinicianHomeScreen extends StatelessWidget {
  const ClinicianHomeScreen({super.key});

  static const Color headerBlueStart = Color(0xFF4C7B9C);
  static const Color headerBlueEnd = Color(0xFF3F8F87);
  static const Color primaryGreen = Color(0xFF3E8E5A);
  static const Color backgroundMint = Color(0xFFE9F6F1);

  static const List<Map<String, dynamic>> _fallbackPatients = [
    {
      'id': 'p1',
      'name': 'Alex Rivera',
      'initials': 'AR',
      'regimen': 'Ibuprofen · Ankle Exercises',
      'rate': 92,
      'status': AdherenceTrafficStatus.good,
    },
    {
      'id': 'p2',
      'name': 'Maya Chen',
      'initials': 'MC',
      'regimen': 'Lisinopril 10 mg',
      'rate': 88,
      'status': AdherenceTrafficStatus.good,
    },
    {
      'id': 'p3',
      'name': 'Jordan Blake',
      'initials': 'JB',
      'regimen': 'PT Plan (Shoulder)',
      'rate': 55,
      'status': AdherenceTrafficStatus.warning,
    },
    {
      'id': 'p4',
      'name': 'Daniel Marc',
      'initials': 'DM',
      'regimen': 'Medication Protocol v1',
      'rate': 48,
      'status': AdherenceTrafficStatus.poor,
    },
  ];

  Color _statusColor(int rate) {
    if (rate >= 80) return const Color(0xFF3CB371);
    if (rate >= 60) return const Color(0xFFF2B705);
    return const Color(0xFFE05A4E);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final patientProvider = context.watch<PatientDirectoryProvider>();
    final rawPatients = patientProvider.patients;

    final clinicianName = user?.name.isNotEmpty == true ? user!.name : 'Dr. Sarah Carter';
    final clinicianInitials = user?.initials.isNotEmpty == true ? user!.initials : 'SC';

    // Build safe patient list
    final List<Map<String, dynamic>> patientList = rawPatients.isNotEmpty
        ? rawPatients.map((p) {
            final rateVal = (p['rate'] as num?)?.toInt() ?? 82;
            final nameVal = (p['name'] as String?)?.isNotEmpty == true ? p['name'] as String : 'Patient';
            final initialsVal = (p['initials'] as String?)?.isNotEmpty == true
                ? p['initials'] as String
                : (nameVal.isNotEmpty ? nameVal[0] : 'P');
            final regimenVal = (p['regimen'] as String?)?.isNotEmpty == true
                ? p['regimen'] as String
                : 'Prescribed Regimen';
            return {
              'id': p['id']?.toString() ?? 'p_${nameVal.hashCode}',
              'name': nameVal,
              'initials': initialsVal,
              'regimen': regimenVal,
              'rate': rateVal,
            };
          }).toList()
        : _fallbackPatients;

    final atRiskCount = patientList.where((p) => ((p['rate'] as int?) ?? 100) < 80).length;
    final totalPatients = patientList.length;
    final avgRate = totalPatients > 0
        ? (patientList.fold<int>(0, (sum, p) => sum + ((p['rate'] as int?) ?? 0)) / totalPatients).round()
        : 85;

    return Scaffold(
      backgroundColor: backgroundMint,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context, clinicianName, clinicianInitials),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Benchmark Card
                        _buildBenchmarkCard(avgRate, atRiskCount, totalPatients),
                        const SizedBox(height: 24),

                        // Patient Overview Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Patient Overview',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => context.go(RoutePaths.clinicianDirectory),
                              icon: const Icon(Icons.arrow_forward, size: 16, color: primaryGreen),
                              label: const Text(
                                'View Directory',
                                style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Table Column Headers
                        _buildColumnHeaders(),
                        const SizedBox(height: 8),

                        // Patient Rows
                        for (final patient in patientList.take(6)) ...[
                          _buildPatientRow(context, patient),
                          const SizedBox(height: 10),
                        ],
                        const SizedBox(height: 16),

                        // Manage Patients Button
                        _buildManagePatientsButton(context),
                        const SizedBox(height: 28),

                        // Recent Clinical Messages Section
                        _buildMessageThreadCard(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String clinicianName, String clinicianInitials) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [headerBlueStart, headerBlueEnd],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: primaryGreen.withValues(alpha: 0.2),
            child: Text(
              clinicianInitials.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$clinicianName\n- Dashboard',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.go(RoutePaths.clinicianSettings),
            icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildBenchmarkCard(int avgRate, int atRiskCount, int totalPatients) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Panel Adherence Benchmark',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: avgRate >= 80 ? const Color(0xFFE8F6EF) : const Color(0xFFFEF7EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$avgRate% Avg Compliance',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: avgRate >= 80 ? const Color(0xFF1A8754) : const Color(0xFFC57B18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: avgRate / 100.0,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(avgRate >= 80 ? primaryGreen : const Color(0xFFF2B705)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            atRiskCount == 0
                ? 'All $totalPatients patients in your panel are currently meeting the 80% adherence goal.'
                : '$atRiskCount of $totalPatients patients currently below the 80% target threshold.',
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeaders() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'Patient Name',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ink2),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Current Regimen',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ink2),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Adherence Rate',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ink2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientRow(BuildContext context, Map<String, dynamic> patient) {
    final name = (patient['name'] as String?) ?? 'Patient';
    final initials = (patient['initials'] as String?) ?? 'PT';
    final regimen = (patient['regimen'] as String?) ?? 'General Plan';
    final rate = (patient['rate'] as int?) ?? 80;

    return InkWell(
      onTap: () => context.go(RoutePaths.clinicianDirectory),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: primaryGreen.withValues(alpha: 0.15),
                    child: Text(
                      initials.toUpperCase(),
                      style: const TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                regimen,
                style: const TextStyle(fontSize: 13, color: AppColors.ink2),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _statusColor(rate),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$rate%',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.ink),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagePatientsButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => context.go(RoutePaths.clinicianDirectory),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: const Text(
          'Manage Patients',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageThreadCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.chat_bubble_outline, color: primaryGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Clinical Inquiries & Messages',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.go(RoutePaths.clinicianMessages),
                child: const Text('Open Chat', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: backgroundMint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF4C7B9C),
                  child: Text('AR', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alex Rivera',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Can I take my evening dose an hour later? I have a late meeting today.',
                        style: TextStyle(fontSize: 12, color: AppColors.ink2),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.go(RoutePaths.clinicianMessages),
                  icon: const Icon(Icons.reply, color: primaryGreen, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
