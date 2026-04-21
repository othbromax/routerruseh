import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:route_rush/data/route_data.dart';
import 'package:route_rush/game/route_rush_game.dart';

abstract class Obstacle extends PositionComponent
    with CollisionCallbacks, HasGameReference<RouteRushGame> {
  double speed;
  final HazardType hazardType;

  Obstacle({
    required super.position,
    required this.speed,
    required super.size,
    required this.hazardType,
  }) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;

    final viewportHeight = game.camera.viewport.size.y;
    if (position.y > viewportHeight + size.y) {
      removeFromParent();
    }
  }
}

// --- Pothole: dark jagged crater ---
class Pothole extends Obstacle {
  static const double _width = 55;
  static const double _height = 35;

  final Paint _craterPaint = Paint()..color = const Color(0xFF1A1A1A);
  final Paint _rimPaint = Paint()..color = const Color(0xFF3A3A3A);
  final Paint _innerPaint = Paint()..color = const Color(0xFF0D0D0D);
  final Paint _cracksP = Paint()
    ..color = const Color(0xFF4A4A4A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  Pothole({required super.position, required super.speed})
      : super(
          size: Vector2(_width, _height),
          hazardType: HazardType.pothole,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final w = size.x;
    final h = size.y;

    canvas.drawOval(Rect.fromLTWH(0, 0, w, h), _rimPaint);
    canvas.drawOval(Rect.fromLTWH(w * 0.08, h * 0.08, w * 0.84, h * 0.84), _craterPaint);
    canvas.drawOval(Rect.fromLTWH(w * 0.25, h * 0.25, w * 0.5, h * 0.5), _innerPaint);
    // Crack lines radiating from crater
    canvas.drawLine(Offset(w * 0.1, h * 0.2), Offset(-w * 0.05, h * 0.0), _cracksP);
    canvas.drawLine(Offset(w * 0.85, h * 0.3), Offset(w * 1.05, h * 0.1), _cracksP);
    canvas.drawLine(Offset(w * 0.5, h * 0.9), Offset(w * 0.5, h * 1.05), _cracksP);
  }
}

// --- Nails & Glass: scattered debris ---
class NailsGlass extends Obstacle {
  static const double _width = 50;
  static const double _height = 30;

  final Paint _debrisPaint = Paint()..color = const Color(0xFFD9D9D9);
  final Paint _glintPaint = Paint()..color = const Color(0xFFFFFFFF);
  final Paint _basePaint = Paint()..color = const Color(0xFF555555);

  NailsGlass({required super.position, required super.speed})
      : super(
          size: Vector2(_width, _height),
          hazardType: HazardType.nailsGlass,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final w = size.x;
    final h = size.y;

    canvas.drawOval(Rect.fromLTWH(0, h * 0.2, w, h * 0.6), _basePaint);

    final shardPositions = [
      Offset(w * 0.15, h * 0.3),
      Offset(w * 0.35, h * 0.5),
      Offset(w * 0.55, h * 0.25),
      Offset(w * 0.7, h * 0.55),
      Offset(w * 0.85, h * 0.35),
      Offset(w * 0.25, h * 0.65),
      Offset(w * 0.6, h * 0.7),
    ];
    for (final pos in shardPositions) {
      canvas.drawRect(Rect.fromCenter(center: pos, width: 4, height: 4), _debrisPaint);
    }

    final glintPositions = [
      Offset(w * 0.2, h * 0.4),
      Offset(w * 0.5, h * 0.35),
      Offset(w * 0.75, h * 0.45),
    ];
    for (final pos in glintPositions) {
      canvas.drawCircle(pos, 2, _glintPaint);
    }
  }
}

// --- Barricade: concrete barrier with warning stripes ---
class Barricade extends Obstacle {
  static const double _width = 60;
  static const double _height = 45;

  final Paint _concretePaint = Paint()..color = const Color(0xFF888888);
  final Paint _stripePaint = Paint()..color = const Color(0xFFF4C430);
  final Paint _darkPaint = Paint()..color = const Color(0xFFD10000);
  final Paint _borderPaint = Paint()
    ..color = const Color(0xFF555555)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  Barricade({required super.position, required super.speed})
      : super(
          size: Vector2(_width, _height),
          hazardType: HazardType.barricade,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final w = size.x;
    final h = size.y;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _concretePaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _borderPaint);

