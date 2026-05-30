import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'clinical_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  static const Color _cardGreen = Color(0xFF4A7C6F);
  final ImagePicker _imagePicker = ImagePicker();

  // Store uploaded files
  File? _selectedFile;
  String? _selectedFileName;
  bool _isUploading = false;
  bool _uploadSuccess = false;

  // Show options dialog
  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: _cardGreen),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: _cardGreen),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
          _selectedFileName = pickedFile.name;
          _uploadSuccess = false;
        });
        await _uploadFile();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  // Pick image from camera
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
          _selectedFileName = pickedFile.name;
          _uploadSuccess = false;
        });
        await _uploadFile();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take photo: $e');
    }
  }

  // Upload file
  Future<void> _uploadFile() async {
    setState(() {
      _isUploading = true;
    });

    try {
      // Simulate upload delay - Replace with actual API call
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Replace with your actual API call
      // Example:
      // final response = await yourApiService.uploadReport(_selectedFile!);
      // if (response.success) {
      //   setState(() { _uploadSuccess = true; });
      //   _showSuccessSnackBar('$_selectedFileName uploaded successfully!');
      // }

      // Simulate success
      setState(() {
        _uploadSuccess = true;
      });

      if (mounted) {
        _showSuccessSnackBar('$_selectedFileName uploaded successfully!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Upload failed: $e');
        setState(() {
          _selectedFile = null;
          _selectedFileName = null;
          _uploadSuccess = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // Clear selected file
  void _clearSelectedFile() {
    setState(() {
      _selectedFile = null;
      _selectedFileName = null;
      _uploadSuccess = false;
    });
  }

  // Show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            // Smart Lab Insights header
            _buildHeader(),
            const SizedBox(height: 20),

            // Upload Lab Report card
            _buildUploadCard(),
            const SizedBox(height: 16),

            // Comparative Analytics card
            _buildComparativeCard(),
            const SizedBox(height: 16),

            // Recent Archives card
            _buildRecentArchivesCard(),
          ],
        ),

        // Loading overlay
        if (_isUploading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_cardGreen),
              ),
            ),
          ),

        // FAB
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'chat_reports',
            mini: true,
            backgroundColor: _cardGreen,
            foregroundColor: Colors.white,
            elevation: 4,
            onPressed: () {
              // TODO: Implement chat functionality
            },
            child: const Icon(Icons.chat_bubble_outline, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildUploadCard() {
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
            child: Icon(
              _uploadSuccess ? Icons.check_circle : Icons.upload_file,
              size: 30,
              color: _uploadSuccess ? Colors.green : _cardGreen,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _selectedFile != null ? 'LAB REPORT READY' : 'UPLOAD LAB REPORT',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFile != null
                ? _uploadSuccess
                    ? 'Ready for analysis'
                    : 'Uploading in progress...'
                : 'Tap to select image from gallery or camera',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),

          // Show selected file info
          if (_selectedFile != null && !_isUploading) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _uploadSuccess
                    ? Colors.green.withOpacity(0.1)
                    : _cardGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _uploadSuccess ? Colors.green : _cardGreen,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _uploadSuccess ? Icons.check_circle : Icons.image,
                    color: _uploadSuccess ? Colors.green : _cardGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedFileName ?? 'File selected',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_uploadSuccess)
                          const Text(
                            'Upload completed successfully',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!_uploadSuccess)
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: _clearSelectedFile,
                      tooltip: 'Remove file',
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Dynamic button based on upload status
          if (!_isUploading)
            GestureDetector(
// In _buildUploadCard method, update the onTap for ANALYZE REPORT button
              onTap: _uploadSuccess
                  ? () {
                      // Navigate to analysis report screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ClinicalSynthesisScreen(),
                        ),
                      );
                    }
                  : _showImageSourceDialog,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 15),
                decoration: BoxDecoration(
                  color: _uploadSuccess ? Colors.green : _cardGreen,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  _uploadSuccess ? 'ANALYZE REPORT' : 'SELECT FILE',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

          // Uploading state
          if (_isUploading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'UPLOADING...',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),

          // Upload another button after success
          if (_uploadSuccess) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                _clearSelectedFile();
                _showImageSourceDialog();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: _cardGreen, width: 1.5),
                ),
                child: const Text(
                  'UPLOAD ANOTHER',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _cardGreen,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

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
          Center(
            child: Text(
              _selectedFile != null && _uploadSuccess
                  ? '1 report uploaded'
                  : 'No records found',
              textAlign: TextAlign.center,
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

// Get formatted date
  String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }
}
