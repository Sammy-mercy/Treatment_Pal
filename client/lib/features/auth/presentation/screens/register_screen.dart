// features/auth/presentation/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../models/user_model.dart';
import '../../../../routing/route_paths.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/brand_logo.dart';
import '../../logic/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _role = UserRole.patient;

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();
    final registered = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _role,
    );
    if (!registered || !mounted) return;
    context.go(_role == UserRole.clinician
        ? RoutePaths.clinicianHome
        : RoutePaths.patientHome);
  }

  Widget _roleOption(UserRole role, String label) {
    final selected = _role == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.ink : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isWide = MediaQuery.of(context).size.width >= 900;

    final form = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    BrandLogo(width: 44, height: 44),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Therapy Pal',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColors.ink,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Treatment Regimen',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  'Create your account',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _role == UserRole.patient
                      ? 'Track your regimen and stay in touch with your care team.'
                      : 'Monitor adherence across your patient panel.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.muted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EEF0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _roleOption(UserRole.patient, 'Patient'),
                      _roleOption(UserRole.clinician, 'Clinician'),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (authProvider.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.dangerBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, size: 18, color: AppColors.danger),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            authProvider.errorMessage!,
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                AppTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  hintText: 'Your full name',
                  validator: (v) => Validators.validateRequired(v, 'Full name'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Email Address',
                  controller: _emailController,
                  hintText: 'name@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  hintText: 'At least 8 characters',
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: 'Complete Registration',
                  onPressed: _submitRegistration,
                  isLoading: authProvider.isLoading,
                ),
                const SizedBox(height: 14),
                Center(
                  child: TextButton(
                    onPressed: () => context.push(RoutePaths.login),
                    child: const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Already have an account?  ',
                            style: TextStyle(color: AppColors.muted, fontSize: 13.5),
                          ),
                          TextSpan(
                            text: 'Sign in',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: isWide
            ? Row(
                children: [
                  Expanded(
                    flex: 11,
                    child: form,
                  ),
                  Expanded(
                    flex: 9,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const BrandLogo(width: 44, height: 44),
                              ),
                              const SizedBox(height: 28),
                              const Text(
                                'Your treatment regimen, in one calm place.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Track doses, follow your schedule and stay in touch with your care team.',
                                style: TextStyle(
                                  color: Color(0xE6FFFFFF),
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 28),
                              _infoRow(Icons.schedule_outlined, 'Daily dose schedule with reminders'),
                              _infoRow(Icons.trending_up_rounded, 'Adherence you can see at a glance'),
                              _infoRow(Icons.chat_bubble_outline_rounded, 'Direct messages with your clinician'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : form,
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