    const int stripeCount = 5;
    final stripeWidth = w / stripeCount;
    for (int i = 0; i < stripeCount; i++) {
      if (i.isEven) {
        canvas.drawRect(
          Rect.fromLTWH(i * stripeWidth, h * 0.2, stripeWidth, h * 0.6),
          _darkPaint,
        );
      } else {
        canvas.drawRect(
          Rect.fromLTWH(i * stripeWidth, h * 0.2, stripeWidth, h * 0.6),
          _stripePaint,
        );
      }
    }
  }
}

// --- Oil Spill: dark iridescent puddle that causes uncontrolled sliding ---
class OilSpill extends Obstacle {
  static const double _width = 60;
  static const double _height = 40;

  double _shimmerPhase = 0;
  final Random _random = Random();

  final Paint _oilBase = Paint()..color = const Color(0xDD0A0A0A);
  final Paint _oilSheen1 = Paint()..color = const Color(0x33663399);
  final Paint _oilSheen2 = Paint()..color = const Color(0x22228B22);
  final Paint _oilEdge = Paint()
    ..color = const Color(0xFF1A1A1A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  OilSpill({required super.position, required super.speed})
      : super(
          size: Vector2(_width, _height),
          hazardType: HazardType.oilSpill,
        ) {
    _shimmerPhase = _random.nextDouble() * 3.14;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _shimmerPhase += dt * 2.5;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final w = size.x;
    final h = size.y;

    // Irregular puddle shape
    final puddlePath = Path()
      ..moveTo(w * 0.15, h * 0.35)
      ..cubicTo(w * 0.0, h * 0.1, w * 0.4, h * -0.05, w * 0.6, h * 0.1)
      ..cubicTo(w * 0.85, h * 0.2, w * 1.05, h * 0.45, w * 0.85, h * 0.7)
      ..cubicTo(w * 0.7, h * 0.95, w * 0.35, h * 1.05, w * 0.2, h * 0.8)
      ..cubicTo(w * 0.0, h * 0.65, w * 0.05, h * 0.5, w * 0.15, h * 0.35)
      ..close();

    canvas.drawPath(puddlePath, _oilBase);

    // Animated rainbow sheen
    final sheenOffset = sin(_shimmerPhase) * 0.15;
    canvas.drawOval(
      Rect.fromLTWH(w * (0.2 + sheenOffset), h * 0.2, w * 0.4, h * 0.35),
      _oilSheen1,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * (0.35 - sheenOffset), h * 0.4, w * 0.35, h * 0.3),
      _oilSheen2,
    );

    canvas.drawPath(puddlePath, _oilEdge);
  }
}

// --- Traffic Cone: orange cone obstacle that bounces the player ---
class TrafficCone extends Obstacle {
  static const double _width = 30;
  static const double _height = 42;

  final Paint _conePaint = Paint()..color = const Color(0xFFFF5A00);
  final Paint _coneDark = Paint()..color = const Color(0xFFCC4800);
  final Paint _stripePaint = Paint()..color = const Color(0xFFFFFFFF);
  final Paint _basePaint = Paint()..color = const Color(0xFF333333);
  final Paint _outlinePaint = Paint()
    ..color = const Color(0xFF882200)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  TrafficCone({required super.position, required super.speed})
      : super(
          size: Vector2(_width, _height),
          hazardType: HazardType.trafficCone,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final w = size.x;
    final h = size.y;

    // Base plate
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.05, h * 0.82, w * 0.9, h * 0.16),
        const Radius.circular(2),
      ),
      _basePaint,
    );

    // Cone body (trapezoid)
    final conePath = Path()
      ..moveTo(w * 0.42, h * 0.02)
      ..lineTo(w * 0.58, h * 0.02)
      ..lineTo(w * 0.85, h * 0.82)
      ..lineTo(w * 0.15, h * 0.82)
      ..close();
    canvas.drawPath(conePath, _conePaint);

    // Darker right side for 3D effect
    final shadePath = Path()
      ..moveTo(w * 0.50, h * 0.02)
      ..lineTo(w * 0.58, h * 0.02)
      ..lineTo(w * 0.85, h * 0.82)
      ..lineTo(w * 0.50, h * 0.82)
      ..close();
    canvas.drawPath(shadePath, _coneDark);

    // White reflective stripes
    canvas.drawRect(
      Rect.fromLTWH(w * 0.28, h * 0.28, w * 0.44, h * 0.08),
      _stripePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.20, h * 0.55, w * 0.60, h * 0.08),
      _stripePaint,
    );

    // Cone tip
    canvas.drawCircle(Offset(w * 0.50, h * 0.04), w * 0.08, _coneDark);

    canvas.drawPath(conePath, _outlinePaint);
  }
}
