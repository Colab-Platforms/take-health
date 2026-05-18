import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (context.canPop()) {
          context.pop();
        } else {
          // Fallback if there's no history (e.g. deep link)
          // Usually go back to a safe place like splash or home
        }
      },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_back, size: 16, color: Color(0xFF0D4D3B)),
          SizedBox(width: 8),
          Text(
            'Back',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0D4D3B),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
