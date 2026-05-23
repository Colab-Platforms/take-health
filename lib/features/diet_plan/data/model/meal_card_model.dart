import 'meal_option_model.dart';

class MealCard {
  final String meal;
  final String time;
  final int kcal;
  final int items;
  final String imageUrl;
  final List<String> iconColors;
  final List<MealOption> options;

  const MealCard({
    required this.meal,
    required this.time,
    required this.kcal,
    required this.items,
    required this.imageUrl,
    required this.iconColors,
    required this.options,
  });
}