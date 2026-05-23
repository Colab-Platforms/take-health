// lib/features/diet_plan/presentation/pages/diet_plan_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/model/meal_card_model.dart';
import '../../data/model/meal_option_model.dart';
import '../widgets/action_clip.dart';
import '../widgets/meal_card_widget.dart';
import '../widgets/meal_options_popup.dart';
import '../widgets/preference_dialog.dart';
import 'meal_options_sheet.dart';
import 'regenerate_plan_sheet.dart';

class DietPlanPage extends StatefulWidget {
  const DietPlanPage({super.key});

  @override
  State<DietPlanPage> createState() => _DietPlanPageState();
}

class _DietPlanPageState extends State<DietPlanPage> {
  final List<MealCard> _meals = const [
    MealCard(
      meal: 'Breakfast',
      time: '08:00 AM',
      kcal: 2224,
      items: 2,
      imageUrl:
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=300&q=80',
      iconColors: ['#8D6E63', '#78909C'],
      options: [
        MealOption(
          name: 'Moong Dal Chilla with Green Chutney + 1 Medium Banana',
          ingredients:
          '2 MEDIUM CHILLAS (160G) + 2 TBSP CHUTNEY (30G) + 1 MEDIUM BANANA (100G)',
          kcal: 430,
          imageUrl:
          'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=200&q=80',
        ),
        MealOption(
          name: 'Vegetable Upma with Coconut Chutney + 1 Glass Low-Fat Milk',
          ingredients:
          '1.5 BOWL UPMA (250G) + 2 TBSP CHUTNEY (30G) + 1 GLASS MILK (200ML)',
          kcal: 428,
          imageUrl:
          'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=200&q=80',
        ),
      ],
    ),
    MealCard(
      meal: 'Lunch',
      time: '01:30 PM',
      kcal: 2668,
      items: 2,
      imageUrl:
      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300&q=80',
      iconColors: ['#8D6E63', '#BF8B70'],
      options: [
        MealOption(
          name: 'Grilled Chicken with Brown Rice + Stir-fried Vegetables',
          ingredients:
          '150G CHICKEN BREAST + 1 CUP BROWN RICE (185G) + 1 CUP VEG (120G)',
          kcal: 520,
          imageUrl:
          'https://images.unsplash.com/photo-1547592180-85f173990554?w=200&q=80',
        ),
        MealOption(
          name: 'Dal Tadka with 2 Rotis + Cucumber Raita',
          ingredients:
          '1 BOWL DAL (200G) + 2 WHEAT ROTIS (60G) + 1 SMALL BOWL RAITA (100G)',
          kcal: 480,
          imageUrl:
          'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=200&q=80',
        ),
      ],
    ),
    MealCard(
      meal: 'Dinner',
      time: '08:30 PM',
      kcal: 1778,
      items: 2,
      imageUrl:
      'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=300&q=80',
      iconColors: ['#558B2F', '#7CB342'],
      options: [
        MealOption(
          name: 'Palak Paneer with 2 Rotis + Mixed Salad',
          ingredients:
          '1 BOWL PALAK PANEER (200G) + 2 ROTIS (60G) + 1 BOWL SALAD (80G)',
          kcal: 420,
          imageUrl:
          'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=200&q=80',
        ),
        MealOption(
          name: 'Vegetable Khichdi + Low-Fat Curd',
          ingredients: '1.5 BOWL KHICHDI (300G) + 1 SMALL BOWL CURD (100G)',
          kcal: 390,
          imageUrl:
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=200&q=80',
        ),
      ],
    ),
  ];

  void _showMealOptions(MealCard meal) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            ),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.72,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F0),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: MealOptionsPopup(meal: meal),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPreferenceDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: const PreferenceDialog(),
          ),
        );
      },
    );
  }

  void _showRegenerateDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.88,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const RegeneratePlanSheet(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DietColors.bgColor,
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
                color: DietColors.appBarGreen,
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
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: DietColors.appBarGreen,
                size: 22,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                ActionButtons(
                  onHistoryTap: () {},
                  onPreferenceTap: _showPreferenceDialog,
                  onRegenerateTap: _showRegenerateDialog,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "Today's Plan",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: DietColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                ..._meals.map((meal) => MealCardWidget(
                  meal: meal,
                  onTap: () => _showMealOptions(meal),
                )),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'chat',
        mini: true,
        backgroundColor: Colors.white,
        foregroundColor: DietColors.primaryGreen,
        elevation: 4,
        onPressed: () {},
        child: const Icon(Icons.chat_bubble_outline, size: 20),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}