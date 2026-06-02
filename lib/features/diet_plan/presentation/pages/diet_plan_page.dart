// lib/features/diet_plan/presentation/pages/diet_plan_page.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/model/meal_card_model.dart';
import '../../data/model/meal_option_model.dart';
import '../widgets/action_clip.dart';
import '../widgets/meal_card_widget.dart';
import '../widgets/meal_options_popup.dart';
import '../widgets/personalized_nutrition_card.dart';
import '../widgets/plan_history_dialog.dart';
import '../widgets/preference_dialog.dart';
import 'regenerate_plan_sheet.dart';

class DietPlanPage extends StatefulWidget {
  const DietPlanPage({super.key});

  @override
  State<DietPlanPage> createState() => _DietPlanPageState();
}

class _DietPlanPageState extends State<DietPlanPage> {
  Set<String> _loggedMeals = {};
  bool _isDietGenerated = false;
  bool _isGenerating = false;
  bool _isLoadingState = true;
  bool _isPolling = false;
  List<MealCard> _meals = [];
  String? _apiError;

  static const String _dietGeneratedKey = 'diet_plan_generated';

  // Meal visual configs
  static const _mealConfigs = [
    {
      'key': 'breakfast',
      'label': 'Breakfast',
      'time': '08:00 AM',
      'colors': ['#8D6E63', '#78909C'],
      'img':
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=300&q=80',
      'optImg':
          'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=200&q=80',
    },
    {
      'key': 'lunch',
      'label': 'Lunch',
      'time': '01:30 PM',
      'colors': ['#8D6E63', '#BF8B70'],
      'img':
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300&q=80',
      'optImg':
          'https://images.unsplash.com/photo-1547592180-85f173990554?w=200&q=80',
    },
    {
      'key': 'dinner',
      'label': 'Dinner',
      'time': '08:30 PM',
      'colors': ['#558B2F', '#7CB342'],
      'img':
          'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=300&q=80',
      'optImg':
          'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=200&q=80',
    },
  ];


