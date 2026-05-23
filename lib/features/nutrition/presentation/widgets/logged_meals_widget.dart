import 'package:flutter/material.dart';

class LoggedMealsWidget extends StatelessWidget {
  final VoidCallback? onLogMeal;
  const LoggedMealsWidget({super.key, this.onLogMeal});

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

            children: [

              const Text(
                "Logged Meals",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              Text(
                "VIEW MENU",
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.symmetric(
              vertical: 40,
            ),

            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(28),

              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.green.shade50,
                ],
              ),
            ),

            child: Column(
              children: [

                Icon(
                  Icons.restaurant_menu,
                  size: 42,
                  color: Colors.green.shade700,
                ),

                const SizedBox(height: 14),

                const Text(
                  "NO MEALS LOGGED",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 18),

                GestureDetector(
                  onTap:  onLogMeal,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xff5D8B74),
                      borderRadius:
                      BorderRadius.circular(18),
                    ),

                    child: const Text(
                      "LOG FIRST MEAL",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
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
  }
}