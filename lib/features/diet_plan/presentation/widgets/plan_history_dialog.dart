// lib/features/diet_plan/presentation/widgets/plan_history_dialog.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PlanHistoryItem {
  final String goal;
  final String date;
  final int kcal;
  final String type;
  final bool isActive;

  const PlanHistoryItem({
    required this.goal,
    required this.date,
    required this.kcal,
    required this.type,
    this.isActive = false,
  });
}

class PlanHistoryDialog extends StatelessWidget {
  const PlanHistoryDialog({super.key});

  static const List<PlanHistoryItem> _history = [
    PlanHistoryItem(
      goal: 'GENERAL HEALTH',
      date: 'Fri, May 15, 2026',
      kcal: 1602,
      type: 'Balanced',
      isActive: true,
    ), PlanHistoryItem(
      goal: 'MENTAL HEALTH',
      date: 'SAT, May 20, 2026',
      kcal: 1602,
      type: 'Balanced',
     // isActive: true,
    ),
    PlanHistoryItem(
      goal: 'GENERAL HEALTH',
      date: 'Wed, May 13, 2026',
      kcal: 1590,
      type: 'Balanced',
    ),    PlanHistoryItem(
      goal: 'GENERAL HEALTH',
      date: 'Wed, May 13, 2026',
      kcal: 1590,
      type: 'Balanced',
    ),    PlanHistoryItem(
      goal: 'GENERAL HEALTH',
      date: 'Wed, May 13, 2026',
      kcal: 1590,
      type: 'Balanced',
    ),
    PlanHistoryItem(
      goal: 'GENERAL HEALTH',
      date: 'Wed, May 13, 2026',
      kcal: 1590,
      type: 'Balanced',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.92,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.80,
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildHistoryCard(_history[index]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan History',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'PREVIOUS GENERATIONS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close,
              size: 18,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(PlanHistoryItem item) {
    if (item.isActive) {
      return _buildActiveCard(item);
    }
    return _buildInactiveCard(item);
  }

  Widget _buildActiveCard(PlanHistoryItem item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DietColors.cardGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tags row
                Row(
                  children: [
                    _buildTag(item.goal, active: true),
                    const SizedBox(width: 8),
                    _buildActiveNowTag(),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.date,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.kcal} kcal • ${item.type}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.white,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildInactiveCard(PlanHistoryItem item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTag(item.goal, active: false),
                const SizedBox(height: 10),
                Text(
                  item.date,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.kcal} kcal • ${item.type}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: DietColors.cardGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, {required bool active}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active ? Colors.white24 : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: active ? Colors.white : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildActiveNowTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'ACTIVE NOW',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}