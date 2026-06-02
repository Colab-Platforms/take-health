// lib/features/diet_plan/presentation/widgets/preference_dialog.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_theme.dart';

class PreferenceDialog extends StatefulWidget {
  final String? source; // 'preferences' or 'regenerate'

  const PreferenceDialog({super.key, this.source});

  @override
  State<PreferenceDialog> createState() => _PreferenceDialogState();
}

class _PreferenceDialogState extends State<PreferenceDialog> {
  int _selectedTab  = 0;
  bool _isLoading   = true;
  bool _isSaving    = false;
  String? _apiError; // shown when the API fails

  // tab 0=Breakfast  1=Lunch  2=Snacks  3=Dinner  4=General
  final Map<int, List<String>> _allPreferences = {
    0: [], 1: [], 2: [], 3: [], 4: [],
  };

  final List<String> _quickAddItems = [
    "Oats", "Smoothie", "Idli", "Poha", "Paratha", "Dosa", "Fruits"
  ];

  final TextEditingController _textController = TextEditingController();

  static const String _prefKey = 'diet_food_preferences';

  List<String> get _currentItems   => _allPreferences[_selectedTab]!;
  int get _totalSelected =>
      _allPreferences.values.fold(0, (s, l) => s + l.length);

  bool get _isFromRegenerate => widget.source == 'regenerate';

  // ════════════════════════ LIFECYCLE ══════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // ════════════════════════ PERSISTENCE ════════════════════════════════════

  Future<void> _loadPreferences() async {
    final prefs  = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_prefKey);
    if (raw != null) {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      for (int i = 0; i < 5; i++) {
        final key = i.toString();
        if (decoded.containsKey(key)) {
          _allPreferences[i] = List<String>.from(decoded[key] as List<dynamic>);
        }
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, List<String>> toEncode = {
      for (int i = 0; i < 5; i++) i.toString(): _allPreferences[i]!,
    };
    await prefs.setString(_prefKey, jsonEncode(toEncode));
  }

  // ════════════════════════ API CALL ═══════════════════════════════════════

  Future<void> _onSavePressed() async {
    if (_totalSelected == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please add at least one preference'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() { _isSaving = true; _apiError = null; });

    try {
      // ApiService handles Bearer token + retry + error parsing automatically
      await ApiService.saveFoodPreferences(
        preferredFoods      : List<String>.from(_allPreferences[4]!),
        foodsToAvoid        : const [],
        dietaryRestrictions : const [],
        mealPreferences     : {
          'breakfast' : List<String>.from(_allPreferences[0]!),
          'lunch'     : List<String>.from(_allPreferences[1]!),
          'snacks'    : List<String>.from(_allPreferences[2]!),
          'dinner'    : List<String>.from(_allPreferences[3]!),
        },
      );

      // Also persist locally so the dialog re-opens with saved state
      await _saveLocally();

      // If from regenerate tab, call generate then close
      if (_isFromRegenerate) {
        final user = await ApiService.getUser();
        final pref = user?['profile']?['dietaryPreference'] ?? 'vegetarian';
        await ApiService.generateDietPlan(
          dietaryPreference: pref.toString(),
          allergies: const [],
          fitnessGoals: List<String>.from(_allPreferences[4]!),
        );
        if (!mounted) return;
        Navigator.pop(context, true); // Return true to indicate regeneration started
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$_totalSelected preferences saved!'),
          backgroundColor: DietColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.pop(context);
      }

    } on SocketException {
      setState(() => _apiError = 'No internet connection. Please try again.');
    } on HttpException catch (e) {
      // HttpException message already contains the server error + status code
      setState(() => _apiError = e.message);
    } catch (e) {
      setState(() => _apiError = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ════════════════════════ HELPERS ════════════════════════════════════════

  String _getHintText() {
    switch (_selectedTab) {
      case 0: return "Add breakfast...";
      case 1: return "Add lunch...";
      case 2: return "Add snacks...";
      case 3: return "Add dinner...";
      case 4: return "Add preference...";
      default: return "Add item...";
    }
  }

  void _addItem() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && !_currentItems.contains(text)) {
      setState(() { _currentItems.add(text); _textController.clear(); });
    }
  }

  void _removeItem(String item) => setState(() => _currentItems.remove(item));

  void _addQuickItem(String item) {
    if (!_currentItems.contains(item)) setState(() => _currentItems.add(item));
  }

  // ════════════════════════ BUILD ══════════════════════════════════════════

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
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
            ),
            child: _isLoading
                ? const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(
                    color: DietColors.primaryGreen),
              ),
            )
                : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildTabs(),
                const SizedBox(height: 20),

