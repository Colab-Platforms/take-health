import 'package:flutter/material.dart';
import 'package:classroom_app/core/theme/app_theme.dart';

class PasswordValidationChecker extends StatelessWidget {
  final String password;
  const PasswordValidationChecker({super.key, required this.password});

  bool get hasMinLength => password.length >= 8;
  bool get hasNumber => password.contains(RegExp(r'[0-9]'));
  bool get hasSymbol => password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  int get strength {
    int count = 0;
    if (hasMinLength) count++;
    if (hasNumber) count++;
    if (hasSymbol) count++;
    return count;
  }

  Color get strengthColor {
    if (strength == 1) return Colors.red;
    if (strength == 2) return Colors.orange;
    if (strength == 3) return Colors.green;
    return Colors.grey.withValues(alpha: 0.2);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        // Strength bar
        Container(
          width: double.infinity,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: strength / 3,
            child: Container(
              decoration: BoxDecoration(
                color: strengthColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _RequirementItem(label: '8 characters minimum', isMet: hasMinLength),
        _RequirementItem(label: 'a number', isMet: hasNumber),
        _RequirementItem(label: 'a symbol', isMet: hasSymbol),
      ],
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String label;
  final bool isMet;
  const _RequirementItem({required this.label, required this.isMet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isMet ? Colors.green : Colors.grey.withValues(alpha: 0.3),
                width: 1.5,
              ),
              color: isMet ? Colors.green : Colors.transparent,
            ),
            child: isMet
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green : Colors.grey,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
