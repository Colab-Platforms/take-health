// lib/features/diet_plan/presentation/widgets/personalized_nutrition_card.dart
import 'package:flutter/material.dart';

class PersonalizedNutritionCard extends StatelessWidget {
  final VoidCallback? onGenerateTap;
  final bool          isGenerating;  // shows spinner on button while loading

  const PersonalizedNutritionCard({
    super.key,
    this.onGenerateTap,
    this.isGenerating = false,
  });

  static const Color _cardBg     = Color(0xFFF9F9F7);
  static const Color _titleColor = Color(0xFF1A1A1A);
  static const Color _bodyColor  = Color(0xFF555555);
  static const Color _boldColor  = Color(0xFF1A1A1A);
  static const Color _iconBg     = Color(0xFFEEEEEE);
  static const Color _iconColor  = Color(0xFF999999);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: const BoxDecoration(color: _iconBg, shape: BoxShape.circle),
            child: const Icon(Icons.restaurant_menu_rounded,
                color: _iconColor, size: 32),
          ),
          const SizedBox(height: 28),
          const Text(
            'Personalized Nutrition\nEngine',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.w600,
              color: _titleColor, height: 1.25, letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                  fontSize: 15, color: _bodyColor,
                  height: 1.6, fontWeight: FontWeight.w400),
              children: [
                TextSpan(text: 'Our AI will analyze your '),
                TextSpan(text: 'Health\nReports',
                    style: TextStyle(fontWeight: FontWeight.w700, color: _boldColor)),
                TextSpan(text: ', '),
                TextSpan(text: 'Fitness Goals',
                    style: TextStyle(fontWeight: FontWeight.w700, color: _boldColor)),
                TextSpan(text: ', and '),
                TextSpan(text: 'BMI',
                    style: TextStyle(fontWeight: FontWeight.w700, color: _boldColor)),
                TextSpan(text: ' to\ncurate a clinical-grade diet plan\njust for you.'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: _GenerateButton(
              onTap       : isGenerating ? null : onGenerateTap,
              isGenerating: isGenerating,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenerateButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool          isGenerating;
  const _GenerateButton({this.onTap, required this.isGenerating});

  @override
  State<_GenerateButton> createState() => _GenerateButtonState();
}

class _GenerateButtonState extends State<_GenerateButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 120),
        lowerBound: 0, upperBound: 1);
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown  : widget.isGenerating ? null : (_) => _ctrl.forward(),
      onTapUp    : widget.isGenerating ? null : (_) {
        _ctrl.reverse(); widget.onTap?.call();
      },
      onTapCancel: widget.isGenerating ? null : () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: widget.isGenerating
                ? const Color(0xFF3A3A3A)
                : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(999),
          ),
          child: widget.isGenerating
              ? const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.2)),
              SizedBox(width: 12),
              Text('GENERATING PLAN...',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: 1.2)),
            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SparkleIcon(),
              const SizedBox(width: 10),
              const Text('GENERATE MY\nPERSONALIZED PLAN',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: 1.2, height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SparkleIcon extends StatefulWidget {
  @override
  State<_SparkleIcon> createState() => _SparkleIconState();
}

class _SparkleIconState extends State<_SparkleIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: const Icon(Icons.auto_awesome_rounded,
          color: Color(0xFF3DBE8B), size: 18),
    );
  }
}