import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'clinical_page.dart';

// ─── Colors ──────────────────────────────────────────────────────────────────
const _kGreen      = Color(0xFF4A7C6F);
const _kGreenLight = Color(0xFFE8F2EF);
const _kInk        = Color(0xFF1A1A1A);
const _kMuted      = Color(0xFF888888);
const _kBg         = Color(0xFFF0F4F0);
const _kShadow     = Color(0x0D000000);

// ─── Model ───────────────────────────────────────────────────────────────────
class UploadedReport {
  final File   file;
  final String name;
  final DateTime uploadedAt;
  UploadedReport({required this.file, required this.name, required this.uploadedAt});
}

// ─── Top-level list — survives navigation, hot-reload, tab switches ───────────
final List<UploadedReport> uploadedReportsList = [];

// ─── Page ────────────────────────────────────────────────────────────────────
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  final ImagePicker _picker = ImagePicker();
  bool _isUploading  = false;
  UploadedReport? _lastUploaded;

  // ════════════════════════ UPLOAD LOGIC ═══════════════════════════════════

  Future<void> _showSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              ListTile(
                leading: _sheetIcon(Icons.photo_library_rounded),
                title: const Text('Choose from Gallery',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.gallery); },
              ),
              ListTile(
                leading: _sheetIcon(Icons.camera_alt_rounded),
                title: const Text('Take a Photo',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.camera); },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetIcon(IconData icon) => Container(
    width: 40, height: 40,
    decoration: BoxDecoration(color: _kGreenLight, borderRadius: BorderRadius.circular(12)),
    child: Icon(icon, color: _kGreen, size: 20),
  );

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) await _uploadFile(File(picked.path), picked.name);
    } catch (e) {
      _snack('Failed to pick image: $e', isError: true);
    }
  }

  Future<void> _uploadFile(File file, String name) async {
    setState(() { _isUploading = true; _lastUploaded = null; });
    try {
      await Future.delayed(const Duration(seconds: 2)); // replace with real API
      final report = UploadedReport(file: file, name: name, uploadedAt: DateTime.now());
      setState(() {
        uploadedReportsList.insert(0, report);          // newest first
        _lastUploaded = report;
      });
      _snack('$name uploaded successfully!');
    } catch (e) {
      _snack('Upload failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Report',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
          'Remove "${uploadedReportsList[index].name}" from your archives?',
          style: const TextStyle(color: _kMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: _kMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                final removed = uploadedReportsList.removeAt(index);
                if (_lastUploaded == removed) _lastUploaded = null;
              });
              _snack('Report removed');
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : _kGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ));
  }

  // ════════════════════════ BUILD ══════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildUploadCard(),
            const SizedBox(height: 16),
            _buildComparativeCard(),
            const SizedBox(height: 16),
            _buildArchivesCard(),
          ],
        ),

        // Loading overlay
        if (_isUploading)
          Container(
            color: Colors.black.withOpacity(.45),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_kGreen)),
                  SizedBox(height: 18),
                  Text('Uploading report...',
                      style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ],
              ),
            ),
          ),


      ],
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white, shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDDDDDD)),
            ),
            child: const Icon(Icons.monitor_heart_outlined, size: 18, color: _kGreen),
          ),
          const SizedBox(width: 10),
          const Text('Smart Lab Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _kInk)),
        ]),
        const SizedBox(height: 10),
        const Text(
          'Upload your medical reports and let our AI translate complex jargon '
              'into actionable health insights and visualize your progress over time.',
          style: TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.5),
        ),
      ],
    );
  }

  // ─── Upload Card ─────────────────────────────────────────────────────────
  Widget _buildUploadCard() {
    final bool hasLast = _lastUploaded != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: _kShadow, blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        children: [
          Container(
            width: 68, height: 68,
            decoration: BoxDecoration(
              color: _kBg, shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDDDDDD), width: 1.2),
            ),
            child: Icon(
              hasLast ? Icons.check_circle : Icons.upload_file,
              size: 30,
              color: hasLast ? Colors.green : _kGreen,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            hasLast ? 'LAB REPORT READY' : 'UPLOAD LAB REPORT',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                color: _kInk, letterSpacing: .5),
          ),
          const SizedBox(height: 8),
          Text(
            hasLast ? 'Ready for analysis'
                : 'Tap to select image from gallery or camera',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: _kMuted, height: 1.5),
          ),
          const SizedBox(height: 22),

          if (hasLast && !_isUploading) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                  const SizedBox(width: 10),
                  // File name + status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_lastUploaded!.name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        const Text('Upload completed successfully',
                            style: TextStyle(fontSize: 11, color: Colors.green)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Delete button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        uploadedReportsList.remove(_lastUploaded);
                        _lastUploaded = null;
                      });
                      _snack('File removed');
                    },
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          size: 17, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (!_isUploading) ...[
            GestureDetector(
              onTap: hasLast
                  ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClinicalSynthesisScreen()),
              ).then((_) {
                if (mounted) setState(() => _lastUploaded = null);
              })
                  : _showSourceDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 15),
                decoration: BoxDecoration(
                  color: hasLast ? Colors.green : _kGreen,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  hasLast ? 'ANALYZE REPORT' : 'SELECT FILE',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: 1.2),
                ),
              ),
            ),
            if (hasLast) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _showSourceDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: _kGreen, width: 1.5),
                  ),
                  child: const Text('UPLOAD ANOTHER',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                          color: _kGreen, letterSpacing: 1)),
                ),
              ),
            ],
          ],

          if (_isUploading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text('UPLOADING...',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: 1.2)),
            ),
        ],
      ),
    );
  }

  // ─── Comparative Analytics ────────────────────────────────────────────────
  Widget _buildComparativeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: _kShadow, blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: _kBg, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.bar_chart_rounded, size: 22, color: _kGreen),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COMPARATIVE\nANALYTICS',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
                            color: _kInk, letterSpacing: .3, height: 1.3)),
                    SizedBox(height: 4),
                    Text('Trend mapping between two labs',
                        style: TextStyle(fontSize: 12, color: _kMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(children: [
              Icon(Icons.monitor_heart_outlined, size: 40, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('Select report(s) from history\nto visualize analytics',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade400, height: 1.5)),
            ]),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─── Recent Archives ─────────────────────────────────────────────────────
  Widget _buildArchivesCard() {
    final int count = uploadedReportsList.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: _kShadow, blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + badge
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: _kBg, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.history_rounded, size: 22, color: _kGreen),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('RECENT ARCHIVES',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
                        color: _kInk, letterSpacing: .5)),
              ),
              // Count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: count > 0 ? _kGreenLight : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count report${count == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .3,
                    color: count > 0 ? _kGreen : Colors.grey,
                  ),
                ),
              ),
            ],
          ),

          // Empty state
          if (count == 0) ...[
            const SizedBox(height: 28),
            Center(
              child: Text('No records found',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400,
                      fontStyle: FontStyle.italic)),
            ),
            const SizedBox(height: 12),
          ],

          // Report tiles
          if (count > 0) ...[
            const SizedBox(height: 16),
            for (int i = 0; i < count; i++) _buildTile(i),
          ],
        ],
      ),
    );
  }

  // ─── Report tile  (overflow-safe layout) ─────────────────────────────────
  Widget _buildTile(int index) {
    final UploadedReport report = uploadedReportsList[index];
    final String date = _fmtDate(report.uploadedAt);
    final String time = _fmtTime(report.uploadedAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _kBg, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0EAE7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: thumbnail + name/date ──────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 46, height: 46,
                    color: Colors.white,
                    child: _isImage(report.name)
                        ? Image.file(report.file, fit: BoxFit.cover)
                        : const Icon(Icons.picture_as_pdf_rounded,
                        color: Color(0xFFE53935), size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + date — Expanded prevents right overflow
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.name,
                          style: const TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w700, color: _kInk),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 5),
                      Row(children: [
                        const Icon(Icons.access_time_rounded,
                            size: 11, color: _kMuted),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text('$date  $time',
                              style: const TextStyle(fontSize: 11, color: _kMuted),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Row 2: Analyze + Delete — guaranteed no overflow ──────────
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ClinicalSynthesisScreen()),
                    ).then((_) {
                      if (mounted) setState(() => _lastUploaded = null);
                    }),
                    child: Container(
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _kGreen,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text('Analyze',
                          style: TextStyle(fontSize: 12,
                              fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _confirmDelete(index),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        size: 18, color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────
  bool _isImage(String name) {
    final String ext = name.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp', 'heic'].contains(ext);
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/'
          '${d.year}';

  String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:'
          '${d.minute.toString().padLeft(2, '0')}';
}