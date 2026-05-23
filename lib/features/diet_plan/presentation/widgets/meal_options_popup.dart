import 'package:flutter/material.dart';
import '../../data/model/meal_card_model.dart';
import '../../data/model/meal_option_model.dart';

class MealOptionsPopup extends StatelessWidget {
  final MealCard meal;

  const MealOptionsPopup({
    super.key,
    required this.meal,
  });

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color orangeAccent = Color(0xFFE65100);

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
                "${meal.meal} Options",
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
            itemCount: meal.options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, index) {
              final option = meal.options[index];

              return _buildOptionCard(option);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(MealOption option) {
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
                      ),

                      const SizedBox(height: 8),

                      Text(
                        option.ingredients,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          height: 1.4,
                        ),
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

            /// BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "LOG MEAL",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}