// lib/features/diet_plan/presentation/widgets/plan_history_dialog.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_theme.dart';

// ─── Model ───────────────────────────────────────────────────────────────────
class PlanHistoryItem {
  final String goal;
  final String date;
  final DateTime? rawDateObj;
  final int    kcal;
  final String type;
  final bool   isActive;

  const PlanHistoryItem({
    required this.goal,
    required this.date,
    this.rawDateObj,
    required this.kcal,
    required this.type,
    this.isActive = false,
  });

  /// Map from a single API object — handles multiple possible field names
  factory PlanHistoryItem.fromJson(Map<String, dynamic> json) {
    // ── goal ──────────────────────────────────────────────────────────────
    final goal = (json['goal']          ??
        json['healthGoal']    ??
        json['planGoal']      ??
        json['goalType']      ??
        'GENERAL HEALTH')
        .toString()
        .toUpperCase();

    // ── date ──────────────────────────────────────────────────────────────
    String date = 'Unknown date';
    DateTime? rawDateObj;
    final rawDate = json['createdAt']    ??
        json['date']         ??
        json['generatedAt']  ??
        json['updatedAt'];
    if (rawDate != null) {
      try {
        final dt = DateTime.parse(rawDate.toString()).toLocal();
        rawDateObj = dt;
        const months = [
          '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final dow = days[dt.weekday - 1];
        date = '$dow, ${months[dt.month]} ${dt.day}, ${dt.year}';
      } catch (_) {
        date = rawDate.toString();
      }
    }

    // ── kcal ──────────────────────────────────────────────────────────────
    final kcal = int.tryParse(
      (json['totalCalories'] ??
          json['calories']      ??
          json['kcal']          ??
          json['targetCalories'] ??
          0)
          .toString(),
    ) ??
        0;

    // ── type ──────────────────────────────────────────────────────────────
    final type = (json['planType']  ??
        json['type']      ??
        json['dietType']  ??
        'Balanced')
        .toString();

    // ── isActive ──────────────────────────────────────────────────────────
    final isActive = json['isActive'] == true || json['active'] == true;

    return PlanHistoryItem(
      goal    : goal,
      date    : date,
      rawDateObj: rawDateObj,
      kcal    : kcal,
      type    : type,
      isActive: isActive,
    );
  }
}

// ─── Dialog ──────────────────────────────────────────────────────────────────
class PlanHistoryDialog extends StatefulWidget {
  const PlanHistoryDialog({super.key});

  @override
  State<PlanHistoryDialog> createState() => _PlanHistoryDialogState();
}

class _PlanHistoryDialogState extends State<PlanHistoryDialog> {
  List<PlanHistoryItem> _items = [];
  bool   _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────
  Future<void> _fetchHistory() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final raw = await ApiService.getDietPlanHistory();
      final items = raw
          .whereType<Map<String, dynamic>>()
          .map(PlanHistoryItem.fromJson)
          .toList();

      // Fetch local logged meals
      try {
        final prefs = await SharedPreferences.getInstance();
        final logsJson = prefs.getString('local_meal_logs') ?? '[]';
        final logs = jsonDecode(logsJson) as List<dynamic>;
        for (var log in logs) {
          items.add(PlanHistoryItem.fromJson({
            'goal': log['name'] ?? 'Logged Meal',
            'date': log['date'],
            'kcal': log['kcal'] ?? 0,
            'type': 'Logged ${log['type'] ?? 'Meal'}',
            'isActive': false,
          }));
        }
      } catch (_) {}

      // Sort descending by date
      items.sort((a, b) {
        if (a.rawDateObj == null && b.rawDateObj == null) return 0;
        if (a.rawDateObj == null) return 1;
        if (b.rawDateObj == null) return -1;
        return b.rawDateObj!.compareTo(a.rawDateObj!);
      });

      setState(() { _items = items; _isLoading = false; });
    } on SocketException {
      setState(() { _error = 'No internet connection.'; _isLoading = false; });
    } on HttpException catch (e) {
      setState(() { _error = e.message; _isLoading = false; });
    } catch (e) {
      setState(() { _error = 'Failed to load history.'; _isLoading = false; });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
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

                // ── Body ──────────────────────────────────────────────────
                if (_isLoading)  _buildLoading()
                else if (_error != null) _buildError()
                else if (_items.isEmpty)  _buildEmpty()
                  else _buildList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Loading ───────────────────────────────────────────────────────────────
  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: DietColors.primaryGreen),
            SizedBox(height: 18),
            Text('Loading history...',
                style: TextStyle(fontSize: 13, color: Colors.grey,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────
  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56, height: 56,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Color(0xFFFFEBEB)),
            child: const Icon(Icons.wifi_off_rounded, color: Colors.red, size: 26),
          ),
          const SizedBox(height: 14),
          Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _fetchHistory,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: DietColors.cardGreen,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('Try Again',
                  style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty ─────────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Text('No history found',
            style: TextStyle(fontSize: 14, color: Colors.grey,
                fontStyle: FontStyle.italic)),
      ),
    );
  }

  // ── List ─────────────────────────────────────────────────────────────────
  Widget _buildList() {
    return Flexible(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _buildHistoryCard(_items[i]),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Plan History',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A))),
            const SizedBox(height: 4),
            const Text('PREVIOUS GENERATIONS',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                    letterSpacing: 1.2, color: Colors.grey)),
          ],
        ),
        const Spacer(),
        // Refresh button
        if (!_isLoading)
          GestureDetector(
            onTap: _fetchHistory,
            child: Container(
              width: 36, height: 36, margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: DietColors.cardGreen.withOpacity(.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh_rounded,
                  size: 18, color: DietColors.cardGreen),
            ),
          ),
        // Close button
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: Colors.grey.shade100, shape: BoxShape.circle),
            child: const Icon(Icons.close, size: 18, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  // ── Cards ─────────────────────────────────────────────────────────────────
  Widget _buildHistoryCard(PlanHistoryItem item) =>
      item.isActive ? _buildActiveCard(item) : _buildInactiveCard(item);

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
                Row(children: [
                  _buildTag(item.goal, active: true),
                  const SizedBox(width: 8),
                  _buildActiveNowTag(),
                ]),
                const SizedBox(height: 10),
                Text(item.date,
                    style: const TextStyle(fontSize: 18,
                        fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 4),
                Text('${item.kcal} kcal • ${item.type}',
                    style: const TextStyle(fontSize: 12, color: Colors.white70,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 24),
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
                Text(item.date,
                    style: const TextStyle(fontSize: 18,
                        fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 4),
                Text('${item.kcal} kcal • ${item.type}',
                    style: const TextStyle(fontSize: 12,
                        color: DietColors.cardGreen, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 24),
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
      child: Text(label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
              letterSpacing: .5,
              color: active ? Colors.white : Colors.grey)),
    );
  }

  Widget _buildActiveNowTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.white24, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          const Text('ACTIVE NOW',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                  letterSpacing: .5, color: Colors.white)),
        ],
      ),
    );
  }
}