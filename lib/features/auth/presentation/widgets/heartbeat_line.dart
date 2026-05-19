import 'dart:math' as math;
import 'package:flutter/material.dart';

class HeartbeatLine extends StatefulWidget {
  final Color color;
  final double height;

  const HeartbeatLine({
    super.key,
    this.color = const Color(0xFF5DF6A8), // Light glowing mint green
    this.height = 60.0,
  });

  @override
  State<HeartbeatLine> createState() => _HeartbeatLineState();
}

class _HeartbeatLineState extends State<HeartbeatLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    // Loop the pulse animation with a small delay or loop infinitely
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _HeartbeatPainter(
              progress: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class _HeartbeatPainter extends CustomPainter {
  final double progress;
  final Color color;

  _HeartbeatPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final double width = size.width;
    final double height = size.height;
    final double centerY = height / 2;

    path.moveTo(0, centerY);

    // Let the pulse center travel across the screen
    final double pulseCenterX = width * progress;
    // Set width of the heartbeat peak structure
    const double pulseWidth = 100.0;

    for (double x = 0; x <= width; x += 1.5) {
      double y = centerY;
      final double dx = x - pulseCenterX;

      if (dx.abs() < pulseWidth / 2) {
        // Normalize coordinate within pulse width between -1.0 and 1.0
        final double t = dx / (pulseWidth / 2);

        // ECG mathematical formula representing P-Q-R-S-T peaks
        double ecgOffset = 0.0;
        if (t < -0.7) {
          // P wave: small bump
          final double pt = (t + 0.95) / 0.25;
          if (pt > 0 && pt < 1) {
            ecgOffset = 0.15 * centerY * math.sin(pt * math.pi);
          }
        } else if (t < -0.45) {
          // PR segment: flat
        } else if (t < -0.3) {
          // Q wave: small dip
          final double qt = (t + 0.45) / 0.15;
          if (qt > 0 && qt < 1) {
            ecgOffset = -0.18 * centerY * math.sin(qt * math.pi);
          }
        } else if (t < 0.1) {
          // R wave (huge peak) and S wave (deep dip)
          final double rst = (t + 0.3) / 0.4; // 0 to 1
          if (rst > 0 && rst < 1) {
            if (rst < 0.45) {
              // High peak
              final double rFactor = rst / 0.45;
              ecgOffset = 0.85 * centerY * rFactor;
            } else if (rst < 0.8) {
              // Steep drop to S dip
              final double sFactor = (rst - 0.45) / 0.35;
              ecgOffset = 0.85 * centerY - (1.35 * centerY * sFactor);
            } else {
              // Return to baseline
              final double returnFactor = (rst - 0.8) / 0.2;
              ecgOffset = -0.5 * centerY * (1.0 - returnFactor);
            }
          }
        } else if (t < 0.5) {
          // ST segment: returning to baseline
          final double st = (t - 0.1) / 0.4;
          if (st > 0 && st < 1) {
            ecgOffset = -0.1 * centerY * (1.0 - st);
          }
        } else if (t < 0.9) {
          // T wave: medium bump
          final double tt = (t - 0.5) / 0.4;
          if (tt > 0 && tt < 1) {
            ecgOffset = 0.25 * centerY * math.sin(tt * math.pi);
          }
        }
        y = centerY - ecgOffset;
      }
      path.lineTo(x, y);
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeartbeatPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
