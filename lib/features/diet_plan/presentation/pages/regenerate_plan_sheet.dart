import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/api_service.dart';

class RegeneratePlanSheet extends StatefulWidget {
  /// Called after a successful regeneration so the parent can refresh meals.
  final VoidCallback? onSuccess;
  final VoidCallback? onOpenPreference;

  const RegeneratePlanSheet({super.key, this.onSuccess, this.onOpenPreference});

  @override
  State<RegeneratePlanSheet> createState() => _RegeneratePlanSheetState();
}

class _RegeneratePlanSheetState extends State<RegeneratePlanSheet> {
  static const Color _green = Color(0xFF2E7D32);

  bool _loadingDifferent  = false;
  bool _loadingPreferred  = false;

  // ── Different Food ────────────────────────────────────────────────────────
  Future<void> _onDifferentFood() async {
    setState(() => _loadingDifferent = true);
    try {
      // 1. Generate a new plan with default (different) meals
      await ApiService.generateDietPlan(
        dietaryPreference: await _getSavedDietPreference(),
        allergies        : const [],
        fitnessGoals     : const [],
      );

      if (!mounted) return;
      Navigator.pop(context);
      widget.onSuccess?.call();       // ← tells DietPlanPage to re-fetch

    } on HttpException catch (e) {
      _showError(e.message);
    } on SocketException {
      _showError('No internet connection.');
    } catch (_) {
      _showError('Failed to regenerate plan. Please try again.');
    } finally {
      if (mounted) setState(() => _loadingDifferent = false);
    }
  }

  // ── Based on Preferred Food ───────────────────────────────────────────────
  Future<void> _onPreferredFood() async {
    if (widget.onOpenPreference != null) {
      widget.onOpenPreference!();
    } else {
      Navigator.pop(context);
    }
  }

  // ── Read saved diet preference from user profile ──────────────────────────
  Future<String> _getSavedDietPreference() async {
    try {
      final user = await ApiService.getUser();
      final pref = user?['profile']?['dietaryPreference'];
      if (pref != null && pref.toString().isNotEmpty) return pref.toString();
    } catch (_) {}
    return 'vegetarian';
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg,
            style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 4),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool anyLoading = _loadingDifferent || _loadingPreferred;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(24), bottom: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            children: [
              const Text('Regenerate Plan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A))),
              const Spacer(),
              GestureDetector(
                onTap: anyLoading ? null : () => Navigator.pop(context),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 17,
                      color: Color(0xFF555555)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Option 1 — Different Food ────────────────────────────────
          _buildOptionTile(
            icon    : Icons.auto_awesome_rounded,
            title   : 'Different Food',
            subtitle: 'Generate completely new variety of healthy Indian meals',
            isLoading: _loadingDifferent,
            disabled : anyLoading,
            onTap   : _onDifferentFood,
          ),
          const SizedBox(height: 12),

          // ── Option 2 — Based on Preferred Food ───────────────────────
          _buildOptionTile(
            icon    : Icons.restaurant_rounded,
            title   : 'Based on Preferred Food',
            subtitle: 'Update your favorites first, then generate a tailored plan',
            isLoading: _loadingPreferred,
            disabled : anyLoading,
            onTap   : _onPreferredFood,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData    icon,
    required String      title,
    required String      subtitle,
    required bool        isLoading,
    required bool        disabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isLoading ? const Color(0xFFF0F7F0) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isLoading ? _green : const Color(0xFFE8E8E8),
            width: 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon or spinner
            SizedBox(
              width: 22, height: 22,
              child: isLoading
                  ? const CircularProgressIndicator(
                  color: _green, strokeWidth: 2.2)
                  : Icon(icon, size: 22,
                  color: disabled ? Colors.grey : _green),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: disabled && !isLoading
                            ? Colors.grey
                            : const Color(0xFF1A1A1A),
                      )),
                  const SizedBox(height: 4),
                  Text(
                    isLoading ? 'Generating new plan...' : subtitle,
                    style: TextStyle(
                      fontSize: 12.5, height: 1.4,
                      color: isLoading ? _green : const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            if (!isLoading && !disabled)
              const Icon(Icons.chevron_right_rounded,
                  size: 20, color: Color(0xFFBBBBBB)),
          ],
        ),
      ),
    );
  }
}