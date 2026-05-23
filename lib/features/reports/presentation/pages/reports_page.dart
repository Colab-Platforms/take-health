import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  static const Color _primaryGreen = Color(0xFF2E7D32);
  static const Color _cardGreen = Color(0xFF4A7C6F);
  static const Color _bgColor = Color(0xFFF2F2F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green.shade50,
        elevation: 0,
        leadingWidth: 75,
        leading: const Padding(
          padding: EdgeInsets.only(left: 18, top: 5, bottom: 5),
          child: CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Hello Yoro!",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Good afternoon",
              style: TextStyle(
                color: Color(0xff5D8B74),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xff5D8B74),
                size: 22,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // ── Smart Lab Insights header ──────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
                ),
                child: const Icon(
                  Icons.monitor_heart_outlined,
                  size: 18,
                  color: _cardGreen,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Smart Lab Insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Upload your medical reports and let our AI translate complex jargon into actionable health insights and visualize your progress over time.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF555555),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // ── Upload Lab Report card ─────────────────────────────────────
          _buildUploadCard(context),
          const SizedBox(height: 16),

          // ── Comparative Analytics card ─────────────────────────────────
          _buildComparativeCard(),
          const SizedBox(height: 16),

          // ── Recent Archives card ───────────────────────────────────────
          _buildRecentArchivesCard(),
        ],
      ),

      // ── FABs ────────────────────────────────────────────────────────────
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'chat',
            mini: true,
            backgroundColor: _cardGreen,
            foregroundColor: Colors.white,
            elevation: 4,
            onPressed: () {},
            child: const Icon(Icons.chat_bubble_outline, size: 18),
          ),
        ],
      ),
    );
  }

  // ── Upload card ────────────────────────────────────────────────────────────
  Widget _buildUploadCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Upload icon
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F0),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDDDDDD), width: 1.2),
            ),
            child: const Icon(
              Icons.upload_file,
              size: 30,
              color: _cardGreen,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'UPLOAD LAB REPORT',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Drag & drop or tap to select PDF\nor image',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: () => _onUpload(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 15),
              decoration: BoxDecoration(
                color: _cardGreen,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'SELECT FILE',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Comparative Analytics card ─────────────────────────────────────────────
  Widget _buildComparativeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  size: 22,
                  color: _cardGreen,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COMPARATIVE\nANALYTICS',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: 0.3,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Trend mapping between two labs',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Empty state
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.monitor_heart_outlined,
                  size: 40,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                Text(
                  'Select report(s) from history\nto visualize analytics',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Recent Archives card ───────────────────────────────────────────────────
  Widget _buildRecentArchivesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  size: 22,
                  color: _cardGreen,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'RECENT ARCHIVES',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Empty state
          Center(
            child: Text(
              'No records found',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── Upload action ──────────────────────────────────────────────────────────
  void _onUpload(BuildContext context) {
    // TODO: open file picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File picker coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}