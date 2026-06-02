// lib/features/diet_plan/presentation/widgets/food_icon_stack.dart
import 'package:flutter/material.dart';

class FoodIconStack extends StatelessWidget {
  final List<String> imageUrls;

  const FoodIconStack({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    final urls = imageUrls.take(2).toList(); // show at most 2
    if (urls.isEmpty) return const SizedBox(width: 46, height: 28);

    return SizedBox(
      width: 20.0 + (urls.length - 1) * 18.0 + 8,
      height: 28,
      child: Stack(
        children: List.generate(urls.length, (i) {
          return Positioned(
            left: i * 18.0,
            top: 1,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  urls[i],
                  width: 22,
                  height: 22,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.restaurant, size: 12, color: Colors.grey),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}