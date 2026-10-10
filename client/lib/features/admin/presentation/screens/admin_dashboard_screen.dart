import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/logic/auth_provider.dart';
import '../../../../routing/route_paths.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStats());
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response =
          await context.read<ApiClient>().get('/admin/dashboard-stats');
      if (!mounted) return;
      setState(() {
        _stats = Map<String, dynamic>.from(response as Map);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Widget _metricCard(
      {required String title, required dynamic value, required IconData icon}) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text('$value',
                      style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Analytics'),
        actions: [
          IconButton(
            tooltip: 'Refresh analytics',
            onPressed: _loading ? null : _loadStats,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go(RoutePaths.login);
            },
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth >= 720
                  ? (constraints.maxWidth - 24) / 2
                  : constraints.maxWidth;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_error!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: AppColors.danger)),
                                const SizedBox(height: 12),
                                FilledButton.icon(
                                    onPressed: _loadStats,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry')),
                              ],
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('User and traffic overview',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  SizedBox(
                                      width: cardWidth,
                                      child: _metricCard(
                                          title: 'Total Users',
                                          value: _stats?['totalUsers'] ?? 0,
                                          icon: Icons.people_outline)),
                                  SizedBox(
                                      width: cardWidth,
                                      child: _metricCard(
                                          title: 'Active Today',
                                          value: _stats?['activeToday'] ?? 0,
                                          icon: Icons.bolt_outlined)),
                                  SizedBox(
                                      width: cardWidth,
                                      child: _metricCard(
                                          title: 'Returning Users',
                                          value: _stats?['returningUsers'] ?? 0,
                                          icon: Icons.replay_outlined)),
                                  SizedBox(
                                      width: cardWidth,
                                      child: _metricCard(
                                          title: 'Anonymous Visits',
                                          value:
                                              _stats?['anonymousVisits'] ?? 0,
                                          icon: Icons.visibility_outlined)),
                                  SizedBox(
                                      width: cardWidth,
                                      child: _metricCard(
                                          title: 'Anonymous Active Today',
                                          value:
                                              _stats?['anonymousActiveToday'] ??
                                                  0,
                                          icon: Icons.person_search_outlined)),
                                  SizedBox(
                                      width: cardWidth,
                                      child: _metricCard(
                                          title: 'Returning Anonymous',
                                          value: _stats?[
                                                  'returningAnonymousVisitors'] ??
                                              0,
                                          icon: Icons.history_outlined)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _stats?['storage'] == 'firestore'
                                    ? 'Analytics storage: Firestore'
                                    : 'Analytics storage: development memory (configure Firebase credentials to persist data)',
                                style: const TextStyle(
                                    color: AppColors.muted, fontSize: 12),
                              ),
                            ],
                          ),
              );
            },
          ),
        ),
      ),
    );
  }
}
