import 'package:flutter/material.dart';
import 'package:classroom_app/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:classroom_app/core/routes/app_routes.dart';
import 'package:pinput/pinput.dart';
import '../widgets/password_validation_checker.dart';
import '../widgets/auth_app_bar.dart';

class VerifyIdentityPage extends StatelessWidget {
  const VerifyIdentityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 64,
      height: 64,
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: Color(0xFF0D4D3B),
        fontFamily: 'SF Pro Display',
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 1.5),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AuthAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ── Title ─────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Text(
                    'Verify Identity',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 28,
                      color: const Color(0xFF0D4D3B),
                      fontWeight: FontWeight.w800,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  Text(
                    'Step 2 of 3 • Code',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                      letterSpacing: 1.1,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),

            // ── Verification Code ────────────────────────────
            Center(
              child: Text(
                'Verification Code',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                  letterSpacing: 0.8,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Pinput(
                length: 4,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: const Color(0xFF0D4D3B), width: 1.5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Center(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                  children: [
                    const TextSpan(text: "Didn't receive code? "),
                    TextSpan(
                      text: 'Resend Code',
                      style: TextStyle(
                        color: const Color(0xFF0D4D3B),
                        decoration: TextDecoration.underline,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),

            // ── Verify Code Button ───────────────────────────
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
                onPressed: () => context.push(AppRoutes.secureAccount),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Verify Code',
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
                    fontFamily: 'SF Pro Display',
                  ),
                  children: const [
                    TextSpan(
                      text: 'Security Note: ',
                      style: TextStyle(color: Color(0xFF0D4D3B), fontFamily: 'SF Pro Display'),
                    ),
                    TextSpan(
                      text: 'Take.health AI platform never asks for your password over email. All password resets are handled through our secure verification system.',
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
}
