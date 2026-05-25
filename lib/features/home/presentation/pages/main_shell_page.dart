import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:classroom_app/features/home/presentation/pages/home_page.dart';
import 'package:classroom_app/features/nutrition/presentation/pages/nutrition_page.dart';
import 'package:classroom_app/features/reports/presentation/pages/reports_page.dart';
import 'package:classroom_app/core/widgets/common_app_bar.dart';
import 'package:classroom_app/features/profile/presentation/pages/profile_page.dart';
import '../../../diet_plan/presentation/pages/diet_plan_page.dart';

class MainShellPage extends StatefulWidget {
  final int initialTab;
  const MainShellPage({super.key, this.initialTab = 0});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openProfile() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const ProfilePage(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  void _openQuickLog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickLogSheet(
        onAddMealTap: () {
          Navigator.of(context).pop(); // close quick log
          _openAddMealSheet();
        },
      ),
    );
  }

  void _openAddMealSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddToMealSheet(selectedMode: 0,),
    );
  }

  List<String> get _pageTitles => [
    'Home',
    'Nutrition',
    'Reports',
    'Diet Plan',
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(
        onViewFullPlan: () => _onTabSelected(3),
        onUploadReport: () => _onTabSelected(2),
        onNutrition: () => _onTabSelected(1),
      ),
      const NutritionPage(),
      const ReportsPage(),
      const DietPlanPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: CommonAppBar(onProfileTap: _openProfile),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      floatingActionButton: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xff4A9B6E), Color(0xff2E7D50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff4A9B6E).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _openQuickLog,
          elevation: 0,
          backgroundColor: Colors.transparent,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(width: 5),
              _buildNavItem(icon: Icons.grid_view_rounded, label: 'Home', index: 0),
              _buildNavItem(icon: Icons.monitor_heart_outlined, label: 'Nutrition', index: 1),
              const SizedBox(width: 25),
              _buildNavItem(icon: Icons.assignment_outlined, label: 'Reports', index: 2),
              _buildNavItem(icon: Icons.apple_outlined, label: 'Diet Plan', index: 3),
              const SizedBox(width: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xff4A9B6E) : Colors.grey.shade400;

    return InkWell(
      onTap: () => _onTabSelected(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK LOG BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class QuickLogSheet extends StatelessWidget {
  final VoidCallback onAddMealTap;

  const QuickLogSheet({super.key, required this.onAddMealTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5EE),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quick Log',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A9B6E).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PRIMARY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4A9B6E),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Add Meal + Medical Records
          Row(
            children: [
              Expanded(
                child: _QuickLogCard(
                  icon: Icons.restaurant_menu_rounded,
                  iconColor: const Color(0xFF4A9B6E),
                  iconBg: const Color(0xFFD6EDE2),
                  title: 'Add Meal',
                  subtitle: 'Daily intake',
                  onTap: onAddMealTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickLogCard(
                  icon: Icons.verified_user_outlined,
                  iconColor: const Color(0xFF7B6FCD),
                  iconBg: const Color(0xFFE8E6F7),
                  title: 'Medical Records',
                  subtitle: 'Vault records',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Insights
          _BannerTile(
            icon: Icons.trending_up_rounded,
            iconColor: const Color(0xFF4A9B6E),
            iconBg: Colors.white,
            title: 'Progress Insights',
            subtitle: 'Review vitality metrics',
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 20),

          // Section label
          const Text(
            'TRACK YOUR DAILY ACTIVITIES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF888888),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),

          // Activity grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.6,
            children: [
              _ActivityTile(
                icon: Icons.balance_outlined,
                iconColor: const Color(0xFF4A9B6E),
                iconBg: const Color(0xFFD6EDE2),
                label: 'Weight',
                onTap: () => Navigator.of(context).pop(),
              ),
              _ActivityTile(
                icon: Icons.local_drink_outlined,
                iconColor: const Color(0xFF5B9BD5),
                iconBg: const Color(0xFFD9EBF9),
                label: 'Water',
                onTap: () => Navigator.of(context).pop(),
              ),
              _ActivityTile(
                icon: Icons.bedtime_outlined,
                iconColor: const Color(0xFF7B6FCD),
                iconBg: const Color(0xFFE8E6F7),
                label: 'Sleep',
                onTap: () => Navigator.of(context).pop(),
              ),
              _ActivityTile(
                icon: Icons.directions_walk_rounded,
                iconColor: const Color(0xFFE8873A),
                iconBg: const Color(0xFFFAEAD9),
                label: 'Steps',
                onTap: () => Navigator.of(context).pop(),
              ),
              _ActivityTile(
                icon: Icons.air_rounded,
                iconColor: const Color(0xFFE8736E),
                iconBg: const Color(0xFFFADDDC),
                label: 'Smoke',
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADD TO MEAL (BREAKFAST) BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class AddToMealSheet extends StatefulWidget {
  final int selectedMode;
  const AddToMealSheet({super.key,  required this.selectedMode});

  @override
  State<AddToMealSheet> createState() => _AddToMealSheetState();
}

class _AddToMealSheetState extends State<AddToMealSheet> {
  // Meal type selection
  int _selectedMeal = 0; // 0=Breakfast, 1=Lunch, 2=Dinner
  final List<String> _mealTypes = ['BREAKFAST', 'LUNCH', 'DINNER'];
  final List<IconData> _mealIcons = [
    Icons.wb_sunny_outlined,
    Icons.wb_cloudy_outlined,
    Icons.nightlight_outlined,
  ];

  // Input mode selection
  int _selectedMode = 0; // 0=Scan, 1=Type, 2=Voice Log
  @override
  void initState() {
    super.initState();
    _selectedMode = widget.selectedMode; // Set the initial mode from widget
  }
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── PINNED HEADER (never scrolls) ──────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title + close
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ADD TO ${_mealTypes[_selectedMeal]}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A),
                              letterSpacing: 0.3,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  size: 18, color: Color(0xFF555555)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Meal type chips
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: List.generate(_mealTypes.length, (i) {
                          final selected = _selectedMeal == i;
                          return Padding(
                            padding: EdgeInsets.only(
                                right: i < _mealTypes.length - 1 ? 10 : 0),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedMeal = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 9),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFF4A9B6E)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: selected
                                        ? const Color(0xFF4A9B6E)
                                        : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_mealIcons[i],
                                        size: 15,
                                        color: selected
                                            ? Colors.white
                                            : Colors.grey.shade500),
                                    const SizedBox(width: 6),
                                    Text(
                                      _mealTypes[i],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: selected
                                            ? Colors.white
                                            : Colors.grey.shade500,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mode tabs
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            _ModeTab(
                              icon: Icons.crop_free_rounded,
                              label: 'SCAN',
                              selected: _selectedMode == 0,
                              onTap: () =>
                                  setState(() => _selectedMode = 0),
                            ),
                            _ModeTab(
                              icon: Icons.description_outlined,
                              label: 'TYPE',
                              selected: _selectedMode == 1,
                              onTap: () =>
                                  setState(() => _selectedMode = 1),
                            ),
                            _ModeTab(
                              icon: Icons.mic_outlined,
                              label: 'VOICE LOG',
                              selected: _selectedMode == 2,
                              onTap: () =>
                                  setState(() => _selectedMode = 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),

              // ── SCROLLABLE CONTENT ─────────────────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 32),
                  children: [
                    // Mode content
                    if (_selectedMode == 0)
                      _ScanContent()
                    else if (_selectedMode == 1)
                      const _TypeContent()
                    else
                      _VoiceContent(),

                    const SizedBox(height: 20),

                    // Helper text — scan only
                    if (_selectedMode == 0) ...[
                      Text(
                        'Our engine will optimize the portion size and\nnutritional content directly from the photo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Analyze button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB2D8C4),
                          foregroundColor: const Color(0xFF2E7D50),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.search_rounded, size: 20),
                        label: Text(
                          _selectedMode == 0
                              ? 'ANALYZE PHOTO'
                              : _selectedMode == 1
                              ? 'ANALYZE & LOG MEAL'
                              : 'ANALYZE VOICE LOG',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Scan content ──────────────────────────────────────────────────────────────

class _ScanContent extends StatefulWidget {
  const _ScanContent();

  @override
  State<_ScanContent> createState() => _ScanContentState();
}

class _ScanContentState extends State<_ScanContent> {
  File? _pickedImage;
  bool _isLoading = false;

  /// Opens camera or gallery, then updates state with the chosen image.
  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isLoading = true);
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (file != null) {
        setState(() => _pickedImage = File(file.path));
      }
    } catch (e) {
      // Permission denied or no camera available
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? 'Camera permission denied or not available.'
                  : 'Gallery permission denied.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF2E7D50),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _removeImage() => setState(() => _pickedImage = null);

  @override
  Widget build(BuildContext context) {
    // ── IMAGE PREVIEW STATE ───────────────────────────────────────────────────
    if (_pickedImage != null) {
      return Column(
        children: [
          // Preview card
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Image
                Image.file(
                  _pickedImage!,
                  width: double.infinity,
                  height: 260,
                  fit: BoxFit.cover,
                ),
                // Dark gradient overlay at bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 90,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xCC000000), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                // Remove button (top-right)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: _removeImage,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
                // "Tap to re-upload" label at bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 14,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => _showSourcePicker(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.35)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh_rounded,
                                color: Colors.white, size: 15),
                            SizedBox(width: 6),
                            Text(
                              'TAP TO RE-UPLOAD',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Filename chip
          Row(
            children: [
              const Icon(Icons.image_outlined,
                  size: 14, color: Color(0xFF4A9B6E)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _pickedImage!.path.split('/').last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showSourcePicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6EDE2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'CHANGE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E7D50),
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // ── EMPTY / PICKER STATE ──────────────────────────────────────────────────
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: const Color(0xFF4A7D62),
        borderRadius: BorderRadius.circular(20),
      ),
      child: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.5,
        ),
      )
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.crop_free_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 20),
          _SheetButton(
            label: 'TAP TO SCAN MEAL',
            onTap: () => _pickImage(ImageSource.camera),
          ),
          const SizedBox(height: 10),
          Text(
            'OR',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          _SheetButton(
            icon: Icons.photo_outlined,
            label: 'UPLOAD PHOTO',
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  /// Bottom sheet to choose between camera and gallery (for re-upload).
  void _showSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose Source',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6EDE2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_outlined,
                      color: Color(0xFF4A9B6E), size: 20),
                ),
                title: const Text('Camera',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text('Take a new photo',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9EBF9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_outlined,
                      color: Color(0xFF5B9BD5), size: 20),
                ),
                title: const Text('Gallery',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text('Pick from your photos',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Type content ──────────────────────────────────────────────────────────────

class _TypeContent extends StatefulWidget {
  const _TypeContent();

  @override
  State<_TypeContent> createState() => _TypeContentState();
}

class _TypeContentState extends State<_TypeContent> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _searchFocused = false;
  String? _selectedMethod;
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;



  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  final List<String> _quickTags = [
    'APPLE',
    'RICE & DAL',
    'PANEER SABZI',
    'OATS',
    'COFFEE',
  ];

  final List<String> _preparationMethods = [
    'Boiled',
    'Fried',
    'Steamed',
    'Grilled',
    'Raw',
    'Baked',
    'Roasted',
  ];


  void _selectMethod(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Preparation Method',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            ..._preparationMethods.map(
                  (m) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(m,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF1A1A1A))),
                trailing: _selectedMethod == m
                    ? const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF4A9B6E))
                    : null,
                onTap: () => Navigator.of(context).pop(m),
              ),
            ),
          ],
        ),
      ),
    );
    if (result != null) setState(() => _selectedMethod = result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        // Search Field - NEW CODE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search for food or describe...',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),

              // Search icon on the left
              prefixIcon: Icon(
                Icons.search_rounded,
                color: _isSearchFocused ? const Color(0xFF4A9B6E) : Colors.grey.shade400,
                size: 22,
              ),

              // Voice icon on the right
              suffixIcon: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Voice search coming soon!'),
                      duration: Duration(milliseconds: 800),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(6),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _isSearchFocused
                        ? const Color(0xFF4A9B6E).withOpacity(0.1)
                        : const Color(0xFFD6EDE2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.mic_outlined,
                    color: Color(0xFF4A9B6E),
                    size: 20,
                  ),
                ),
              ),

              // Background color
              filled: true,
              //fillColor: _isSearchFocused ? Colors.white : Colors.grey.shade100,

              // Border styling
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF4A9B6E), width: 1.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),

              // Content padding
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              isDense: true,
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A1A1A),
            ),
            textInputAction: TextInputAction.search,
            onChanged: (value) {
              print('Searching: $value');
            },
            onSubmitted: (value) {
              print('Search submitted: $value');
            },
          ),
        ),
        const SizedBox(height: 20),

        // Quantity + Preparation row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quantity
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'QUANTITY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4A9B6E),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        hintText: 'e.g., 2 bowls',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                      ),
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF1A1A1A)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Preparation
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PREPARATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4A9B6E),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectMethod(context),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedMethod ?? 'Select Method',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _selectedMethod != null
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: _selectedMethod != null
                                  ? const Color(0xFF1A1A1A)
                                  : Colors.grey.shade500,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded,
                              color: Colors.grey.shade400, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Quick Search Tags
        const Text(
          'QUICK SEARCH TAGS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A9B6E),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _quickTags.map((tag) {
            return GestureDetector(
              onTap: () {
                _searchController.text = tag;
              },
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Voice content ─────────────────────────────────────────────────────────────

class _VoiceContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF4A7D62),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mic_rounded, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 16),
          Text(
            'TAP TO SPEAK',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared button inside scan/voice panels ────────────────────────────────────

class _SheetButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _SheetButton({required this.label, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE SUB-WIDGETS FOR QUICK LOG SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _QuickLogCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickLogCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BannerTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final VoidCallback onTap;

  const _ActivityTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected ? const Color(0xFF4A9B6E) : Colors.grey.shade400,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: selected ? const Color(0xFF1A1A1A) : Colors.grey.shade400,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}