import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/api_service.dart';
import '../../../home/domain/entities/user_profile_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _accountExpanded = false;
  bool _goalExpanded = false;
  bool _isLoading = true;
  bool _isUploadingPhoto = false;

  // Account Details controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String _gender = 'Male';
  String _bloodGroup = 'AB+';
  String _isDiabetic = 'No';
  final _medicalCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();

  // Goal Settings controllers
  String _healthObjective = 'Weight loss';
  final _targetWeightCtrl = TextEditingController();
  String _targetTimeframe = '12 Weeks (Sustainable)';

  // Calculated values
  double _bmi = 0;
  int _healthScore = 0;
  int _dailyCalories = 0;
  Map<String, String> _macros = {'PRO': '0g', 'CARB': '0g', 'FAT': '0g'};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _medicalCtrl.dispose();
    _allergiesCtrl.dispose();
    _targetWeightCtrl.dispose();
    super.dispose();
  }

  // ── Load Data ──────────────────────────────────────────────────────────────
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();

    _nameCtrl.text = prefs.getString('user_name') ?? 'mayur';
    _emailCtrl.text = prefs.getString('user_email') ?? 'mayurranshinge08@gmail.com';
    _phoneCtrl.text = prefs.getString('user_phone') ?? '9167110082';
    _ageCtrl.text = prefs.getString('user_age') ?? '26';
    _heightCtrl.text = prefs.getString('user_height') ?? '152';
    _weightCtrl.text = prefs.getString('user_weight') ?? '51';
    _gender = prefs.getString('user_gender') ?? 'Male';
    _bloodGroup = prefs.getString('user_blood_group') ?? 'AB+';
    _isDiabetic = prefs.getString('user_is_diabetic') ?? 'No';
    _medicalCtrl.text = prefs.getString('user_medical_conditions') ?? '';
    _allergiesCtrl.text = prefs.getString('user_allergies') ?? '';
    _healthObjective = prefs.getString('user_health_objective') ?? 'Weight loss';
    _targetWeightCtrl.text = prefs.getString('user_target_weight') ?? '64';
    _targetTimeframe = prefs.getString('user_target_timeframe') ?? '12 Weeks (Sustainable)';

    // Also sync provider with latest prefs
    await UserProfileProvider.instance.loadFromPrefs();

    _calculateMetrics();
    setState(() => _isLoading = false);
  }

  // ── Save Data ──────────────────────────────────────────────────────────────
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_name', _nameCtrl.text.trim());
    await prefs.setString('user_email', _emailCtrl.text.trim());
    await prefs.setString('user_phone', _phoneCtrl.text.trim());
    await prefs.setString('user_age', _ageCtrl.text.trim());
    await prefs.setString('user_height', _heightCtrl.text.trim());
    await prefs.setString('user_weight', _weightCtrl.text.trim());
    await prefs.setString('user_gender', _gender);
    await prefs.setString('user_blood_group', _bloodGroup);
    await prefs.setString('user_is_diabetic', _isDiabetic);
    await prefs.setString('user_medical_conditions', _medicalCtrl.text.trim());
    await prefs.setString('user_allergies', _allergiesCtrl.text.trim());
    await prefs.setString('user_health_objective', _healthObjective);
    await prefs.setString('user_target_weight', _targetWeightCtrl.text.trim());
    await prefs.setString('user_target_timeframe', _targetTimeframe);

    // Update provider so CommonAppBar reflects new name instantly
    await UserProfileProvider.instance.updateName(_nameCtrl.text.trim());

    _calculateMetrics();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: Color(0xFF4A9B6E),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // ── Metrics ────────────────────────────────────────────────────────────────
  void _calculateMetrics() {
    final double height = double.tryParse(_heightCtrl.text) ?? 0;
    final double weight = double.tryParse(_weightCtrl.text) ?? 0;

    if (height > 0 && weight > 0) {
      _bmi = weight / ((height / 100) * (height / 100));
      _bmi = double.parse(_bmi.toStringAsFixed(1));

      if (_bmi >= 18.5 && _bmi <= 24.9) {
        _healthScore = 92;
      } else if (_bmi >= 25 && _bmi <= 29.9) {
        _healthScore = 75;
      } else if (_bmi >= 30) {
        _healthScore = 60;
      } else if (_bmi < 18.5) {
        _healthScore = 70;
      } else {
        _healthScore = 85;
      }

      if (_isDiabetic == 'Yes') _healthScore -= 10;
      if (_isDiabetic == 'Pre-diabetic') _healthScore -= 5;
      _healthScore = _healthScore.clamp(0, 100);

      _calculateDailyCalories();
    } else {
      _bmi = 0;
      _healthScore = 0;
    }

    setState(() {});
  }

  void _calculateDailyCalories() {
    final double weight = double.tryParse(_weightCtrl.text) ?? 0;
    final double height = double.tryParse(_heightCtrl.text) ?? 0;
    final int age = int.tryParse(_ageCtrl.text) ?? 26;

    double bmr;
    if (_gender == 'Male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    if (_healthObjective == 'Weight loss') {
      _dailyCalories = (bmr * 1.2).toInt() - 300;
    } else if (_healthObjective == 'Muscle gain') {
      _dailyCalories = (bmr * 1.375).toInt() + 300;
    } else {
      _dailyCalories = (bmr * 1.2).toInt();
    }

    _dailyCalories = _dailyCalories.clamp(1200, 3500);

    double proteinGrams, carbsGrams, fatGrams;

    if (_healthObjective == 'Weight loss') {
      proteinGrams = (weight * 2.0).roundToDouble();
      fatGrams = (weight * 0.8).roundToDouble();
      carbsGrams = ((_dailyCalories - (proteinGrams * 4) - (fatGrams * 9)) / 4).roundToDouble();
    } else if (_healthObjective == 'Muscle gain') {
      proteinGrams = (weight * 2.2).roundToDouble();
      fatGrams = (weight * 0.9).roundToDouble();
      carbsGrams = ((_dailyCalories - (proteinGrams * 4) - (fatGrams * 9)) / 4).roundToDouble();
    } else {
      proteinGrams = (weight * 1.6).roundToDouble();
      fatGrams = (weight * 0.7).roundToDouble();
      carbsGrams = ((_dailyCalories - (proteinGrams * 4) - (fatGrams * 9)) / 4).roundToDouble();
    }

    _macros = {
      'PRO': '${proteinGrams.round()}g',
      'CARB': '${carbsGrams.round()}g',
      'FAT': '${fatGrams.round()}g',
    };

    setState(() {});
  }

  String _getBMICategory() {
    if (_bmi < 18.5) return 'UNDERWEIGHT';
    if (_bmi >= 18.5 && _bmi < 25) return 'NORMAL';
    if (_bmi >= 25 && _bmi < 30) return 'OVERWEIGHT';
    return 'OBESE';
  }

  Color _getBMIColor() {
    if (_bmi < 18.5) return const Color(0xFFF59E0B);
    if (_bmi >= 18.5 && _bmi < 25) return const Color(0xFF15803D);
    if (_bmi >= 25 && _bmi < 30) return const Color(0xFFF97316);
    return const Color(0xFFE53935);
  }

  // ── Avatar Builder ─────────────────────────────────────────────────────────
  Widget _buildAvatar() {
    final profile = UserProfileProvider.instance;
    if (profile.localImagePath != null) {
      return Image.file(File(profile.localImagePath!), width: 80, height: 80, fit: BoxFit.cover);
    }
    if (profile.profilePictureUrl != null && profile.profilePictureUrl!.isNotEmpty) {
      return Image.network(
        profile.profilePictureUrl!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultAvatarWidget(),
      );
    }
    return _defaultAvatarWidget();
  }

  Widget _defaultAvatarWidget() {
    return Image.network('https://i.pravatar.cc/300', width: 80, height: 80, fit: BoxFit.cover);
  }

  // ── Bottom Sheet ───────────────────────────────────────────────────────────
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Update Profile Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            ListTile(
              onTap: () {
                Navigator.of(ctx).pop();
                _pickAndUploadImage(ImageSource.gallery);
              },
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: const Color(0xFFE8F5EE), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.photo_library_outlined, color: Color(0xFF4A9B6E), size: 20),
              ),
              title: const Text('Upload Photo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
              subtitle: const Text('Choose from your gallery', style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFBBBBBB)),
            ),
            const Divider(height: 1, indent: 70, color: Color(0xFFF0F0F0)),
            ListTile(
              onTap: () {
                Navigator.of(ctx).pop();
                _pickAndUploadImage(ImageSource.camera);
              },
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF3B82F6), size: 20),
              ),
              title: const Text('Open Camera', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
              subtitle: const Text('Take a new photo', style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFBBBBBB)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF5F5F5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF888888))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Pick & Upload ──────────────────────────────────────────────────────────
  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (picked == null) return;

      setState(() => _isUploadingPhoto = true);

      // Update provider immediately for instant preview everywhere
      await UserProfileProvider.instance.updateProfilePicture(localPath: picked.path);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      final ext = picked.path.split('.').last.toLowerCase();
      final mimeType = ext == 'png' ? 'png' : 'jpeg';

      final uri = Uri.parse('https://ai-healthcare-ip89.onrender.com/api/auth/upload-profile-picture');

      final request = http.MultipartRequest('POST', uri)
        ..headers['accept'] = 'application/json'
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(
          await http.MultipartFile.fromPath(
            'profilePicture',
            picked.path,
            contentType: MediaType('image', mimeType),
          ),
        );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      debugPrint('Upload status: ${response.statusCode}');
      debugPrint('Upload body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        String? networkUrl;
        try {
          final body = jsonDecode(response.body);
          networkUrl = body['url'] ??
              body['profilePictureUrl'] ??
              body['data']?['url'] ??
              body['profile_picture'];
        } catch (_) {}

        // Update provider with network URL if returned
        await UserProfileProvider.instance.updateProfilePicture(
          localPath: picked.path,
          networkUrl: networkUrl,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated successfully!'),
              backgroundColor: Color(0xFF4A9B6E),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Revert provider on failure
        UserProfileProvider.instance.clearLocalImage();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed (${response.statusCode}): ${response.body}'),
              backgroundColor: const Color(0xFFE53935),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      UserProfileProvider.instance.clearLocalImage();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFE53935),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F5F0),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF4A9B6E))),
      );
    }

    // Watch provider so avatar in this page also updates reactively
    final profile = context.watch<UserProfileProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F5F0),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1A1A1A)),
          ),
        ),
        centerTitle: true,
        title: const Text('My Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: const Icon(Icons.notifications_none_rounded, size: 20, color: Color(0xFF1A1A1A)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ── Profile Header ──────────────────────────────────────────────
            Row(
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: _isUploadingPhoto ? null : _showImagePickerOptions,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF4A9B6E), width: 2.5),
                        ),
                        child: ClipOval(child: _buildAvatar()),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _isUploadingPhoto ? null : _showImagePickerOptions,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: _isUploadingPhoto ? const Color(0xFF888888) : const Color(0xFF4A9B6E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: _isUploadingPhoto
                              ? const Padding(
                            padding: EdgeInsets.all(5),
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                              : const Icon(Icons.camera_alt_rounded, size: 13, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _InfoChip(label: '${_ageCtrl.text} yrs'),
                          const SizedBox(width: 6),
                          _InfoChip(label: _gender),
                          const SizedBox(width: 6),
                          _InfoChip(label: '${_heightCtrl.text}cm'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 13, color: Color(0xFF888888)),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              _emailCtrl.text,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF888888), fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Health Score & BMI ──────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.favorite_border_rounded,
                    iconColor: const Color(0xFF4A9B6E),
                    iconBg: const Color(0xFFE8F5EE),
                    label: 'Health Score',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: '$_healthScore', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
                              const TextSpan(text: ' / 100', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF888888))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text('Top 5% for your age', style: TextStyle(fontSize: 11, color: Color(0xFF4A9B6E), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.show_chart_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    iconBg: const Color(0xFFEFF6FF),
                    label: 'Current BMI',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_bmi.toString(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getBMIColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getBMICategory(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _getBMIColor(), letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Menu Items ──────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 3))],
              ),
              child: Column(
                children: [
                  _ExpandableMenuItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Account Details',
                    isExpanded: _accountExpanded,
                    isFirst: true,
                    onTap: () => setState(() => _accountExpanded = !_accountExpanded),
                    expandedContent: _buildAccountForm(),
                  ),
                  const _Divider(),
                  _ExpandableMenuItem(
                    icon: Icons.my_location_outlined,
                    label: 'Goal Settings',
                    isExpanded: _goalExpanded,
                    onTap: () => setState(() => _goalExpanded = !_goalExpanded),
                    expandedContent: _buildGoalForm(),
                  ),
                  const _Divider(),
                  _MenuItem(icon: Icons.description_outlined, label: 'Medical Records', onTap: () {}),
                  const _Divider(),
                  _MenuItem(icon: Icons.trending_up_rounded, label: 'Progress Reports', onTap: () {}),
                  const _Divider(),
                  _MenuItem(icon: Icons.receipt_long_outlined, label: 'Terms & Conditions', onTap: () {}),
                  const _Divider(),
                  _MenuItem(icon: Icons.shield_outlined, label: 'Privacy Policy', onTap: () {}, isLast: true),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  InkWell(
                    onTap: () => _confirmLogout(context),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(22),
                      bottomRight: Radius.circular(22),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, size: 18, color: Color(0xFFE53935)),
                          SizedBox(width: 8),
                          Text('Logout Account', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFE53935))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Account Form ───────────────────────────────────────────────────────────
  Widget _buildAccountForm() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormLabel('FULL NAME'),
          _FormField(controller: _nameCtrl, hint: 'Full name'),
          const SizedBox(height: 14),
          _FormLabel('EMAIL'),
          _FormField(controller: _emailCtrl, hint: 'Email', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _FormLabel('PHONE'),
                  _FormField(controller: _phoneCtrl, hint: 'Phone', keyboardType: TextInputType.phone),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _FormLabel('AGE'),
                  _FormField(controller: _ageCtrl, hint: 'Age', keyboardType: TextInputType.number, onChanged: () => _calculateMetrics()),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _FormLabel('GENDER'),
                  _DropdownField(
                    value: _gender,
                    items: const ['Male', 'Female', 'Other'],
                    onChanged: (v) { setState(() => _gender = v!); _calculateMetrics(); },
                  ),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _FormLabel('BLOOD GROUP'),
                  _DropdownField(
                    value: _bloodGroup,
                    items: const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
                    onChanged: (v) => setState(() => _bloodGroup = v!),
                  ),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _FormLabel('HEIGHT (CM)'),
                  _FormField(controller: _heightCtrl, hint: 'Height', keyboardType: TextInputType.number, onChanged: () => _calculateMetrics()),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _FormLabel('WEIGHT (KG)'),
                  _FormField(controller: _weightCtrl, hint: 'Weight', keyboardType: TextInputType.number, onChanged: () => _calculateMetrics()),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('COMPREHENSIVE HEALTH HISTORY',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF4A9B6E), letterSpacing: 0.5)),
          const SizedBox(height: 12),
          _FormLabel('ARE YOU DIABETIC?'),
          _DropdownField(
            value: _isDiabetic,
            items: const ['No', 'Yes', 'Pre-diabetic'],
            onChanged: (v) { setState(() => _isDiabetic = v!); _calculateMetrics(); },
          ),
          const SizedBox(height: 14),
          _FormLabel('MEDICAL CONDITIONS'),
          _FormField(controller: _medicalCtrl, hint: '', maxLines: 3),
          const SizedBox(height: 14),
          _FormLabel('ALLERGIES'),
          _FormField(controller: _allergiesCtrl, hint: '', maxLines: 3),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A2332),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('SAVE CHANGES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Goal Form ──────────────────────────────────────────────────────────────
  Widget _buildGoalForm() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormLabel('HEALTH OBJECTIVE'),
          _DropdownField(
            value: _healthObjective,
            items: const ['Weight loss', 'Muscle gain', 'Maintenance', 'Endurance'],
            onChanged: (v) { setState(() => _healthObjective = v!); _calculateMetrics(); },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFF0F8F4), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CURRENT WEIGHT',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF4A9B6E), letterSpacing: 0.4)),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          text: _weightCtrl.text,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
                          children: const [TextSpan(text: ' kg', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF888888)))],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _FormLabel('TARGET WEIGHT'),
                  _FormField(controller: _targetWeightCtrl, hint: '0', keyboardType: TextInputType.number, onChanged: () => _calculateMetrics()),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _FormLabel('TARGET TIMEFRAME'),
          _DropdownField(
            value: _targetTimeframe,
            items: const ['4 Weeks (Aggressive)', '8 Weeks (Moderate)', '12 Weeks (Sustainable)', '16 Weeks (Gradual)'],
            onChanged: (v) => setState(() => _targetTimeframe = v!),
          ),
          const SizedBox(height: 6),
          const Text('Tip: 12 weeks is recommended for sustainable fat loss or muscle gain.',
              style: TextStyle(fontSize: 11, color: Color(0xFF888888), fontStyle: FontStyle.italic)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFF1A2332), borderRadius: BorderRadius.circular(18)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('DAILY CALORIE BUDGET',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF8A9BB0), letterSpacing: 0.5)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$_dailyCalories', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                        const SizedBox(width: 4),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text('KCAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8A9BB0), letterSpacing: 0.5)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _MacroBudgetCard(color: const Color(0xFF4A9B6E), label: 'PRO', value: _macros['PRO'] ?? '0g'),
                    const SizedBox(width: 10),
                    _MacroBudgetCard(color: const Color(0xFFF5A623), label: 'CARB', value: _macros['CARB'] ?? '0g'),
                    const SizedBox(width: 10),
                    _MacroBudgetCard(color: const Color(0xFFE53935), label: 'FAT', value: _macros['FAT'] ?? '0g'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _saveUserData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitness plan synced successfully!'), backgroundColor: Color(0xFF4A9B6E)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A9B6E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('SYNC FITNESS PLAN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ApiService.logout();
              } catch (_) {}
              if (context.mounted) context.go(AppRoutes.login);
            },
            child: const Text('Logout', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Form helpers ────────────────────────────────────────────────────────────────

Widget _FormLabel(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF888888), letterSpacing: 0.5)),
);

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final int maxLines;
  final VoidCallback? onChanged;

  const _FormField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: (_) => onChanged?.call(),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
        filled: true,
        fillColor: const Color(0xFFF8F9F8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4A9B6E), width: 1.5)),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF888888)),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          onChanged: onChanged,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        ),
      ),
    );
  }
}

