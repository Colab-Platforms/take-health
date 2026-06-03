// Updated MealOptionsPopup using your existing ApiService
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/model/meal_card_model.dart';
import '../../data/model/meal_option_model.dart';
import '../../../../core/services/api_service.dart';

class MealOptionsPopup extends StatefulWidget {
  final MealCard meal;

  const MealOptionsPopup({
    super.key,
    required this.meal,
  });

  @override
  State<MealOptionsPopup> createState() => _MealOptionsPopupState();
}

class _MealOptionsPopupState extends State<MealOptionsPopup> {
  bool _isLogging = false;
  String? _loggingError;
  int? _loggingMealIndex; // Track which meal is being logged
  final Set<int> _loggedIndices = {}; // Track successfully logged meals

  @override
  void initState() {
    super.initState();
    _loadLoggedMeals();
  }

  Future<void> _loadLoggedMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getString('local_meal_logs') ?? '[]';
      final logs = jsonDecode(logsJson) as List<dynamic>;

      final today = DateTime.now();
      final loggedNames = logs.where((log) {
        final date = DateTime.tryParse(log['date'] ?? '');
        if (date == null) return false;
        return date.year == today.year && 
               date.month == today.month && 
               date.day == today.day && 
               log['type'] == widget.meal.meal;
      }).map((e) => e['name'] as String).toSet();

      final newLoggedIndices = <int>{};
      for (int i = 0; i < widget.meal.options.length; i++) {
        if (loggedNames.contains(widget.meal.options[i].name)) {
          newLoggedIndices.add(i);
        }
      }

      if (newLoggedIndices.isNotEmpty && mounted) {
        setState(() {
          _loggedIndices.addAll(newLoggedIndices);
        });
      }
    } catch (_) {}
  }

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color orangeAccent = Color(0xFFE65100);

  Future<void> _logMeal(MealOption option, int index) async {
    setState(() {
      _isLogging = true;
      _loggingMealIndex = index;
      _loggingError = null;
    });

    try {
      // Convert the meal option to API format
      final foodItem = ApiService.convertMealOptionToApiFormat(
        option,
        widget.meal.meal.toLowerCase(),
      );

      // Call the API
      final response = await ApiService.logMeal(
        mealType: widget.meal.meal.toLowerCase(),
        foodItems: [foodItem],
        notes: 'Logged from Diet Plan app - ${DateTime.now()}',
        source: 'manual',
      );

      if (mounted) {
        setState(() {
          _loggedIndices.add(index);
        });

        // Save locally so it shows up in history
        try {
          final prefs = await SharedPreferences.getInstance();
          final logsJson = prefs.getString('local_meal_logs') ?? '[]';
          final logs = jsonDecode(logsJson) as List<dynamic>;
          logs.add({
            'name': option.name,
            'kcal': option.kcal,
            'type': widget.meal.meal,
            'date': DateTime.now().toIso8601String(),
          });
          await prefs.setString('local_meal_logs', jsonEncode(logs));
        } catch (_) {}

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text('✓ Meal logged successfully!'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to log meal';
        if (e.toString().contains('Session expired')) {
          errorMessage = 'Session expired. Please login again.';
          // Optionally navigate to login screen
        } else if (e.toString().contains('No internet')) {
          errorMessage = 'No internet connection. Please check your network.';
        } else {
          errorMessage = e.toString();
        }

        setState(() {
          _loggingError = errorMessage;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(errorMessage),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLogging = false;
          _loggingMealIndex = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// HEADER
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 16, 10),
          child: Row(
            children: [
              Text(
                "${widget.meal.meal} Options",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 18),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        /// OPTIONS
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: widget.meal.options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, index) {
              final option = widget.meal.options[index];
              final isThisMealLogging = _isLogging && _loggingMealIndex == index;
              final isLogged = _loggedIndices.contains(index);

              return _buildOptionCard(option, index, isThisMealLogging, isLogged);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(MealOption option, int index, bool isLoading, bool isLogged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOP ROW
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// IMAGE
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    option.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported, size: 40),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                /// DETAILS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        option.ingredients,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: orangeAccent,
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${option.kcal} KCAL",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: orangeAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            /// LOG MEAL BUTTON with loading state
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (isLoading || isLogged) ? null : () => _logMeal(option, index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLogged ? Colors.grey.shade400 : primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isLogged) ...[
                            const Icon(Icons.check, size: 18),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            isLogged ? "LOGGED" : "LOG MEAL",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            /// Show error message for this specific meal if any
            if (_loggingError != null && _loggingMealIndex == index)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, size: 16, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _loggingError!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}