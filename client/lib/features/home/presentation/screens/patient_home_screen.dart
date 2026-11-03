// features/home/presentation/screens/patient_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routing/route_paths.dart';
import '../../../auth/logic/auth_provider.dart';
import '../../../regimen/logic/regimen_provider.dart';
import '../../../adherence/logic/adherence_provider.dart';
import '../../../notifications/logic/notification_provider.dart';

class DailyDoseItem {
  final String id;
  final String time;
  final String period;
  final String title;
  final String subtitle;
  final String actionLabel;
  bool isDone;

  DailyDoseItem({
    required this.id,
    required this.time,
    required this.period,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    this.isDone = false,
  });
}

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  static const Color headerBlue = Color(0xFF4C7B9C);
  static const Color accentBlue = Color(0xFF2E6DA4);
  static const Color backgroundMint = Color(0xFFE9F6F1);

  late List<DailyDoseItem> _doseItems;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _doseItems = [
      DailyDoseItem(
        id: 'item_01',
        time: '08:00',
        period: 'AM',
        title: 'Take Meds',
        subtitle: '(Ibuprofen 200mg)',
        actionLabel: 'Mark as Taken',
        isDone: true,
      ),
      DailyDoseItem(
        id: 'item_02',
        time: '01:00',
        period: 'PM',
        title: 'Physical Therapy',
        subtitle: '(Ankle Exercises - 15 min)',
        actionLabel: 'Mark as Done',
        isDone: false,
      ),
      DailyDoseItem(
        id: 'item_03',
        time: '06:00',
        period: 'PM',
        title: 'Take Meds',
        subtitle: '(Multivitamin)',
        actionLabel: 'Mark as Taken',
        isDone: false,
      ),
    ];
  }

  void _syncWithProviders(RegimenProvider regimenProvider, AdherenceProvider adherenceProvider) {
    if (_initialized) return;
    final items = regimenProvider.allItems;
    if (items.isNotEmpty) {
      _doseItems = items.map((it) {
        final timeStr = it.times.isNotEmpty ? it.times.first : '08:00';
        final parts = timeStr.split(':');
        final hour = int.tryParse(parts.first) ?? 8;
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        final displayTime = '${displayHour.toString().padLeft(2, '0')}:${parts.length > 1 ? parts[1] : "00"}';

        final isTherapy = it.isTherapy;
        return DailyDoseItem(
          id: it.id,
          time: displayTime,
          period: period,
          title: isTherapy ? 'Physical Therapy' : 'Take Meds',
          subtitle: '(${it.drugName} ${it.dosage})'.trim(),
          actionLabel: isTherapy ? 'Mark as Done' : 'Mark as Taken',
          isDone: false,
        );
      }).toList();
    }
    _initialized = true;
  }

  double get _adherenceFraction {
    if (_doseItems.isEmpty) return 0;
    final done = _doseItems.where((i) => i.isDone).length;
    return done / _doseItems.length;
  }

  void _toggleItem(int index) {
    setState(() {
      _doseItems[index].isDone = !_doseItems[index].isDone;
    });

    final item = _doseItems[index];
    if (item.isDone) {
      context.read<AdherenceProvider>().logDose(item.id, 'taken');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final regimenProvider = context.watch<RegimenProvider>();
    final adherenceProvider = context.watch<AdherenceProvider>();
    final notifProvider = context.watch<NotificationProvider>();

    _syncWithProviders(regimenProvider, adherenceProvider);

    final patientName = user?.name.isNotEmpty == true
        ? user!.name.split(' ').first
        : 'Alex';

    final logs = adherenceProvider.logs;

    return Scaffold(
      backgroundColor: backgroundMint,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context, patientName, notifProvider.unreadCount),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Today's Regimen Card
                        _buildTodaysRegimenCard(context),
                        const SizedBox(height: 24),

                        // Recent Logs Section
                        _buildRecentLogsSection(context, logs),
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

  Widget _buildHeader(BuildContext context, String name, int unreadNotifs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: const BoxDecoration(
        color: headerBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomPaint(
                size: const Size(36, 36),
                painter: _HeartCrossOutlinePainter(),
              ),
              InkWell(
                onTap: () => context.go(RoutePaths.patientNotifications),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                      if (unreadNotifs > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Good Morning, $name!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Recovery Plan Active · 3 sessions scheduled today',
            style: TextStyle(
              color: Color(0xFFD6EAEB),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysRegimenCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.go(RoutePaths.patientRegimens),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Regimen",
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.ink),
                ),
                Row(
                  children: [
                    Text(
                      'View All (${_doseItems.length})',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accentBlue),
                    ),
                    const Icon(Icons.chevron_right, color: accentBlue, size: 20),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < _doseItems.length; i++) ...[
            _buildRegimenRow(i),
            if (i != _doseItems.length - 1)
              const Divider(height: 24, thickness: 1, color: Color(0xFFEFF3F4)),
          ],
          const SizedBox(height: 20),
          _buildAdherenceRow(),
        ],
      ),
    );
  }

  Widget _buildRegimenRow(int index) {
    final item = _doseItems[index];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 58,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.time,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.ink),
              ),
              Text(
                item.period,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: item.isDone ? AppColors.muted : AppColors.ink,
                            decoration: item.isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        Text(
                          item.subtitle,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: item.isDone,
                    activeColor: accentBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    onChanged: (_) => _toggleItem(index),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _toggleItem(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: item.isDone ? const Color(0xFFE8F6EF) : const Color(0xFFE9F5F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                        size: 15,
                        color: item.isDone ? const Color(0xFF1A8754) : accentBlue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.isDone ? 'Completed' : item.actionLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: item.isDone ? const Color(0xFF1A8754) : accentBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdherenceRow() {
    final percent = (_adherenceFraction * 100).round();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _adherenceFraction,
                  strokeWidth: 3.5,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(accentBlue),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Adherence: $percent%',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.ink),
                ),
                Text(
                  '${_doseItems.where((i) => i.isDone).length} of ${_doseItems.length} tasks recorded today',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLogsSection(BuildContext context, List<dynamic> logs) {
    final List<Map<String, String>> displayLogs = logs.isNotEmpty
        ? logs.take(3).map((l) {
            final isTaken = l.status == 'taken';
            return {
              'label': isTaken ? 'Dose taken on schedule' : 'Dose missed',
              'detail': 'Regimen Item ID: ${l.regimenItemId} · Status: ${l.status.toUpperCase()}',
              'isTaken': isTaken ? 'true' : 'false',
            };
          }).toList()
        : [
            {
              'label': 'Meds taken at 08:05 AM',
              'detail': 'Ibuprofen 200mg',
              'isTaken': 'true',
            },
            {
              'label': 'Meds taken at 08:06 AM',
              'detail': 'Morning Vitamin C & Zinc',
              'isTaken': 'true',
            },
            {
              'label': 'Physical therapy completed at 09:20 AM',
              'detail': 'Ankle Exercises (15 min set)',
              'isTaken': 'true',
            },
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Logs',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.ink),
            ),
            TextButton(
              onPressed: () => context.go(RoutePaths.patientAdherence),
              child: const Text('Full History', style: TextStyle(fontWeight: FontWeight.bold, color: accentBlue)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final log in displayLogs) ...[
          _buildLogRow(log),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildLogRow(Map<String, String> log) {
    final isTaken = log['isTaken'] == 'true';
    return Container(
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
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isTaken ? const Color(0xFFE8F6EF) : const Color(0xFFFDEEF0),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTaken ? Icons.medication_outlined : Icons.warning_amber_rounded,
              color: isTaken ? const Color(0xFF1A8754) : const Color(0xFFC83E4D),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log['label'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  log['detail'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a white outline heart-with-medical-cross icon matching the reference design.
class _HeartCrossOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final heartPath = Path();
    heartPath.moveTo(w * 0.5, h * 0.88);
    heartPath.cubicTo(
      w * 0.08, h * 0.55,
      w * 0.02, h * 0.22,
      w * 0.28, h * 0.08,
    );
    heartPath.cubicTo(
      w * 0.40, h * 0.01,
      w * 0.5, h * 0.12,
      w * 0.5, h * 0.20,
    );
    heartPath.cubicTo(
      w * 0.5, h * 0.12,
      w * 0.60, h * 0.01,
      w * 0.72, h * 0.08,
    );
    heartPath.cubicTo(
      w * 0.98, h * 0.22,
      w * 0.92, h * 0.55,
      w * 0.5, h * 0.88,
    );

    canvas.drawPath(heartPath, strokePaint);

    // Medical cross in the center, filled white
    final crossPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final crossW = w * 0.14;
    final crossH = h * 0.34;
    final cx = w * 0.5;
    final cy = h * 0.42;

    final vertical = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: crossW, height: crossH),
      const Radius.circular(2),
    );
    final horizontal = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: crossH, height: crossW),
      const Radius.circular(2),
    );
    canvas.drawRRect(vertical, crossPaint);
    canvas.drawRRect(horizontal, crossPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
