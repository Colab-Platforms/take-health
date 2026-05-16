import 'package:flutter/material.dart';
import 'package:classroom_app/core/theme/app_theme.dart';

/// Renders pill-shaped step dots (active = purple, inactive = grey).
class StepIndicator extends StatelessWidget {
  final int currentStep; // 1-based
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (i) {
        final isActive = i + 1 == currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 10,
          height: 5,
          decoration: BoxDecoration(
            color: isActive ? AppColors.stepActive : AppColors.stepInactive,
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}
