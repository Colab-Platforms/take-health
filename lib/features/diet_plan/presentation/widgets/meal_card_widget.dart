// lib/features/diet_plan/presentation/widgets/meal_card_widget.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/model/meal_card_model.dart';
import 'food_icon_stack.dart';

class MealCardWidget extends StatelessWidget {
  final MealCard meal;
  final VoidCallback onTap;
  final bool isDone;

  const MealCardWidget({
    super.key,
    required this.meal,
    required this.onTap,
    this.isDone = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            _buildRightImage(),
            _buildLeftContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildRightImage() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: SizedBox(
          width: 150,
          child: Image.network(
            meal.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: const Color(0xFFE8F5E9),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF4CAF50),
                    strokeWidth: 2,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFFE8F5E9),
              child: const Icon(Icons.restaurant,
                  color: Color(0xFF4CAF50), size: 40),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftContent() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meal.meal,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: DietColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              FoodIconStack(
                imageUrls: meal.options.map((o) => o.imageUrl).toList(),
              ),
              const SizedBox(width: 8),
              Text(
                '${meal.items} ITEMS',
                style: const TextStyle(
                  fontSize: 12,
                  color: DietColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 15, color: DietColors.primaryGreen),
              const SizedBox(width: 4),
              Text(
                meal.time,
                style: const TextStyle(
                  fontSize: 13,
                  color: DietColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.local_fire_department_rounded,
                  size: 15, color: DietColors.orangeAccent),
              const SizedBox(width: 4),
              Text(
                '${meal.kcal} KCAL',
                style: const TextStyle(
                  fontSize: 13,
                  color: DietColors.orangeAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDone ? Colors.green.shade600 : DietColors.primaryGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isDone ? Icons.check_rounded : Icons.arrow_outward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              if (isDone) ...[
                const SizedBox(width: 12),
                Text(
                  "LOGGED",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.green.shade700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}