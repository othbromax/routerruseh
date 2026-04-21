import 'dart:math';

import 'package:flame/components.dart';
import 'package:route_rush/data/route_data.dart';
import 'package:route_rush/game/components/obstacle.dart';
import 'package:route_rush/game/components/road_background.dart';

class ObstacleSpawner extends Component with HasGameReference {
  final RoadBackground road;
  final Random _random = Random();

  double _spawnTimer = 0;
  double spawnInterval = 1.5;
  double obstacleSpeed = 300;
  List<HazardType> availableHazards = [HazardType.pothole];

  ObstacleSpawner({required this.road});

  void configure({
    required double interval,
    required double speed,
    required List<HazardType> hazards,
  }) {
    spawnInterval = interval;
    obstacleSpeed = speed;
    availableHazards = hazards;
  }

  void reset() {
    _spawnTimer = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _spawnTimer += dt;
    if (_spawnTimer >= spawnInterval) {
      _spawnTimer = 0;
      _spawnObstacle();
    }
  }

  void _spawnObstacle() {
    // Safety rule: pick lanes to occupy, always leaving at least one clear
    final maxOccupied = RoadBackground.laneCount - 1;
    final occupiedCount = _random.nextInt(maxOccupied) + 1;

    final lanes = List.generate(RoadBackground.laneCount, (i) => i);
    lanes.shuffle(_random);
    final chosenLanes = lanes.take(occupiedCount);

    for (final lane in chosenLanes) {
      final double x = road.getLaneCenter(lane);
      final double y = -60.0;
      final hazardType = availableHazards[_random.nextInt(availableHazards.length)];

      final obstacle = _createObstacle(hazardType, Vector2(x, y), obstacleSpeed);
      game.world.add(obstacle);
    }
  }

  Obstacle _createObstacle(HazardType type, Vector2 position, double speed) {
    switch (type) {
      case HazardType.pothole:
        return Pothole(position: position, speed: speed);
      case HazardType.nailsGlass:
        return NailsGlass(position: position, speed: speed);
      case HazardType.barricade:
        return Barricade(position: position, speed: speed);
      case HazardType.oilSpill:
        return OilSpill(position: position, speed: speed);
      case HazardType.trafficCone:
        return TrafficCone(position: position, speed: speed);
    }
  }
}
