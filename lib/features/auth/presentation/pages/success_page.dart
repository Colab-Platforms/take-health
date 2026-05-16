import 'package:flutter/material.dart';
import 'package:classroom_app/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:classroom_app/core/routes/app_routes.dart';
import '../widgets/auth_back_button.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const AuthBackButton(),
            const Spacer(flex: 2),
            
            // Success Icon (Clover shape)
            Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const _CloverLeaf(rotation: 0),
                    const _CloverLeaf(rotation: 1.57), // 90 deg
                    const _CloverLeaf(rotation: 3.14), // 180 deg
                    const _CloverLeaf(rotation: 4.71), // 270 deg
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            const Text(
              'Your account\nwas successfully created!',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading,
            ),
            
            const SizedBox(height: 12),
            
            const Text(
              'Only one click to explore online education.',
              textAlign: TextAlign.center,
              style: AppTextStyles.subheading,
            ),
            
            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  context.go(AppRoutes.splash); // Go back to beginning or login
                },
                child: const Text('Log in'),
              ),
            ),
            
            const Spacer(flex: 4),
            
            const _TermsCaption(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _CloverLeaf extends StatelessWidget {
  final double rotation;
  const _CloverLeaf({required this.rotation});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 40),
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

class _TermsCaption extends StatelessWidget {
  const _TermsCaption();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: AppTextStyles.caption,
          children: [
            TextSpan(text: 'By using Classroom, you agree to the\n'),
            TextSpan(
              text: 'Terms',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