class _MacroBudgetCard extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _MacroBudgetCard({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF232E40), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 4, height: 18, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF8A9BB0), letterSpacing: 0.3)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _ExpandableMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isExpanded;
  final bool isFirst;
  final VoidCallback onTap;
  final Widget expandedContent;

  const _ExpandableMenuItem({
    required this.icon,
    required this.label,
    required this.isExpanded,
    required this.onTap,
    required this.expandedContent,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: isFirst
              ? const BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22))
              : BorderRadius.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, size: 20, color: const Color(0xFF3A3A3A)),
                ),
                const SizedBox(width: 14),
                Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)))),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: const Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: Color(0xFFBBBBBB)),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: expandedContent,
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xFFE8F5EE), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2E7D50))),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final Widget child;

  const _StatCard({required this.icon, required this.iconColor, required this.iconBg, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF888888)))),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _MenuItem({required this.icon, required this.label, required this.onTap, this.isFirst = false, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.only(
        topLeft: isFirst ? const Radius.circular(22) : Radius.zero,
        topRight: isFirst ? const Radius.circular(22) : Radius.zero,
        bottomLeft: isLast ? const Radius.circular(22) : Radius.zero,
        bottomRight: isLast ? const Radius.circular(22) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 20, color: const Color(0xFF3A3A3A)),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)))),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFBBBBBB)),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFF0F0F0));
  }
}