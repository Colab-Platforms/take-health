import 'package:flutter/material.dart';
import 'package:classroom_app/core/theme/app_theme.dart';

/// A generic outlined social-login button.
class SocialButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Widget? iconWidget;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialButton({
    super.key,
    required this.label,
    this.icon,
    this.iconWidget,
    this.onPressed,
    this.isLoading = false,
  });

  /// Facebook variant with brand colour icon
  factory SocialButton.facebook({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialButton(
      label: 'Continue with Facebook',
      onPressed: onPressed,
      isLoading: isLoading,
      iconWidget: _BrandIcon(
        color: const Color(0xFF1877F2),
        child: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 22),
      ),
    );
  }

  /// Google variant with coloured 'G'
  factory SocialButton.google({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialButton(
      label: 'Continue with Google',
      onPressed: onPressed,
      isLoading: isLoading,
      iconWidget: const _GoogleIcon(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.inputBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppColors.white,
        ),
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconWidget != null)
              iconWidget!
            else if (icon != null)
              Icon(icon, size: 22, color: AppColors.textPrimary),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandIcon extends StatelessWidget {
  final Color color;
  final Widget child;
  const _BrandIcon({required this.color, required this.child});

  @override
  Widget build(BuildContext context) => child;
}

/// Simple Google 'G' icon using colored text
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4285F4),
        fontFamily: 'sans-serif',
      ),
    );
  }
}
