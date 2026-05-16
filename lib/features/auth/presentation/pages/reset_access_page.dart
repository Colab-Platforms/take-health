import 'package:flutter/material.dart';
import 'package:classroom_app/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:classroom_app/core/routes/app_routes.dart';
import '../widgets/auth_app_bar.dart';

class ResetAccessPage extends StatelessWidget {
  const ResetAccessPage({super.key});

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
            const SizedBox(height: 50),

            // ── Title ─────────────────────────────────────────
            Text(
              'RESET ACCESS',
              style: AppTextStyles.heading.copyWith(
                fontSize: 26,
                color: const Color(0xFF0D4D3B),
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text(
              'STEP 1 OF 3 • EMAIL',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 1.1,
              ),
            ),
            
            const SizedBox(height: 32),

            // ── Email Field ───────────────────────────────────
            _buildField(
              label: 'EMAIL ADDRESS',
              hint: 'Email Address',
              icon: Icons.email_outlined,
              onChanged: (val) {},
            ),

            const SizedBox(height: 32),

            // ── Send Code Button ─────────────────────────────
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
                onPressed: () => context.push(AppRoutes.verifyIdentity),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SEND CODE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 60),

            // ── Security Note ───────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F5F9).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey.withValues(alpha: 0.6),
                    height: 1.5,
                    letterSpacing: 0.5,
                  ),
                  children: const [
                    TextSpan(
                      text: 'SECURITY NOTE: ',
                      style: TextStyle(color: Color(0xFF0D4D3B)),
                    ),
                    TextSpan(
                      text: 'TAKE.HEALTH AI PLATFORM NEVER ASKS FOR YOUR PASSWORD OVER EMAIL. ALL PASSWORD RESETS ARE HANDLED THROUGH OUR SECURE VERIFICATION SYSTEM.',
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
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26, fontWeight: FontWeight.w500),
            prefixIcon: Icon(icon, color: Colors.grey.withValues(alpha: 0.4), size: 22),
            filled: true,
            fillColor: const Color(0xFFF0F5F9),
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
