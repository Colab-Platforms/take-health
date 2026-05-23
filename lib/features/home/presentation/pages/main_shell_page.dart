import 'package:flutter/material.dart';
import 'package:classroom_app/features/home/presentation/pages/home_page.dart';
import 'package:classroom_app/features/home/presentation/pages/nutrition_page.dart';
import 'package:classroom_app/features/home/presentation/pages/reports_page.dart';

import '../../../diet_plan/presentation/pages/diet_plan_page.dart';

class MainShellPage extends StatefulWidget {
  final int initialTab;
  const MainShellPage({super.key, this.initialTab = 0});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(onViewFullPlan: () => _onTabSelected(3)),
      const NutritionPage(),
      const ReportsPage(),
      const DietPlanPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      floatingActionButton: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xff4A9B6E), Color(0xff2E7D50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff4A9B6E).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            // TODO: Add food logging action
          },
          elevation: 0,
          backgroundColor: Colors.transparent,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(width: 5),
              _buildNavItem(
                icon: Icons.grid_view_rounded,
                label: 'Home',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.monitor_heart_outlined,
                label: 'Nutrition',
                index: 1,
              ),
              const SizedBox(width: 25),
              _buildNavItem(
                icon: Icons.assignment_outlined,
                label: 'Reports',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.apple_outlined,
                label: 'Diet Plan',
                index: 3,
              ),
              SizedBox(width: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xff4A9B6E) : Colors.grey.shade400;

    return InkWell(
      onTap: () => _onTabSelected(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
