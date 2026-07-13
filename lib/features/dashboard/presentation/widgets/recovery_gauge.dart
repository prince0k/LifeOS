import 'dart:math';
import 'package:flutter/material.dart';

class RecoveryGauge extends StatefulWidget {
  final double score;
  final Color baseColor;

  const RecoveryGauge({
    super.key,
    required this.score,
    required this.baseColor,
  });

  @override
  State<RecoveryGauge> createState() => _RecoveryGaugeState();
}

class _RecoveryGaugeState extends State<RecoveryGauge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0, end: widget.score).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant RecoveryGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation = Tween<double>(begin: _animation.value, end: widget.score).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: 180,
          height: 180,
          child: CustomPaint(
            painter: _GaugePainter(
              value: _animation.value,
              baseColor: widget.baseColor,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_animation.value.toStringAsFixed(0)}%',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'RECOVERY SCORE',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.hintColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value; // 0 to 100
  final Color baseColor;

  _GaugePainter({
    required this.value,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 10;
    const strokeWidth = 14.0;

    // 1. Draw Background Track
    final trackPaint = Paint()
      ..color = baseColor.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // 2. Draw Progress Arc
    final double sweepAngle = 2 * pi * (value / 100.0);
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          baseColor.withOpacity(0.6),
          baseColor,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    // Rotate sweep arc to start from the top (-pi/2)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.baseColor != baseColor;
  }
}
