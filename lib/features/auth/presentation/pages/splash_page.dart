import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:classroom_app/core/theme/app_theme.dart';

import '../../../../core/routes/app_routes.dart';

/// Screen 1 — Welcome / Splash
///
/// The purple overlay and gradient are designed to sit on top of a
/// [VideoPlayer] widget. Swap the [_VideoBackground] placeholder for your
/// actual video once the asset is ready (see comment inside the widget).
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _SplashBody(),
    );
  }
}

class _SplashBody extends StatelessWidget {
  const _SplashBody();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Layer 1: Video (or placeholder) ──────────────────
        const _VideoBackground(),

        // ── Layer 2: Gradient overlay ─────────────────────────
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryDark.withOpacity(0.55),
                AppColors.primaryDark.withOpacity(0.75),
                AppColors.primaryDark.withOpacity(0.92),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // ── Layer 3: Content ──────────────────────────────────
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                // Title block
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Classroom',
                      style: AppTextStyles.splashTitle,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Join over 10,000 learners over the World and\nenjoy online education!',
                      style: AppTextStyles.splashSubtitle,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Create account button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => context.push(AppRoutes.createAccount),
                    child: const Text(
                      'Create an account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Log in
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xCCFFFFFF),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push(AppRoutes.login);
                      },
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ── Video Background ──────────────────────────────────────────────────────
///
/// HOW TO USE YOUR OWN VIDEO:
/// 1. Add your video file to `assets/videos/` (e.g. `background.mp4`).
/// 2. Ensure `pubspec.yaml` lists `assets/videos/`.
/// 3. Replace the body of this widget with a [VideoPlayer] as shown below:
///
/// ```dart
/// class _VideoBackground extends StatefulWidget { ... }
/// class _VideoBackgroundState extends State<_VideoBackground> {
///   late VideoPlayerController _controller;
///
///   @override
///   void initState() {
///     super.initState();
///     _controller = VideoPlayerController.asset('assets/videos/background.mp4')
///       ..initialize().then((_) {
///           _controller.setLooping(true);
///           _controller.setVolume(0);
///           _controller.play();
///           setState(() {});
///         });
///   }
///
///   @override
///   void dispose() {
///     _controller.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return _controller.value.isInitialized
///         ? SizedBox.expand(
///             child: FittedBox(
///               fit: BoxFit.cover,
///               child: SizedBox(
///                 width: _controller.value.size.width,
///                 height: _controller.value.size.height,
///                 child: VideoPlayer(_controller),
///               ),
///             ),
///           )
///         : const ColoredBox(color: Color(0xFF2D1561));
///   }
/// }
/// ```
class _VideoBackground extends StatelessWidget {
  const _VideoBackground();

  @override
  Widget build(BuildContext context) {
    // ── Placeholder: purple gradient that mimics the video mood ──
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A0A35),
            Color(0xFF3B1A7A),
            Color(0xFF5B2DA8),
            Color(0xFF3B1A7A),
          ],
          stops: [0.0, 0.35, 0.65, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Decorative headphones-like circle (placeholder art)
          Positioned(
            top: -60,
            right: -80,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6C3FD1).withOpacity(0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Center icon hint
          Center(
            child: Icon(
              Icons.headphones_rounded,
              size: 140,
              color: Colors.white.withOpacity(0.07),
            ),
          ),
        ],
      ),
    );
  }
}
