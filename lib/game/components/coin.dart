import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:route_rush/game/route_rush_game.dart';

class FuelCoin extends PositionComponent
    with CollisionCallbacks, HasGameReference<RouteRushGame> {
  static const double coinSize = 28;

  double speed;
  double _floatPhase;
  double _glowPhase;

  final Paint _outerPaint = Paint()..color = const Color(0xFFF4C430);
  final Paint _innerPaint = Paint()..color = const Color(0xFFFFD700);
  final Paint _corePaint = Paint()..color = const Color(0xFFFFF3B0);
  final Paint _shimmerPaint = Paint()..color = const Color(0x66FFFFFF);
  final Paint _outlinePaint = Paint()
    ..color = const Color(0xFFB8922E)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  final Paint _glowPaint = Paint()..color = const Color(0x22FFD700);

  // Fuel pump icon paints
  final Paint _iconPaint = Paint()
    ..color = const Color(0xFF6B4E00)
    ..style = PaintingStyle.fill;

  FuelCoin({required super.position, required this.speed})
      : _floatPhase = Random().nextDouble() * pi * 2,
        _glowPhase = Random().nextDouble() * pi * 2,
        super(
          size: Vector2.all(coinSize),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
    _floatPhase += dt * 3.0;
    _glowPhase += dt * 2.0;

    final viewportHeight = game.camera.viewport.size.y;
    if (position.y > viewportHeight + size.y) {
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
    final r = w / 2;

    final floatOffset = sin(_floatPhase) * 2.5;
    final glowScale = 1.0 + sin(_glowPhase) * 0.08;

    canvas.save();
    canvas.translate(0, floatOffset);

    // Outer glow pulse
    canvas.drawCircle(Offset(cx, cy), r * glowScale * 1.4, _glowPaint);

    // Main coin body
    canvas.drawCircle(Offset(cx, cy), r, _outerPaint);
    canvas.drawCircle(Offset(cx, cy), r * 0.82, _innerPaint);
    canvas.drawCircle(Offset(cx, cy), r * 0.55, _corePaint);

    // Fuel pump icon (small gas pump silhouette)
    final iconS = r * 0.5;
    final ix = cx - iconS * 0.4;
    final iy = cy - iconS * 0.5;
    // Pump body
    canvas.drawRect(
      Rect.fromLTWH(ix, iy + iconS * 0.2, iconS * 0.6, iconS * 0.8),
      _iconPaint,
    );
    // Pump nozzle
    canvas.drawRect(
      Rect.fromLTWH(ix + iconS * 0.6, iy + iconS * 0.3, iconS * 0.3, iconS * 0.15),
      _iconPaint,
    );
    // Pump handle
    canvas.drawRect(
      Rect.fromLTWH(ix + iconS * 0.15, iy, iconS * 0.3, iconS * 0.2),
      _iconPaint,
    );

    // Shimmer highlight
    final shimmerAngle = _glowPhase * 0.5;
    final shimmerX = cx + cos(shimmerAngle) * r * 0.3;
    final shimmerY = cy + sin(shimmerAngle) * r * 0.3 - r * 0.15;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(shimmerX, shimmerY), width: r * 0.5, height: r * 0.3),
      _shimmerPaint,
    );

    canvas.drawCircle(Offset(cx, cy), r, _outlinePaint);

    canvas.restore();
  }
}
