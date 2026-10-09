import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_paths.dart';
import '../../../../shared/widgets/brand_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) context.go(RoutePaths.login);
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          _navigationTimer?.cancel();
          context.go(RoutePaths.login);
        },
        child: DecoratedBox(
          decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1599A0), Color(0xFF07545B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const BrandLogo(
                            width: 56,
                            height: 56,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Therapy Pal',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'Your treatment regimen, reminders\nand clinician — in one calm place.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFE2F4F4),
                            height: 1.35,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 108,
                          height: 2,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white.withValues(alpha: 0.22),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 22),
                child: Text(
                  'CARE THAT KEEPS UP WITH YOU',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFB6D5D6),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}