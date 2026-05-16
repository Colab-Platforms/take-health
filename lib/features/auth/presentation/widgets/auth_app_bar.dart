import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AuthAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80); // Increased height to accommodate the branding

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              // ── Back Button ──────────────────────────────────
              if (context.canPop())
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_back, size: 28, color: Color(0xFF0D4D3B)),
                      SizedBox(width: 8),
                      // Text(
                      //   'BACK',
                      //   style: TextStyle(
                      //     fontSize: 12,
                      //     fontWeight: FontWeight.w900,
                      //     color: Color(0xFF0D4D3B),
                      //     letterSpacing: 0.5,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              
              const Spacer(),
              
              // ── Logo branding ──────────────────────────────
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.change_history_rounded, color: Color(0xFF0D4D3B), size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'TAKE HEALTH',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0D4D3B),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              
              const Spacer(flex: 2), // Offset to center branding roughly or keep it right-aligned as per user preference
            ],
          ),
        ],
      ),
    );
  }
}
