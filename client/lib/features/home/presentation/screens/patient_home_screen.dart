// features/home/presentation/screens/patient_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/route_paths.dart';
import '../../../auth/logic/auth_provider.dart';
import '../../../regimen/logic/regimen_provider.dart';
import '../../../regimen/presentation/widgets/regimen_card.dart';
import '../../../adherence/logic/adherence_provider.dart';
import '../../../notifications/logic/notification_provider.dart';
import '../widgets/dashboard_summary_card.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final regimenProvider = context.watch<RegimenProvider>();
    final adherenceProvider = context.watch<AdherenceProvider>();
    final notifProvider = context.watch<NotificationProvider>();

    final allItems = regimenProvider.allItems;
    final compliance = adherenceProvider.complianceRate;

    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 18,
              child: Text(
                user?.initials ?? 'AR',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good morning, ${user?.firstName.isNotEmpty == true ? user!.firstName : "Alex"}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const Text('Recovery Plan Active',
                    style: TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: notifProvider.unreadCount > 0,
              label: Text('${notifProvider.unreadCount}'),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => context.push(RoutePaths.patientNotifications),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1000;
          final progressCard = DashboardSummaryCard(
            title: "Today's Progress",
            primaryMetric: "3 of 7 doses logged",
            subtitle: "Next: Ibuprofen 200 mg at 1:00 PM with food",
            progressPercent: compliance / 100.0,
          );
          final regimenSection = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Current Regimen',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.ink)),
                  TextButton(
                    onPressed: () => context.push(RoutePaths.patientRegimens),
                    child: const Text('View All',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...allItems.take(3).map(
                    (item) => RegimenCard(
                      item: item,
                      onLogDose: () {
                        adherenceProvider.logDose(item.id, 'taken');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('${item.drugName} dose logged!')),
                        );
                      },
                      onToggleActive: () {
                        regimenProvider.toggleItemActive('reg_01', item.id);
                      },
                    ),
                  ),
            ],
          );

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1152),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isWide ? 24 : 16),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 360, child: progressCard),
                          const SizedBox(width: 24),
                          Expanded(child: regimenSection),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          progressCard,
                          const SizedBox(height: 20),
                          regimenSection
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
