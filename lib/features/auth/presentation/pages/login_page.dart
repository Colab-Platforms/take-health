import 'package:flutter/material.dart';
import 'package:classroom_app/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:classroom_app/core/routes/app_routes.dart';
import '../widgets/auth_app_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

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
            const SizedBox(height: 60),

            Text(
              'Welcome Back',
              style: AppTextStyles.heading.copyWith(
                fontSize: 28,
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontFamily: 'SF Pro Display',
              ),
            ),
            Text(
              'Login to your account',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 1.1,
                fontFamily: 'SF Pro Display',
              ),
            ),

            const SizedBox(height: 30),

            // ── Email Field ───────────────────────────────────
            _buildField(
              label: 'Email Address',
              hint: 'admin@fitcure.com',
              icon: Icons.email_outlined,
              onChanged: (val) {},
            ),
            const SizedBox(height: 15),

            // ── Password Field ────────────────────────────────
            _buildField(
              label: 'Password',
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
              onChanged: (val) {},
            ),

            const SizedBox(height: 12),

            // ── Remember Me & Forgot Password ────────────────
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: (val) => setState(() => _rememberMe = val ?? false),
                    side: const BorderSide(color: Colors.black12, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Remember Me',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.resetAccess),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: 0.5,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ),
              ],
            ),

             const SizedBox(height: 15),

            // ── Sign In Button ───────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D4D3B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  context.push(AppRoutes.homePage);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sign In',
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

            const SizedBox(height: 35),

            // ── Create Account Link ──────────────────────────
            Center(
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.createAccount),
                child: Column(
                  children: [
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0D4D3B),
                        letterSpacing: 0.5,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
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
            color: Colors.black,
            letterSpacing: 0.8,
            fontFamily: 'SF Pro Display',
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          obscureText: obscureText,
          onChanged: onChanged,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26, fontWeight: FontWeight.w300,fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey.withValues(alpha: 0.4), size: 22),
            suffixIcon: suffixIcon,
            filled: true,
           // fillColor: const Color(0xFFF0F5F9),
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
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
      ],
    );
  }
}
