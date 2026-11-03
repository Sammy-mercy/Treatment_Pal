// features/profile/presentation/screens/clinician_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/route_paths.dart';
import '../../../auth/logic/auth_provider.dart';

class ClinicianProfileScreen extends StatelessWidget {
  const ClinicianProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    final displayName = user?.name.isNotEmpty == true ? user!.name : 'Dr. Sarah Carter';
    final initials = user?.initials.isNotEmpty == true ? user!.initials : 'SC';
    final email = user?.email.isNotEmpty == true ? user!.email : 'dr.carter@hospital.org';
    final specialization = user?.specialization?.isNotEmpty == true ? user!.specialization! : 'Internal Medicine & Rehab';
    final npi = user?.npi?.isNotEmpty == true ? user!.npi! : '1849204921';

    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: AppBar(
        title: const Text('Clinician Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Avatar & Basic Info Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: const Color(0xFF3E8E5A),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            specialization,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9F6F1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Verified Clinician',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E8E5A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Credentials & Contact Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Professional Credentials',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.badge_outlined, 'NPI Number', npi),
                    const Divider(height: 24),
                    _buildInfoRow(Icons.email_outlined, 'Clinical Email', email),
                    const Divider(height: 24),
                    _buildInfoRow(Icons.medical_services_outlined, 'Primary Specialization', specialization),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Practice & Affiliations
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Practice Locations',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildClinicItem('Downtown Health Center', 'Main Outpatient Clinic · Mon, Wed, Fri'),
                    const Divider(height: 16),
                    _buildClinicItem('Westside Rehabilitation Care', 'Physical Therapy Wing · Tue, Thu'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // App Settings
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Portal Configuration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.notifications_none, color: AppColors.primary),
                      title: const Text('Notification Preferences', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Alert thresholds for missed doses and messages', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
                      onTap: () => context.go(RoutePaths.clinicianSettings),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Logout Button
              OutlinedButton.icon(
                onPressed: () {
                  authProvider.logout();
                  context.go(RoutePaths.login);
                },
                icon: const Icon(Icons.logout, color: AppColors.danger),
                label: const Text(
                  'Sign Out of Clinician Portal',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.dangerBg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF3E8E5A)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClinicItem(String name, String detail) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFE9F6F1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.local_hospital_outlined, color: Color(0xFF3E8E5A), size: 20),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(detail, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
    );
  }
}
