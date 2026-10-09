// features/auth/presentation/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../models/user_model.dart';
import '../../../../routing/route_paths.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/brand_logo.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandLogo(width: 44, height: 44),
                const SizedBox(height: 16),
                const Text('Join Therapy Pal', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink)),
                const SizedBox(height: 6),
                const Text('Register your patient profile or clinical credential.', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                const SizedBox(height: 20),

                AppTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  validator: (v) => Validators.validateRequired(v, 'Full name'),
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 20),

                const Text('Account Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.ink2)),
                const SizedBox(height: 6),
                DropdownButtonFormField<UserRole>(
                  initialValue: _role,
                  decoration: const InputDecoration(),
                  items: const [
                    DropdownMenuItem(value: UserRole.patient, child: Text('Patient')),
                    DropdownMenuItem(value: UserRole.clinician, child: Text('Clinician / Prescriber')),
                  ],
                  onChanged: (val) => setState(() => _role = val ?? UserRole.patient),
                ),
                const SizedBox(height: 28),

                PrimaryButton(
                  label: 'Complete Registration',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.go(RoutePaths.login);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
