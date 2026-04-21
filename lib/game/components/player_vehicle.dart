import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:route_rush/game/components/coin.dart';
import 'package:route_rush/game/components/obstacle.dart';
import 'package:route_rush/game/route_rush_game.dart';

class PlayerVehicle extends PositionComponent
    with CollisionCallbacks, HasGameReference<RouteRushGame> {
  static const double vehicleWidth = 52;
  static const double vehicleHeight = 90;

  late double _minX;
  late double _maxX;

  double _driftForce = 0;
  double _driftTimer = 0;

  final Random _random = Random();

  // Delivery van body
  final Paint _bodyPaint = Paint()..color = const Color(0xFFD4A843);
  final Paint _bodyDarkPaint = Paint()..color = const Color(0xFFB8922E);
  final Paint _cargoPaint = Paint()..color = const Color(0xFFC49A2A);
  final Paint _cargoShadowPaint = Paint()..color = const Color(0xFFA07E20);
  // Cab & windshield
  final Paint _windshieldPaint = Paint()..color = const Color(0xFF7BC8F6);
  final Paint _windshieldGlarePaint = Paint()..color = const Color(0xAABDE8FF);
  // Metal & chrome
  final Paint _bumperPaint = Paint()..color = const Color(0xFF6E6E6E);
  final Paint _bumperHighlightPaint = Paint()..color = const Color(0xFF9A9A9A);
  final Paint _grillPaint = Paint()..color = const Color(0xFF444444);
  // Lights
  final Paint _headlightPaint = Paint()..color = const Color(0xFFFFF3B0);
  final Paint _headlightGlowPaint = Paint()..color = const Color(0x55FFF3B0);
  final Paint _taillightPaint = Paint()..color = const Color(0xFFFF2222);
  final Paint _taillightGlowPaint = Paint()..color = const Color(0x44FF2222);
  // Wheels & details
  final Paint _wheelPaint = Paint()..color = const Color(0xFF1A1A1A);
  final Paint _hubcapPaint = Paint()..color = const Color(0xFF888888);
  final Paint _outlinePaint = Paint()
    ..color = const Color(0xFF3A3020)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;
  // Side mirror
  final Paint _mirrorPaint = Paint()..color = const Color(0xFF888888);
  // Rust/wear accent
  final Paint _rustPaint = Paint()..color = const Color(0x33704020);

  PlayerVehicle() : super(
    size: Vector2(vehicleWidth, vehicleHeight),
    anchor: Anchor.center,
  );

  void setBounds(double minX, double maxX) {
    _minX = minX + size.x / 2;
    _maxX = maxX - size.x / 2;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  void moveHorizontally(double deltaX) {
    position.x = (position.x + deltaX).clamp(_minX, _maxX);
  }

  void applyFlatTireDrift(double durationSeconds) {
    _driftTimer = durationSeconds;
    _driftForce = (_random.nextBool() ? 1 : -1) * 80.0;
  }

  void resetEffects() {
    _driftForce = 0;
    _driftTimer = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_driftTimer > 0) {
      _driftTimer -= dt;
      position.x = (position.x + _driftForce * dt).clamp(_minX, _maxX);
      if (_driftTimer <= 0) {
        _driftForce = 0;
      }
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Obstacle) {
      game.onHazardHit(other.hazardType);
      other.removeFromParent();
    } else if (other is FuelCoin) {
      game.onCoinCollected();
      other.removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final double w = size.x;
    final double h = size.y;

    // Rear wheels (behind body)
    _drawWheel(canvas, w * 0.02, h * 0.70, w * 0.14, h * 0.12);
    _drawWheel(canvas, w * 0.84, h * 0.70, w * 0.14, h * 0.12);

    // Front wheels
    _drawWheel(canvas, w * 0.04, h * 0.12, w * 0.12, h * 0.11);
    _drawWheel(canvas, w * 0.84, h * 0.12, w * 0.12, h * 0.11);

    // Drop shadow under body
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(w * 0.10, h * 0.04, w * 0.82, h * 0.94),
        topLeft: const Radius.circular(5),
        topRight: const Radius.circular(5),
        bottomLeft: const Radius.circular(3),
        bottomRight: const Radius.circular(3),
      ),
      Paint()..color = const Color(0x22000000),
    );

    // -- Cargo box (rear body) --
    final cargoRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(w * 0.12, h * 0.36, w * 0.76, h * 0.56),
      bottomLeft: const Radius.circular(2),
      bottomRight: const Radius.circular(2),
    );
    canvas.drawRRect(cargoRect, _cargoPaint);
    // Shadow stripe on cargo
    canvas.drawRect(
      Rect.fromLTWH(w * 0.12, h * 0.36, w * 0.76, h * 0.06),
      _cargoShadowPaint,
    );
    // Cargo door lines
    canvas.drawLine(
      Offset(w * 0.50, h * 0.80),
      Offset(w * 0.50, h * 0.92),
      _outlinePaint,
    );
    // Cargo door handles
    canvas.drawRect(
      Rect.fromCenter(center: Offset(w * 0.44, h * 0.86), width: 3, height: 6),
      _bumperPaint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(w * 0.56, h * 0.86), width: 3, height: 6),
      _bumperPaint,
    );
    canvas.drawRRect(cargoRect, _outlinePaint);

    // Rust patches
    canvas.drawOval(Rect.fromLTWH(w * 0.60, h * 0.65, w * 0.18, h * 0.08), _rustPaint);
    canvas.drawOval(Rect.fromLTWH(w * 0.15, h * 0.50, w * 0.12, h * 0.06), _rustPaint);

    // -- Cab section --
    final cabRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(w * 0.12, h * 0.08, w * 0.76, h * 0.32),
      topLeft: const Radius.circular(6),
      topRight: const Radius.circular(6),
      bottomLeft: const Radius.circular(1),
      bottomRight: const Radius.circular(1),
    );
    canvas.drawRRect(cabRect, _bodyPaint);
    // Darker cab lower half
    canvas.drawRect(
      Rect.fromLTWH(w * 0.12, h * 0.28, w * 0.76, h * 0.12),
      _bodyDarkPaint,
    );
    canvas.drawRRect(cabRect, _outlinePaint);

    // Windshield
    final windshieldPath = Path()
      ..moveTo(w * 0.20, h * 0.12)
      ..lineTo(w * 0.80, h * 0.12)
      ..lineTo(w * 0.78, h * 0.26)
      ..lineTo(w * 0.22, h * 0.26)
      ..close();
    canvas.drawPath(windshieldPath, _windshieldPaint);
    // Windshield glare
    final glarePath = Path()
      ..moveTo(w * 0.24, h * 0.13)
      ..lineTo(w * 0.44, h * 0.13)
      ..lineTo(w * 0.40, h * 0.20)
      ..lineTo(w * 0.26, h * 0.22)
      ..close();
    canvas.drawPath(glarePath, _windshieldGlarePaint);
    // Windshield divider
    canvas.drawLine(
      Offset(w * 0.50, h * 0.12),
      Offset(w * 0.50, h * 0.26),
      _outlinePaint,
    );
    canvas.drawPath(windshieldPath, _outlinePaint);

    // -- Front bumper & grill --
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.10, h * 0.02, w * 0.80, h * 0.08),
        const Radius.circular(3),
      ),
      _bumperPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.02, w * 0.76, h * 0.03),
        const Radius.circular(1),
      ),
      _bumperHighlightPaint,
    );
    // Grill slats
    for (double gx = w * 0.30; gx <= w * 0.68; gx += 5) {
      canvas.drawLine(
        Offset(gx, h * 0.055),
        Offset(gx, h * 0.085),
        _grillPaint..strokeWidth = 1.5,
      );
    }
    _grillPaint.style = PaintingStyle.fill;

    // Headlights with glow
    canvas.drawOval(
      Rect.fromLTWH(w * 0.12, h * 0.03, w * 0.14, h * 0.05),
      _headlightGlowPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.14, h * 0.035, w * 0.10, h * 0.04),
      _headlightPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.74, h * 0.03, w * 0.14, h * 0.05),
      _headlightGlowPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.76, h * 0.035, w * 0.10, h * 0.04),
      _headlightPaint,
    );

    // -- Rear bumper --
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.91, w * 0.76, h * 0.06),
        const Radius.circular(2),
      ),
      _bumperPaint,
    );

    // Taillights with glow
    canvas.drawRect(
      Rect.fromLTWH(w * 0.14, h * 0.915, w * 0.10, h * 0.04),
      _taillightGlowPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.15, h * 0.92, w * 0.08, h * 0.03),
      _taillightPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.76, h * 0.915, w * 0.10, h * 0.04),
      _taillightGlowPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.77, h * 0.92, w * 0.08, h * 0.03),
      _taillightPaint,
    );

    // Side mirrors
    canvas.drawOval(
      Rect.fromLTWH(w * 0.02, h * 0.18, w * 0.12, h * 0.06),
      _mirrorPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.86, h * 0.18, w * 0.12, h * 0.06),
      _mirrorPaint,
    );

    // "DELIVERY" text stripe on cargo side
    canvas.drawRect(
      Rect.fromLTWH(w * 0.20, h * 0.56, w * 0.60, h * 0.08),
      Paint()..color = const Color(0xFF8B6914),
    );
  }

  void _drawWheel(Canvas canvas, double x, double y, double ww, double wh) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, ww, wh), const Radius.circular(3)),
      _wheelPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x + ww / 2, y + wh / 2), width: ww * 0.45, height: wh * 0.45),
      _hubcapPaint,
    );
  }
}
