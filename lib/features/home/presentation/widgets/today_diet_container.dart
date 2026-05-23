import 'package:flutter/material.dart';

class TodayDietContainer extends StatefulWidget {
  final VoidCallback onViewFullPlan;
  const TodayDietContainer({super.key, required this.onViewFullPlan});

  @override
  State<TodayDietContainer> createState() => _TodayDietContainerState();
}

class _TodayDietContainerState extends State<TodayDietContainer> {
  int _selectedMealIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.78);

  final List<String> _mealTabs = ['BREAKFAST', 'LUNCH', 'DINNER'];

  // Different food data for each meal
  final Map<String, List<Map<String, String>>> _mealData = {
    'BREAKFAST': [
      {
        'name': 'Paneer Bhurji with Multi...',
        'description': '1.5 BOWL PANEER BHURJI (250G)\n+ 3 MEDIUM MULTIGRAIN...',
        'calories': '1112 KCAL',
        'image': 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=400',
      },
      {
        'name': 'Egg White Omelette',
        'description': '6 EGG WHITE OMELETTE\n1.5 BOWL OATS...',
        'calories': '850 KCAL',
        'image': 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=400',
      },
    ],
    'LUNCH': [
      {
        'name': 'Grilled Chicken Salad',
        'description': '200G GRILLED CHICKEN\n+ MIXED GREENS BOWL...',
        'calories': '680 KCAL',
        'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
      },
      {
        'name': 'Brown Rice & Dal',
        'description': '1 BOWL BROWN RICE\n+ 1 BOWL DAL TADKA...',
        'calories': '720 KCAL',
        'image': 'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=400',
      },
    ],
    'DINNER': [
      {
        'name': 'Fish Curry with Roti',
        'description': '200G FISH CURRY\n+ 2 MULTIGRAIN ROTI...',
        'calories': '590 KCAL',
        'image': 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=400',
      },
      {
        'name': 'Palak Paneer & Chapati',
        'description': '1 BOWL PALAK PANEER\n+ 2 CHAPATI...',
        'calories': '650 KCAL',
        'image': 'https://images.unsplash.com/photo-1645177628172-a94c1f96e6db?w=400',
      },
    ],
  };

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentMeal = _mealTabs[_selectedMealIndex];
    final foods = _mealData[currentMeal]!;

    // Get today's date
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Diet",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Meal Tabs
          Row(
            children: List.generate(_mealTabs.length, (index) {
              final isSelected = _selectedMealIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMealIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xff4A9B6E)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                      border: isSelected
                          ? null
                          : Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      _mealTabs[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 18),

          // Food Cards Carousel
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: SizedBox(
              key: ValueKey(currentMeal),
              height: 235,
              child: PageView.builder(
                controller: _pageController,
                itemCount: foods.length,
                padEnds: false,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildFoodCard(foods[index]),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Page Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(foods.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 8,
                width: index == 0 ? 20 : 8,
                decoration: BoxDecoration(
                  color: index == 0
                      ? const Color(0xff4A9B6E)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          const SizedBox(height: 18),

          // View Full Plan Button
          GestureDetector(
            onTap: widget.onViewFullPlan,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xff4A9B6E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Full Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(Map<String, String> food) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(18),
            ),
            child: SizedBox(
              height: 115,
              width: double.infinity,
              child: Image.network(
                food['image']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.green.shade100,
                    child: Center(
                      child: Icon(
                        Icons.restaurant,
                        color: Colors.green.shade300,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Food Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food['name']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 12,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        food['description']!.replaceAll('\n', ' + '),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 14,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      food['calories']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
