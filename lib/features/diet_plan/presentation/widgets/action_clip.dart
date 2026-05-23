// lib/features/diet_plan/presentation/widgets/action_buttons.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// Define ActionChip in the same file
class ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isOutlined;
  final VoidCallback onTap;

  const ActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.isOutlined,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          decoration: BoxDecoration(
            color: isOutlined ? Colors.white : DietColors.primaryGreen,
            borderRadius: BorderRadius.circular(24),
            border: isOutlined
                ? Border.all(color: AppColors.inputBorder, width: 1.2)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isOutlined ? AppColors.textSecondary : AppColors.white,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isOutlined ? AppColors.textSecondary : AppColors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final VoidCallback onHistoryTap;
  final VoidCallback onPreferenceTap;
  final VoidCallback onRegenerateTap;

  const ActionButtons({
    super.key,
    required this.onHistoryTap,
    required this.onPreferenceTap,
    required this.onRegenerateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 16, 12),
      child: Row(
        children: [
          ActionChip(
            icon: Icons.history,
            label: 'HISTORY',
            isOutlined: true,
            onTap: onHistoryTap,
          ),
          const SizedBox(width: 8),
          ActionChip(
            icon: Icons.tune,
            label: 'PREFERENCE',
            isOutlined: true,
            onTap: onPreferenceTap,
          ),
          const SizedBox(width: 8),
          ActionChip(
            icon: Icons.refresh,
            label: 'REGEN PLAN',
            isOutlined: false,
            onTap: onRegenerateTap,
          ),
        ],
      ),
    );
  }
}