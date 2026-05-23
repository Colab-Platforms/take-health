// lib/features/diet_plan/presentation/widgets/food_icon_stack.dart
import 'package:flutter/material.dart';

class FoodIconStack extends StatelessWidget {
  final List<String> colorHexList;

  const FoodIconStack({super.key, required this.colorHexList});

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 28,
      child: Stack(
        children: List.generate(colorHexList.length, (i) {
          final color = _hexToColor(colorHexList[i]);
          return Positioned(
            left: i * 18.0,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: color.withOpacity(0.85),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                i == 0 ? Icons.rice_bowl_rounded : Icons.dinner_dining_rounded,
                size: 13,
                color: Colors.white,
              ),
            ),
          );
        }),
      ),
    );
  }
}