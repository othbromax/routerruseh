import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/animation.dart';
import 'package:route_rush/game/route_rush_game.dart';

class DeliveryAnimation extends PositionComponent
    with HasGameReference<RouteRushGame> {
  double _timer = 0;
  static const double _duration = 1.8;

  final Paint _packagePaint = Paint()..color = const Color(0xFF8B6914);
  final Paint _packageDark = Paint()..color = const Color(0xFF6B4E00);
  final Paint _tapePaint = Paint()..color = const Color(0xFFF4C430);
  final Paint _checkPaint = Paint()
    ..color = const Color(0xFF39FF14)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.5;
  final Paint _glowPaint = Paint()..color = const Color(0x3339FF14);
  final Paint _starPaint = Paint()..color = const Color(0xAAFFD700);

  final VoidCallback onComplete;

  DeliveryAnimation({
    required super.position,
    required this.onComplete,
  }) : super(
          size: Vector2(80, 80),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    if (_timer >= _duration) {
      onComplete();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final w = size.x;
    final h = size.y;
    final cx = w / 2;
    final cy = h / 2;

    final phase = (_timer / _duration).clamp(0.0, 1.0);

    if (phase < 0.5) {
      // Phase 1: Package drops in and lands
      final dropProgress = (phase / 0.5).clamp(0.0, 1.0);
      final eased = Curves.bounceOut.transform(dropProgress);
      final yOffset = -40.0 * (1 - eased);
      final scale = 0.5 + 0.5 * eased;
      final opacity = dropProgress.clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(cx, cy + yOffset);
      canvas.scale(scale);
      canvas.translate(-cx, -cy);

      _packagePaint.color = Color.fromARGB(
        (255 * opacity).toInt(), 0x8B, 0x69, 0x14,
      );

      // Package box
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.2, h * 0.25, w * 0.6, h * 0.5),
          const Radius.circular(3),
        ),
        _packagePaint,
      );
      // Box flap shadow
      canvas.drawRect(
        Rect.fromLTWH(w * 0.2, h * 0.25, w * 0.6, h * 0.1),
        _packageDark,
      );
      // Tape cross
      canvas.drawRect(
        Rect.fromLTWH(w * 0.46, h * 0.25, w * 0.08, h * 0.5),
        _tapePaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(w * 0.2, h * 0.44, w * 0.6, h * 0.08),
        _tapePaint,
      );

      canvas.restore();
    } else {
      // Phase 2: Checkmark appears with star burst
      final checkProgress = ((phase - 0.5) / 0.5).clamp(0.0, 1.0);

      // Fading package
      final packageAlpha = (1 - checkProgress * 0.7).clamp(0.0, 1.0);
      _packagePaint.color = Color.fromARGB(
        (255 * packageAlpha).toInt(), 0x8B, 0x69, 0x14,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.2, h * 0.25, w * 0.6, h * 0.5),
          const Radius.circular(3),
        ),
        _packagePaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(w * 0.46, h * 0.25, w * 0.08, h * 0.5),
        _tapePaint..color = Color.fromARGB((255 * packageAlpha).toInt(), 0xF4, 0xC4, 0x30),
      );

      // Green glow circle
      final glowRadius = w * 0.5 * checkProgress;
      _glowPaint.color = Color.fromARGB(
        (51 * checkProgress).toInt(), 0x39, 0xFF, 0x14,
      );
      canvas.drawCircle(Offset(cx, cy), glowRadius, _glowPaint);

      // Checkmark
      if (checkProgress > 0.2) {
        final checkAlpha = ((checkProgress - 0.2) / 0.8).clamp(0.0, 1.0);
        _checkPaint.color = Color.fromARGB(
          (255 * checkAlpha).toInt(), 0x39, 0xFF, 0x14,
        );

        final checkPath = Path()
          ..moveTo(cx - w * 0.18, cy)
          ..lineTo(cx - w * 0.04, cy + h * 0.14)
          ..lineTo(cx + w * 0.20, cy - h * 0.12);
        canvas.drawPath(checkPath, _checkPaint);
      }

      // Star burst particles
      if (checkProgress > 0.3) {
        final starAlpha = ((1 - checkProgress) * 2).clamp(0.0, 1.0);
        _starPaint.color = Color.fromARGB(
          (170 * starAlpha).toInt(), 0xFF, 0xD7, 0x00,
        );
        for (int i = 0; i < 8; i++) {
          final angle = i * pi / 4 + checkProgress * 0.5;
          final dist = w * 0.3 * checkProgress + 8;
          final sx = cx + cos(angle) * dist;
          final sy = cy + sin(angle) * dist;
          canvas.drawCircle(Offset(sx, sy), 3, _starPaint);
        }
      }
    }
  }
}