  @override
  void initState() {
    super.initState();
    _loadState();
    // Debug: Check API response after load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _debugApiResponse();
    });
  }

  Future<void> _debugApiResponse() async {
    try {
      debugPrint('🔍 Testing API connection...');
      final response = await ApiService.getActiveDietPlan();
      debugPrint('📦 Full API Response: $response');

      if (response['dietPlan'] != null) {
        debugPrint('✅ Found dietPlan key');
        if (response['dietPlan'] is Map) {
          final dietPlan = response['dietPlan'] as Map;
          debugPrint('dietPlan keys: ${dietPlan.keys.toList()}');
          if (dietPlan.containsKey('mealPlan')) {
            debugPrint('mealPlan: ${dietPlan['mealPlan']}');
          }
          if (dietPlan.containsKey('breakfast')) {
            debugPrint('breakfast: ${dietPlan['breakfast']}');
          }
        }
      } else if (response.containsKey('breakfast')) {
        debugPrint('✅ Found breakfast key directly');
        debugPrint('breakfast: ${response['breakfast']}');
      } else {
        debugPrint('❌ Available keys: ${response.keys.toList()}');
      }
    } catch (e) {
      debugPrint('❌ API Error: $e');
    }
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final generated = prefs.getBool(_dietGeneratedKey) ?? false;
      final logsJson = prefs.getString('local_meal_logs') ?? '[]';
      final logs = jsonDecode(logsJson) as List<dynamic>;
      final today = DateTime.now();

      final loggedTypes = logs
          .where((log) {
            final date = DateTime.tryParse(log['date'] ?? '');
            if (date == null) return false;
            return date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;
          })
          .map((e) => e['type'] as String)
          .toSet();

      setState(() {
        _isDietGenerated = generated;
        _loggedMeals = loggedTypes;
        _isLoadingState = false;
      });

      // ALWAYS fetch from API if generated flag is true
      if (generated) {
        setState(() => _isPolling = true);
        await _fetchDietPlanFromApi();
      }
    } catch (e) {
      debugPrint('Error loading state: $e');
      if (mounted) {
        setState(() {
          _isLoadingState = false;
          _apiError = 'Failed to load preferences. Please restart the app.';
        });
      }
    }
  }

  Future<void> _fetchDietPlanFromApi() async {
    try {
      debugPrint('🔄 Fetching diet plan from API...');
      final response = await ApiService.getActiveDietPlan().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Request timeout'),
      );

      debugPrint('📦 API Response received');
      final parsed = _parseMealCards(response);

      if (parsed.isNotEmpty && mounted) {
        debugPrint('✅ Successfully parsed ${parsed.length} meals from API');
        setState(() {
          _meals = parsed;
          _isPolling = false;
          _isDietGenerated = true;
          _apiError = null;
        });
      } else {
        debugPrint('⚠️ No meals parsed from API, starting poll');
        await _pollForActivePlan();
      }
    } catch (e) {
      debugPrint('❌ Error fetching diet plan: $e');
      await _pollForActivePlan();
    }
  }

  Future<void> _loadLoggedMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getString('local_meal_logs') ?? '[]';
      final logs = jsonDecode(logsJson) as List<dynamic>;
      final today = DateTime.now();
      final loggedTypes = logs
          .where((log) {
            final date = DateTime.tryParse(log['date'] ?? '');
            if (date == null) return false;
            return date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;
          })
          .map((e) => e['type'] as String)
          .toSet();
      setState(() => _loggedMeals = loggedTypes);
    } catch (_) {}
  }

  Future<void> _pollForActivePlan({
    int maxRetries = 30,
    int intervalSec = 3,
  }) async {
    debugPrint('🔄 Starting poll (max $maxRetries × ${intervalSec}s)');

    for (int i = 0; i < maxRetries; i++) {
      await Future.delayed(Duration(seconds: intervalSec));
      if (!mounted) return;

      try {
        final response = await ApiService.getActiveDietPlan();
        final status = _extractStatus(response);
        final parsed = _parseMealCards(response);

        debugPrint(
            '🔄 Poll ${i + 1}/$maxRetries — status: $status — meals: ${parsed.length}');

        final hasValidMeals = parsed.isNotEmpty &&
            parsed.every((meal) => meal.options.isNotEmpty);

        if (hasValidMeals) {
          debugPrint('✅ Successfully loaded ${parsed.length} meals from API');
          if (mounted) {
            setState(() {
              _meals = parsed;
              _isPolling = false;
              _isDietGenerated = true;
              _apiError = null;
            });
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(_dietGeneratedKey, true);
          }
          return;
        }

        if (parsed.isNotEmpty && status == 'generating') {
          debugPrint('⏳ Partial data received, continuing to poll...');
          if (mounted) {
            setState(() {
              _meals = parsed;
            });
          }
          continue;
        }

        if (status != 'generating' &&
            status != 'pending' &&
            status != 'processing') {
          debugPrint(
              '⚠️ Status changed to "$status" with ${parsed.length} meals');
          if (parsed.isNotEmpty && mounted) {
            setState(() {
              _meals = parsed;
              _isPolling = false;
              _isDietGenerated = true;
            });
            return;
          }
          break;
        }
      } catch (e) {
        debugPrint('❌ Poll $i error: $e');
      }
    }

    if (mounted) {
      setState(() => _isPolling = false);

      if (_meals.isEmpty) {
        setState(() {
          _apiError = 'No diet plan found. Please generate a plan first.';
        });
      }
    }
  }

  String _extractStatus(Map<String, dynamic> response) {
    final plan = response['dietPlan'] ?? response['plan'] ?? response;
    if (plan is Map) return (plan['status'] ?? '').toString();
    return '';
  }

  List<MealCard> _parseMealCards(Map<String, dynamic> response) {
    try {
      debugPrint('🔍 Parsing response with keys: ${response.keys.toList()}');

      Map<String, dynamic>? dietPlanData;

      // Try different response structures
      if (response['dietPlan'] != null && response['dietPlan'] is Map) {
        dietPlanData = response['dietPlan'] as Map<String, dynamic>;
        debugPrint('Using dietPlan structure');
      } else if (response['plan'] != null && response['plan'] is Map) {
        dietPlanData = response['plan'] as Map<String, dynamic>;
        debugPrint('Using plan structure');
      } else if (response['mealPlan'] != null && response['mealPlan'] is Map) {
        dietPlanData = {'mealPlan': response['mealPlan']};
        debugPrint('Using mealPlan structure');
      } else if (response['meals'] != null && response['meals'] is Map) {
        dietPlanData = {'mealPlan': response['meals']};
        debugPrint('Using meals structure');
      } else if (response.keys
          .any((k) => ['breakfast', 'lunch', 'dinner'].contains(k))) {
        dietPlanData = {'mealPlan': response};
        debugPrint('Using direct meal keys structure');
      } else {
        debugPrint('❌ No valid meal plan structure found');
        return [];
      }

      final mealPlan = dietPlanData['mealPlan'];
      if (mealPlan is! Map<String, dynamic>) {
        debugPrint('❌ mealPlan is not a Map, it is: ${mealPlan.runtimeType}');
        return [];
      }

      debugPrint('🍽️ mealPlan keys: ${mealPlan.keys.toList()}');

      final result = <MealCard>[];

      for (final cfg in _mealConfigs) {
        final key = cfg['key'] as String;
        final rawVal = mealPlan[key];

        if (rawVal == null) {
          debugPrint('⚠️ No data for $key');
          continue;
        }

        List<MealOption> options = [];
        int kcal = 0;

        if (rawVal is List) {
          debugPrint('✅ $key is a List with ${rawVal.length} items');
          if (rawVal.isEmpty) continue;
          options = _parseOptionsList(rawVal, cfg['optImg'] as String);
          kcal = options.fold(0, (s, o) => s + o.kcal);
        } else if (rawVal is Map<String, dynamic>) {
          debugPrint('✅ $key is a Map with keys: ${rawVal.keys.toList()}');
          List<dynamic> optList = [];
          for (final listKey in [
            'meals',
            'options',
            'items',
            'foods',
            'mealOptions',
            'choices'
          ]) {
            if (rawVal[listKey] is List) {
              optList = rawVal[listKey] as List;
              debugPrint(
                  'Found options in "$listKey" with ${optList.length} items');
              break;
            }
          }

          if (optList.isEmpty &&
              (rawVal['name'] != null || rawVal['calories'] != null)) {
            optList = [rawVal];
            debugPrint('Single meal object found');
          }

          if (optList.isEmpty) {
            debugPrint('⚠️ No options list found for $key');
            continue;
          }

          options = _parseOptionsList(optList, cfg['optImg'] as String);
          if (options.isEmpty) continue;

          kcal = int.tryParse((rawVal['totalCalories'] ??
                      rawVal['calories'] ??
                      rawVal['kcal'] ??
                      rawVal['totalKcal'] ??
                      0)
                  .toString()) ??
              options.fold(0, (s, o) => s + o.kcal);
        } else {
          debugPrint('⚠️ Unexpected type for $key: ${rawVal.runtimeType}');
          continue;
        }

        if (options.isNotEmpty) {
          debugPrint(
              '✅ Built card for $key with ${options.length} options, $kcal kcal');
          result.add(_buildCard(cfg, options, kcal));
        }
      }

      debugPrint('✅ Total parsed ${result.length} meal cards');
      return result;
    } catch (e, stack) {
      debugPrint('❌ Error parsing meal cards: $e');
      debugPrint(stack.toString());
      return [];
    }
  }

  List<MealOption> _parseOptionsList(List<dynamic> raw, String fallbackImg) {
    return raw
        .whereType<Map<String, dynamic>>()
        .map((m) {
          final name = (m['name'] ??
                  m['title'] ??
                  m['mealName'] ??
                  m['foodName'] ??
                  m['itemName'] ??
                  m['dish'] ??
                  '')
              .toString();

          if (name.isEmpty) {
            debugPrint('⚠️ Skipping option with empty name');
            return null;
          }

          final ingredients = (m['ingredients'] ??
                  m['description'] ??
                  m['items'] ??
                  m['components'] ??
                  m['contents'] ??
                  m['details'] ??
                  m['composition'] ??
                  '')
              .toString();

          int kcal = 0;
          for (final calKey in [
            'calories',
            'kcal',
            'totalCalories',
            'cal',
            'energy',
            'calorieCount'
          ]) {
            final val = m[calKey];
            if (val != null) {
              kcal = int.tryParse(val.toString()) ?? 0;
              if (kcal > 0) break;
            }
          }

          final apiImg = (m['imageUrl'] ??
                  m['image'] ??
                  m['img'] ??
                  m['photo'] ??
                  m['picture'] ??
                  '')
              .toString();

          debugPrint('📝 Parsed option: $name, $kcal kcal');

          return MealOption(
            name: name,
            ingredients:
                ingredients.isEmpty ? 'No ingredients listed' : ingredients,
            kcal: kcal,
            imageUrl: _imageForFood(name, apiUrl: apiImg),
          );
        })
        .whereType<MealOption>()
        .toList();
  }

  /// Returns an image URL that visually matches the food [name].
  /// Uses Bing thumbnail search so every dish gets an accurate photo.
  String _imageForFood(String name, {String? apiUrl}) {
    final query = Uri.encodeComponent('$name indian food');
    return 'https://tse2.mm.bing.net/th?q=$query&w=300&h=300&c=7&rs=1&p=0&dpr=3&pid=1.7&mkt=en-IN&adlt=moderate';
  }

  MealCard _buildCard(
    Map<String, dynamic> cfg,
    List<MealOption> options,
    int kcal, {
    String? time,
    String? apiCardImage,
  }) {
    final cardImage = options.isNotEmpty
        ? options.first.imageUrl
        : (apiCardImage != null &&
                apiCardImage.isNotEmpty &&
                apiCardImage.startsWith('http'))
            ? apiCardImage
            : cfg['img'] as String;

    return MealCard(
      meal: cfg['label'] as String,
      time: time ?? cfg['time'] as String,
      kcal: kcal,
      items: options.length,
      imageUrl: cardImage,
      iconColors: (cfg['colors'] as List).cast<String>(),
      options: options,
    );
  }

  Future<void> _generatePlan() async {
    if (_isGenerating) return;
    setState(() {
      _isGenerating = true;
      _apiError = null;
    });

    try {
      await _clearTodaysLogs();
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = prefs.getString('diet_food_preferences') ?? '{}';
      final prefsMap = jsonDecode(prefsJson) as Map<String, dynamic>;
      final fitnessGoals = List<String>.from(prefsMap['4'] ?? []);

      debugPrint('🚀 Generating diet plan with goals: $fitnessGoals');

      await ApiService.generateDietPlan(
        dietaryPreference: 'vegetarian',
        allergies: const [],
        fitnessGoals: fitnessGoals,
      );

      await prefs.setBool(_dietGeneratedKey, true);

      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _isDietGenerated = true;
        _isPolling = true;
      });

      await _pollForActivePlan();
    } on HttpException catch (e) {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _isPolling = false;
        _apiError = e.message;
      });
      _showError(e.message);
    } on SocketException {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _isPolling = false;
        _apiError = 'No internet connection.';
      });
      _showError('No internet connection.');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _isPolling = false;
        _apiError = 'Failed to generate plan: $e';
      });
      _showError('Failed to generate plan. Please try again.');
    }
  }

  Future<void> _clearTodaysLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getString('local_meal_logs') ?? '[]';
      final logs = jsonDecode(logsJson) as List<dynamic>;
      final today = DateTime.now();
      logs.removeWhere((log) {
        final date = DateTime.tryParse(log['date'] ?? '');
        if (date == null) return false;
        return date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
      });
      await prefs.setString('local_meal_logs', jsonEncode(logs));
      if (mounted) {
        setState(() {
          _loggedMeals.clear();
        });
      }
    } catch (_) {}
  }

  Future<void> _onPlanRegenerated() async {
    await _clearTodaysLogs();
    setState(() {
      _isPolling = true;
      _apiError = null;
    });
    await _pollForActivePlan();
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(
            child:
                Text(msg, style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 4),
    ));
  }

  Future<void> _showMealOptions(MealCard meal) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => const SizedBox(),
      transitionBuilder: (context, animation, _, __) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.72,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F0),
                    borderRadius: BorderRadius.circular(28)),
                child: MealOptionsPopup(meal: meal),
              ),
            ),
          ),
        ),
      ),
    );
    _loadLoggedMeals();
  }

  void _showHistoryDialog() => showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Dismiss',
        barrierColor: Colors.black.withOpacity(0.35),
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => const SizedBox(),
        transitionBuilder: (_, animation, __, ___) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: const PlanHistoryDialog(),
          ),
        ),
      );

  void _showPreferenceDialog({String? source}) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => const SizedBox(),
      transitionBuilder: (_, animation, __, ___) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: PreferenceDialog(source: source),
        ),
      ),
    );

    if (result == true && source == 'regenerate') {
      _onPlanRegenerated();
    }
  }

  void _showRegenerateDialog() => showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Dismiss',
        barrierColor: Colors.black.withOpacity(0.35),
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => const SizedBox(),
        transitionBuilder: (_, animation, __, ___) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.88,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28)),
                  child: RegeneratePlanSheet(
                    onSuccess: _onPlanRegenerated,
                    onOpenPreference: () {
                      Navigator.pop(context);
                      _showPreferenceDialog(source: 'regenerate');
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  ActionButtons(
                    onHistoryTap: _showHistoryDialog,
                    onPreferenceTap: _showPreferenceDialog,
                    onRegenerateTap: _showRegenerateDialog,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text("Today's Plan",
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: DietColors.textPrimary,
                            letterSpacing: -0.5)),
                  ),
                  if (_isLoadingState)
                    const _PlanLoadingPlaceholder(message: 'Loading...')
                  else if (_isPolling)
                    const _GeneratingPlaceholder()
                  else if (_isDietGenerated && _meals.isNotEmpty)
                    ..._meals.map((meal) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: MealCardWidget(
                            meal: meal,
                            isDone: _loggedMeals.contains(meal.meal),
                            onTap: () => _showMealOptions(meal),
                          ),
                        ))
                  else if (_apiError != null)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            _apiError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _generatePlan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DietColors.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Generate Plan'),
                          ),
                        ],
                      ),
                    )
                  else
                    PersonalizedNutritionCard(
                      isGenerating: _isGenerating,
                      onGenerateTap: _generatePlan,
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlanLoadingPlaceholder extends StatelessWidget {
  final String message;
  const _PlanLoadingPlaceholder({this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) => Container(
        height: 220,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(28)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
                color: DietColors.primaryGreen, strokeWidth: 2.5),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
}

class _GeneratingPlaceholder extends StatefulWidget {
  const _GeneratingPlaceholder();

  @override
  State<_GeneratingPlaceholder> createState() => _GeneratingPlaceholderState();
}

class _GeneratingPlaceholderState extends State<_GeneratingPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _pulse = Tween<double>(begin: .6, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ]),
      child: Column(
        children: [
          FadeTransition(
            opacity: _pulse,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DietColors.primaryGreen.withOpacity(.1)),
              child: const Icon(Icons.restaurant_menu_rounded,
                  color: DietColors.primaryGreen, size: 34),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Crafting Your Plan',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          const Text(
            'Our AI is personalising your meals based\non your health profile. This takes ~30 seconds.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 22),
          const LinearProgressIndicator(
            color: DietColors.primaryGreen,
            backgroundColor: Color(0xFFE8F5E9),
          ),
          const SizedBox(height: 10),
          const Text('Fetching from server…',
              style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
