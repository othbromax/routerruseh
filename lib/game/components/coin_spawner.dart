import 'dart:math';

import 'package:flame/components.dart';
import 'package:route_rush/game/components/coin.dart';
import 'package:route_rush/game/components/road_background.dart';

class CoinSpawner extends Component with HasGameReference {
  final RoadBackground road;
  final Random _random = Random();

  double _spawnTimer = 0;
  double spawnInterval = 3.0;
  double coinSpeed = 300;

  CoinSpawner({required this.road});

  void configure({
    required double interval,
    required double speed,
  }) {
    spawnInterval = interval;
    coinSpeed = speed;
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
      _spawnCoin();
    }
  }

  void _spawnCoin() {
    final lane = _random.nextInt(RoadBackground.laneCount);
    final double x = road.getLaneCenter(lane);
    final double y = -40.0;

    final coin = FuelCoin(
      position: Vector2(x, y),
      speed: coinSpeed,
    );
    game.world.add(coin);
  }
}
