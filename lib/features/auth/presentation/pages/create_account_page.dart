import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classroom_app/core/theme/app_theme.dart';
import 'package:classroom_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import '../widgets/password_validation_checker.dart';
import '../widgets/auth_app_bar.dart';

import '../../../../core/routes/app_routes.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Match white background from Image 1
      appBar: const AuthAppBar(),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account created successfully!')),
            );
          }
          if (state.status == AuthStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Error')),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // ── Title ─────────────────────────────────────────
                Text(
                  'CREATE ACCOUNT',
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 25,
                    color: const Color(0xFF0D4D3B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'START YOUR HEALTH JOURNEY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.withValues(alpha: 0.6),
                    letterSpacing: 1.1,
                  ),
                ),
                
                const SizedBox(height: 32),

                // ── Form Fields ───────────────────────────────────
                _buildField(
                  label: 'FULL NAME *',
                  hint: 'Full Name',
                  icon: Icons.person_outline,
                  onChanged: (val) => context.read<AuthBloc>().add(AuthFullNameChanged(val)),
                ),
                const SizedBox(height: 20),
                
                _buildField(
                  label: 'EMAIL ADDRESS *',
                  hint: 'admin@fitcure.com',
                  icon: Icons.email_outlined,
                  onChanged: (val) => context.read<AuthBloc>().add(AuthEmailChanged(val)),
                ),
                const SizedBox(height: 20),
                
                _buildField(
                  label: 'PHONE NUMBER *',
                  hint: 'Phone Number',
                  icon: Icons.phone_outlined,
                  onChanged: (val) => context.read<AuthBloc>().add(AuthPhoneNumberChanged(val)),
                ),
                const SizedBox(height: 20),
                
                _buildField(
                  label: 'PASSWORD *',
                  hint: '••••••••••••••',
                  icon: Icons.lock_outline,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  onChanged: (val) => context.read<AuthBloc>().add(AuthPasswordChanged(val)),
                ),

                // ── Password Validation Checker ───────────────────
                if (state.password.isNotEmpty)
                  PasswordValidationChecker(password: state.password),
                
                const SizedBox(height: 32),

                // ── Continue Button ───────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D4D3B), // Dark green from Image 1
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: state.isSubmitEnabled
                        ? () => context.read<AuthBloc>().add(const AuthCreateAccountSubmitted())
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'CONTINUE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),

                // ── Footer ────────────────────────────────────────
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                      children: [
                        const TextSpan(text: 'ALREADY REGISTERED? '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => context.push(AppRoutes.login),
                            child: const Text(
                              'SIGN IN',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0D4D3B),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: obscureText,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize:15, color: Colors.black26, fontWeight: FontWeight.w300),
            prefixIcon: Icon(icon, color: Colors.grey.withValues(alpha: 0.4), size: 22),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF0F5F9), // Light blue-grey fill
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black12, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black12, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0D4D3B), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Reduced from 18
          ),
        ),
      ],
    );
  }
}
