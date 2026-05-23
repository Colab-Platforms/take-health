import 'package:flutter/material.dart';

class RegeneratePlanSheet extends StatelessWidget {
  const RegeneratePlanSheet({super.key});

  static const Color _primaryGreen = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24),bottom: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Regenerate Plan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 17,
                    color: Color(0xFF555555),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Option 1 — Different Food
          _buildOptionTile(
            context,
            icon: Icons.auto_awesome_rounded,
            title: 'Different Food',
            subtitle: 'Generate completely new variety of healthy Indian meals',
            onTap: () {
              Navigator.pop(context);
              // TODO: handle Different Food regeneration
            },
          ),
          const SizedBox(height: 12),

          // Option 2 — Based on Preferred Food
          _buildOptionTile(
            context,
            icon: Icons.restaurant_rounded,
            title: 'Based on Preferred Food',
            subtitle:
            'Update your favorites first, then generate a tailored plan',
            onTap: () {
              Navigator.pop(context);
              // TODO: handle Preferred Food regeneration
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8E8E8), width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: _primaryGreen),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF757575),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}