                // Scrollable body
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInput(),
                        const SizedBox(height: 15),
                        _buildQuickAdd(),
                        const SizedBox(height: 18),
                        const Divider(),
                        const SizedBox(height: 18),
                        _buildSelectedSection(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Error banner (shown only when API fails)
                if (_apiError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: Colors.red, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _apiError!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _apiError = null),
                            child: const Icon(Icons.close,
                                size: 16, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Fixed save button
                Padding(
                  padding: const EdgeInsets.only(bottom: 24, top: 8),
                  child: _buildSaveButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Food Preferences",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              SizedBox(height: 5),
              Text("TELL US WHAT YOU LIKE FOR EACH MEAL",
                  style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    letterSpacing: 1.2, color: Colors.grey,
                  )),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
                color: Colors.grey.shade100, shape: BoxShape.circle),
            child: const Icon(Icons.close, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  // ─── Tabs ─────────────────────────────────────────────────────────────────
  Widget _buildTabs() {
    final tabs = [
      {'emoji': '🍳', 'label': 'BREAKFAST'},
      {'emoji': '🥗', 'label': 'LUNCH'},
      {'emoji': '🍎', 'label': 'SNACKS'},
      {'emoji': '🌙', 'label': 'DINNER'},
      {'emoji': '⭐', 'label': 'GENERAL'},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _mealTab(tabs[i]['emoji']!, tabs[i]['label']!,
              _selectedTab == i, i),
        )),
      ),
    );
  }

  Widget _mealTab(String emoji, String label, bool active, int index) {
    final count = _allPreferences[index]!.length;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedTab = index;
        _textController.clear();
      }),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              if (count > 0)
                Positioned(
                  right: -6, top: 0,
                  child: Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(
                        color: DietColors.cardGreen, shape: BoxShape.circle),
                    child: Center(
                      child: Text('$count',
                          style: const TextStyle(
                              fontSize: 9, color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: active ? DietColors.primaryGreen : Colors.grey,
              )),
          const SizedBox(height: 10),
          if (active)
            Container(width: 64, height: 2, color: DietColors.primaryGreen),
        ],
      ),
    );
  }

  // ─── Input ────────────────────────────────────────────────────────────────
  Widget _buildInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _textController,
            decoration: InputDecoration(
              hintText: _getHintText(),
              hintStyle: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.w600),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
              filled: true,
              fillColor: DietColors.inputBg,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 16),
            ),
            style: const TextStyle(
                color: DietColors.textPrimary, fontWeight: FontWeight.w600),
            onSubmitted: (_) => _addItem(),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _addItem,
          child: Container(
            width: 84, height: 54,
            decoration: BoxDecoration(
                color: DietColors.cardGreen,
                borderRadius: BorderRadius.circular(18)),
            child: const Center(
              child: Text("ADD",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Quick add ────────────────────────────────────────────────────────────
  Widget _buildQuickAdd() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("QUICK ADD",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                letterSpacing: 1, color: Colors.grey)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: _quickAddItems.map(_quickChip).toList(),
        ),
      ],
    );
  }

  Widget _quickChip(String text) {
    final bool isSelected = _currentItems.contains(text);
    return GestureDetector(
      onTap: () => _addQuickItem(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? DietColors.cardGreen.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? DietColors.cardGreen : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.add_circle_outline,
              size: 16,
              color: isSelected ? DietColors.cardGreen : DietColors.greyText,
            ),
            const SizedBox(width: 6),
            Text(text,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? DietColors.cardGreen : DietColors.greyText,
                )),
          ],
        ),
      ),
    );
  }

  // ─── Selected section ─────────────────────────────────────────────────────
  Widget _buildSelectedSection() {
    if (_currentItems.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("SELECTED (0)",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  letterSpacing: 1, color: Colors.grey)),
          SizedBox(height: 16),
          Center(
            child: Text("No items selected yet",
                style: TextStyle(fontSize: 14, color: Colors.grey,
                    fontStyle: FontStyle.italic)),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("SELECTED (${_currentItems.length})",
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                letterSpacing: 1, color: Colors.grey)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12, runSpacing: 12,
          children: _currentItems.map(_selectedChip).toList(),
        ),
      ],
    );
  }

  Widget _selectedChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: DietColors.cardGreen, borderRadius: BorderRadius.circular(28)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _removeItem(text),
            child: const Icon(Icons.close, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  // ─── Save button ──────────────────────────────────────────────────────────
  Widget _buildSaveButton() {
    // Different button text based on source
    final buttonText = _isFromRegenerate
        ? "Save and generate new plan"
        : "Save preferences";

    final buttonSubText = _isFromRegenerate
        ? "${_totalSelected} ITEMS"
        : "$_totalSelected ITEMS";

    return GestureDetector(
      onTap: _isSaving ? null : _onSavePressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 58,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _isSaving
              ? DietColors.cardGreen.withOpacity(.7)
              : DietColors.cardGreen,
          borderRadius: BorderRadius.circular(28),
        ),
        child: _isSaving
            ? const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              ),
              SizedBox(width: 14),
              Text("SAVING...",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  )),
            ],
          ),
        )
            : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
              Text(buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  )),
                      //   const SizedBox(width: 0),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 5, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(buttonSubText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
              ),
                        ],
                      ),
            ),
      ),
    );
  }
}