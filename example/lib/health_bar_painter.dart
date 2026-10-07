import 'package:flutter/widgets.dart';

class HealthBarPainter {
  const HealthBarPainter();

  void paint(
    Canvas canvas, {
    required double health,
    required double maxHealth,
    required Size size,
    Offset offset = Offset.zero,
  }) {
    final percentage = (health / maxHealth).clamp(0.0, 1.0);

    canvas.drawRRect(
      RRect.fromRectAndRadius(offset & size, const .circular(8)),
      Paint()..color = const Color(0xFF333333),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          offset.dx,
          offset.dy,
          size.width * percentage,
          size.height,
        ),
        const .circular(8),
      ),
      Paint()..color = const Color(0xFF44DD44),
    );
  }
}
