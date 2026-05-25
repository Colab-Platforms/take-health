import 'package:flutter/material.dart';

import '../../../home/presentation/pages/main_shell_page.dart';

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  int _hydrationGlasses = 0;
  static const int _hydrationGoal = 8;
  static const int _mlPerGlass = 250;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
          // ── Nutrition Tracker header ─────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Nutrition Tracker',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Achieve wellness goals...',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const AddToMealSheet(selectedMode: 0,),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A7C6F),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Log Meal',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const AddToMealSheet(selectedMode: 0,),
                        );
                      },
                      child: _IconBtn(icon: Icons.camera_alt_outlined)),

                  const SizedBox(width: 6),

                  GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const AddToMealSheet(selectedMode: 2,),
                        );
                      },
                      child: _IconBtn(icon: Icons.mic_none_rounded)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Daily Calorie Intake ─────────────────────────────────────────
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Calorie Intake',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '0',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const Text(
                      ' / 1602',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const Spacer(),
                    const Text(
                      '0% OF GOAL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4A7C6F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF4A7C6F)),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '1602 kcal remaining',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4A7C6F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _MacroItem(
                        label: 'PROTEIN',
                        consumed: '0g',
                        goal: '61g',
                        color: Colors.redAccent),
                    _MacroItem(
                        label: 'CARBS',
                        consumed: '0g',
                        goal: '247g',
                        color: Colors.blue),
                    _MacroItem(
                        label: 'FATS',
                        consumed: '0g',
                        goal: '41g',
                        color: Colors.orange),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Nutrition Insight ────────────────────────────────────────────
          _Card(
            color: const Color(0xFFFFF8F0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.warning_amber_rounded,
                      color: Colors.orange.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'NUTRITION INSIGHT',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A),
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 8),
                          _AiBadge(),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Analyzing your eating patterns...',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Today header ─────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TODAY, 23 MAY 2026',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade700,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(Icons.calendar_today_outlined,
                  size: 18, color: Colors.grey.shade500),
            ],
          ),
          const SizedBox(height: 10),

          // ── Meal rows ────────────────────────────────────────────────────
          _MealRow(
            icon: Icons.coffee_outlined,
            iconColor: Colors.orange,
            label: 'Breakfast',
            kcal: '481 KCAL',
          ),
          const SizedBox(height: 10),
          _MealRow(
            icon: Icons.restaurant_outlined,
            iconColor: Colors.green,
            label: 'Lunch',
            kcal: '641 KCAL',
          ),
          const SizedBox(height: 10),
          _MealRow(
            icon: Icons.nightlight_outlined,
            iconColor: Colors.redAccent,
            label: 'Dinner',
            kcal: '481 KCAL',
          ),
          const SizedBox(height: 14),

          // ── Diet Quality Score ───────────────────────────────────────────
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        size: 16, color: Colors.amber.shade600),
                    const SizedBox(width: 6),
                    const Text(
                      'DIET QUALITY SCORE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _QualityRow(
                  label: "TODAY'S QUALITY",
                  healthy: 15,
                  average: 25,
                  junk: 10,
                ),
                const SizedBox(height: 12),
                const _QualityRow(
                  label: 'OVERALL BIO TREND',
                  healthy: 0,
                  average: 100,
                  junk: 0,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Track your first meal to unlock personalized biological fuel insights.',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Recent & Frequent ────────────────────────────────────────────
          // ── Recent & Frequent ────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Recent',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No recent meals',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Frequent',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _Chip(label: 'Oats'),
                          _Chip(label: 'Eggs'),
                          _Chip(label: 'Rice'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Hydration Tracker ────────────────────────────────────────────
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hydration Tracker',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  'GOAL: $_hydrationGoal GLASSES',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_hydrationGlasses > 0) {
                          setState(() => _hydrationGlasses--);
                        }
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.remove, size: 18),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_hydrationGlasses < _hydrationGoal) {
                          setState(() => _hydrationGlasses++);
                        }
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A7C6F),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_hydrationGlasses * _mlPerGlass} ml',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4A7C6F),
                      ),
                    ),
                    Text(
                      '${(_hydrationGoal - _hydrationGlasses) * _mlPerGlass} ml left',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _hydrationGlasses / _hydrationGoal,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF4A7C6F)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Weekly Trends ────────────────────────────────────────────────
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Trends',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 80,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _Bar(label: 'MON', fraction: 0.6),
                      _Bar(label: 'TUE', fraction: 0.8),
                      _Bar(label: 'WED', fraction: 0.5),
                      _Bar(label: 'THU', fraction: 0.9),
                      _Bar(label: 'FRI', fraction: 0.4),
                      _Bar(label: 'SAT', fraction: 0.7, highlight: true),
                      _Bar(label: 'SUN', fraction: 0.3),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    _StatChip(label: 'AVERAGE', value: '1707 kcal'),
                    SizedBox(width: 24),
                    _StatChip(label: 'VARIATION', value: '-10%'),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
  }
}

// ── Reusable widgets ───────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final Color? color;
  const _Card({required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  const _IconBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 18, color: const Color(0xFF4A7C6F)),
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String label;
  final String consumed;
  final String goal;
  final Color color;
  const _MacroItem({
    required this.label,
    required this.consumed,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: consumed,
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800, color: color),
              ),
              TextSpan(
                text: ' / $goal',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AiBadge extends StatelessWidget {
  const _AiBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.orange.shade400,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'AI ANALYSIS',
        style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5),
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String kcal;
  const _MealRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.kcal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          Column(
            children: [
              const Text(
                '0',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 4),
              Text(
                'OF $kcal',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(width: 10),
          const Icon(Icons.add, size: 20, color: Color(0xFF4A7C6F)),
        ],
      ),
    );
  }
}

class _QualityRow extends StatelessWidget {
  final String label;
  final int healthy;
  final int average;
  final int junk;
  const _QualityRow({
    required this.label,
    required this.healthy,
    required this.average,
    required this.junk,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey),
            ),
            Row(
              children: [
                Text('${healthy}% Healty',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.green)),
                const SizedBox(width: 8),
                Text('${average}% Average',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey)),
                const SizedBox(width: 8),
                Text('${junk}% Junk',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: [
              Expanded(
                flex: healthy < 1 ? 1 : healthy,
                child: Container(height: 6, color: Colors.green.shade400),
              ),
              Expanded(
                flex: average < 1 ? 98 : average,
                child: Container(height: 6, color: Colors.grey.shade300),
              ),
              Expanded(
                flex: junk < 1 ? 1 : junk,
                child: Container(height: 6, color: Colors.orange.shade400),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.green.shade700),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double fraction;
  final bool highlight;
  const _Bar({
    required this.label,
    required this.fraction,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: 60 * fraction,
          decoration: BoxDecoration(
            color: highlight ? const Color(0xFF4A7C6F) : Colors.green.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
