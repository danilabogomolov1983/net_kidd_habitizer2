import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The Habitizer brand logo — a minimalist geometric mark
/// representing growth, consistency, and the upward spiral of habit-building.
final class AppLogo extends StatelessWidget {
  final double size;
  final double opacity;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 120,
    this.opacity = 1.0,
    this.color,
  });

  static const _blue = Color(0xFF0058A3);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = (color ?? _blue).withAlpha((255 * opacity).round());
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoPainter(color: effectiveColor),
        size: Size(size, size),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;

  _LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final r = w * 0.4; // outer radius

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Outer circle
    canvas.drawCircle(center, r, paint);

    // Inner arc — upward spiral / growth path
    final spiralPath = Path();
    const double startAngle = -2.2;
    const double sweepAngle = 4.4;
    final rect = Rect.fromCircle(center: center, radius: r * 0.58);
    spiralPath.addArc(rect, startAngle, sweepAngle);
    canvas.drawPath(spiralPath, paint..strokeWidth = w * 0.055);

    // Dot at the tip of the spiral (growth point)
    final dotAngle = startAngle + sweepAngle;
    final dotX = center.dx + (r * 0.58) * math.cos(dotAngle);
    final dotY = center.dy + (r * 0.58) * math.sin(dotAngle);
    canvas.drawCircle(Offset(dotX, dotY), w * 0.04, paint..style = PaintingStyle.fill);

    // Leaf / sprout accent at the top
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = w * 0.04;

    final sproutBase = Offset(center.dx, center.dy - r * 0.42);
    final sproutPath = Path()
      ..moveTo(sproutBase.dx, sproutBase.dy)
      ..quadraticBezierTo(
        sproutBase.dx + r * 0.32, sproutBase.dy - r * 0.48,
        sproutBase.dx + r * 0.14, sproutBase.dy - r * 0.42,
      );
    canvas.drawPath(sproutPath, paint);

    final sproutPath2 = Path()
      ..moveTo(sproutBase.dx, sproutBase.dy)
      ..quadraticBezierTo(
        sproutBase.dx - r * 0.32, sproutBase.dy - r * 0.48,
        sproutBase.dx - r * 0.14, sproutBase.dy - r * 0.42,
      );
    canvas.drawPath(sproutPath2, paint);
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => oldDelegate.color != color;
}
