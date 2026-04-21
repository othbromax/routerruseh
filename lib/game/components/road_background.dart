import 'dart:ui';

import 'package:flame/components.dart';

class RoadBackground extends PositionComponent with HasGameReference {
  static const double roadWidthRatio = 0.75;
  static const int laneCount = 3;

  late double roadWidth;
  late double roadLeft;
  late double laneWidth;

  double _scrollOffset = 0;
  double scrollSpeed = 300;

  final Paint _asphaltPaint = Paint()..color = const Color(0xFF2A2B2E);
  final Paint _shoulderPaint = Paint()..color = const Color(0xFF1A1A1A);
  final Paint _lanePaint = Paint()
    ..color = const Color(0xFFD9D9D9)
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke;
  final Paint _edgePaint = Paint()
    ..color = const Color(0xFFF4C430)
    ..strokeWidth = 4;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = game.size;
    _calculateDimensions();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _calculateDimensions();
  }

  void _calculateDimensions() {
    roadWidth = size.x * roadWidthRatio;
    roadLeft = (size.x - roadWidth) / 2;
    laneWidth = roadWidth / laneCount;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _scrollOffset += scrollSpeed * dt;
    _scrollOffset %= 80;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRect(size.toRect(), _shoulderPaint);

    canvas.drawRect(
      Rect.fromLTWH(roadLeft, 0, roadWidth, size.y),
      _asphaltPaint,
    );

    canvas.drawLine(
      Offset(roadLeft, 0),
      Offset(roadLeft, size.y),
      _edgePaint,
    );
    canvas.drawLine(
      Offset(roadLeft + roadWidth, 0),
      Offset(roadLeft + roadWidth, size.y),
      _edgePaint,
    );

    _drawLaneMarkings(canvas);
  }

  void _drawLaneMarkings(Canvas canvas) {
    const double dashLength = 40;
    const double gapLength = 40;
    final double totalDashCycle = dashLength + gapLength;

    for (int lane = 1; lane < laneCount; lane++) {
      final double x = roadLeft + lane * laneWidth;
      double y = -totalDashCycle + _scrollOffset;

      while (y < size.y) {
        final double startY = y;
        final double endY = y + dashLength;

        if (endY > 0 && startY < size.y) {
          canvas.drawLine(
            Offset(x, startY.clamp(0, size.y)),
            Offset(x, endY.clamp(0, size.y)),
            _lanePaint,
          );
        }
        y += totalDashCycle;
      }
    }
  }

  double getLaneCenter(int lane) {
    return roadLeft + lane * laneWidth + laneWidth / 2;
  }
}
