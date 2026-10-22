import 'dart:math' as math;

import 'package:flutter/material.dart';

class ConfettiCelebration extends StatefulWidget {
  const ConfettiCelebration({super.key, this.duration = const Duration(seconds: 2)});

  final Duration duration;

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..forward();

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        painter: _ConfettiPainter(
          progress: _controller.value,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.tertiary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        size: Size.infinite,
      ),
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.progress, required this.colors});

  final double progress;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || progress >= 1) return;
    final paint = Paint();
    for (var index = 0; index < 36; index++) {
      final seed = index * 37;
      final startX = (seed % 101) / 100 * size.width;
      final drift = math.sin(progress * math.pi * 2 + index) * 18;
      final y = (progress * (size.height + 50) + seed % 70) % size.height;
      paint.color = colors[index % colors.length].withValues(
        alpha: 1 - progress,
      );
      canvas.save();
      canvas.translate(startX + drift, y);
      canvas.rotate(progress * 5 + index);
      canvas.drawRect(const Rect.fromLTWH(-3, -5, 6, 10), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.colors != colors;
}
