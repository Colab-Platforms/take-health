import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:classroom_app/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:classroom_app/core/routes/app_routes.dart';
import 'package:http/http.dart' as http;
import '../widgets/password_validation_checker.dart';
import '../widgets/auth_app_bar.dart';

class SecureAccountPage extends StatefulWidget {
  final String email;
  final String code;

  const SecureAccountPage({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  State<SecureAccountPage> createState() => _SecureAccountPageState();
}

class _SecureAccountPageState extends State<SecureAccountPage> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _password = '';

  Future<void> _resetPassword() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
          'https://ai-healthcare-ip89.onrender.com/api/auth/reset-password',
        ),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': widget.email,
          'code': widget.code,
          'password': _password,
        }),
      );

      if (!mounted) return;

      // Handle HTML response (server cold start)
      if (response.body.startsWith('<!DOCTYPE html>')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Server is waking up. Please try again in a few seconds.',
            ),
          ),
        );
        return;
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Password reset successfully'),
            backgroundColor: const Color(0xFF0D4D3B),
          ),
        );
        context.go(AppRoutes.login);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Something went wrong'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network error. Please check your connection.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AuthAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            Text(
              'Secure Account',
              style: AppTextStyles.heading.copyWith(
                fontSize: 28,
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontFamily: 'SF Pro Display',
              ),
            ),

            const Text(
              'Step 3 of 3 • New Password',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 1.1,
                fontFamily: 'SF Pro Display',
              ),
            ),

            const SizedBox(height: 24),

            // PASSWORD FIELD
            _buildField(
              label: 'New Password',
              hint: 'New Password',
              icon: Icons.lock_outline,
              obscureText: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              onChanged: (val) => setState(() => _password = val),
            ),

            // PASSWORD VALIDATION CHECKER
            if (_password.isNotEmpty)
              PasswordValidationChecker(password: _password),

            const SizedBox(height: 16),

            // RESET PASSWORD BUTTON
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D4D3B),
                  disabledBackgroundColor: const Color(0xFF0D4D3B),
                  disabledForegroundColor: Colors.white.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: (_password.length >= 8 && !_isLoading)
                    ? _resetPassword
                    : null,
                child: _isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
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
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF121A2C),
            letterSpacing: 0.8,
            fontFamily: 'SF Pro Display',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: obscureText,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Colors.black26,
              fontWeight: FontWeight.w300,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: Colors.grey.withValues(alpha: 0.4),
              size: 22,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey.shade50,
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
              borderSide:
              const BorderSide(color: Color(0xFF0D4D3B), width: 1.5),
            ),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
      ],
    );
  }
}