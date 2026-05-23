// lib/features/diet_plan/presentation/widgets/lab_insights_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../presentation/pages/reports_page.dart';

class LabInsightsWidget extends StatelessWidget {
  final VoidCallback? onUploadReport;
  const LabInsightsWidget({super.key, this.onUploadReport});

  void _goToReports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReportsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lab Insights',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Biological markers',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // UPLOAD + button → goes to ReportsPage
              GestureDetector(
                onTap: onUploadReport,
                child: Row(
                  children: [
                    Text(
                      'UPLOAD',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: DietColors.cardGreen,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.add, size: 16, color: DietColors.cardGreen),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Empty state card ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFFDDDDDD), width: 1.2),
                  ),
                  child: Icon(
                    Icons.upload_rounded,
                    size: 24,
                    color: DietColors.cardGreen,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'NO REPORTS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'ADD LAB REPORTS TO GET\nBIOLOGICAL INSIGHTS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    letterSpacing: 0.3,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                // UPLOAD NOW → goes to ReportsPage
                GestureDetector(
                  onTap: onUploadReport,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 13),
                    decoration: BoxDecoration(
                      color: DietColors.cardGreen,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'UPLOAD NOW',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Recommendation row ───────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 15,
                color: DietColors.cardGreen,
              ),
              const SizedBox(width: 6),
              const Text(
                'RECOMMENDATION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Add details to unlock tailored insights.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF1A1A1A),
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}