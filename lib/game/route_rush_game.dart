import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';

import 'package:route_rush/data/game_state.dart';
import 'package:route_rush/data/route_data.dart';
import 'package:route_rush/game/audio_manager.dart';
import 'package:route_rush/game/components/coin.dart';
import 'package:route_rush/game/components/coin_spawner.dart';
import 'package:route_rush/game/components/delivery_animation.dart';
import 'package:route_rush/game/components/obstacle.dart';
import 'package:route_rush/game/components/obstacle_spawner.dart';
import 'package:route_rush/game/components/player_vehicle.dart';
import 'package:route_rush/game/components/road_background.dart';

class RouteRushGame extends FlameGame
    with PanDetector, HasCollisionDetection {
  late RoadBackground road;
  late PlayerVehicle player;
  late ObstacleSpawner spawner;
  late CoinSpawner coinSpawner;

  GameState? gameState;
  AudioManager? audioManager;

  double _baseScrollSpeed = 300;
  double _currentSpeedMultiplier = 1.0;
  double _reducedSpeedMultiplier = 1.0;
  double _speedRecoveryTimer = 0;
  bool _isSpeedReduced = false;

  double _distanceTraveled = 0;
  double _deadlineProgress = 0;
  double _targetDistance = 1000;
  double _deadlineFillRate = 0.02;

  // Camera shake state
  double _shakeTimer = 0;
  double _shakeIntensity = 0;
  final Random _random = Random();

  // Camera jolt state
  double _joltTimer = 0;
  Vector2 _joltOffset = Vector2.zero();

  // Oil spill slide state
  double _oilSlideTimer = 0;
  double _oilSlideForce = 0;

  bool _isRunning = false;
  bool _deadlineWarningPlayed = false;
  bool _isPlayingDeliveryAnimation = false;

  int _requiredCoins = 0;

  double get distanceTraveled => _distanceTraveled;
  double get deadlineProgress => _deadlineProgress;
  double get targetDistance => _targetDistance;

  @override
  Color backgroundColor() => const Color(0xFF121212);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;

    road = RoadBackground();
    world.add(road);

    player = PlayerVehicle();
    world.add(player);

    spawner = ObstacleSpawner(road: road);
    world.add(spawner);

    coinSpawner = CoinSpawner(road: road);
    world.add(coinSpawner);
  }

  @override
  void onMount() {
    super.onMount();
    _positionPlayer();
  }

  void startRun(RouteDefinition routeDef) {
    _targetDistance = routeDef.targetDistance;
    _deadlineFillRate = routeDef.deadlineFillRate;
    _baseScrollSpeed = routeDef.obstacleSpeed;
    _requiredCoins = routeDef.requiredCoins;

    // Apply engine upgrade speed multiplier
    if (gameState != null) {
      final engineLevel = gameState!.getUpgradeLevel('engine');
      if (engineLevel > 0) {
        final engineUpgrade = allUpgrades.firstWhere((u) => u.id == 'engine');
        final tier = engineUpgrade.tiers[engineLevel - 1];
        _baseScrollSpeed *= tier.effectValue;
      }

      gameState!.setFuelCoinsRequired(_requiredCoins);
    }

    road.scrollSpeed = _baseScrollSpeed;
    _currentSpeedMultiplier = 1.0;
    _reducedSpeedMultiplier = 1.0;
    _isSpeedReduced = false;
    _speedRecoveryTimer = 0;

    _oilSlideTimer = 0;
    _oilSlideForce = 0;

    _distanceTraveled = 0;
    _deadlineProgress = 0;

    _shakeTimer = 0;
    _joltTimer = 0;

    spawner.configure(
      interval: routeDef.spawnInterval,
      speed: routeDef.obstacleSpeed,
      hazards: routeDef.availableHazards,
    );
    spawner.reset();

    coinSpawner.configure(
      interval: routeDef.coinSpawnInterval,
      speed: routeDef.obstacleSpeed,
    );
    coinSpawner.reset();

    player.resetEffects();
    _positionPlayer();

    _removeAllObstacles();
    _removeAllCoins();

    _deadlineWarningPlayed = false;
    _isPlayingDeliveryAnimation = false;
    _isRunning = true;
  }

  void stopRun() {
    _isRunning = false;
  }

  void _removeAllObstacles() {
    final toRemove = world.children.whereType<Obstacle>().toList();
    for (final obs in toRemove) {
      obs.removeFromParent();
    }
  }

  void _removeAllCoins() {
    final toRemove = world.children.whereType<FuelCoin>().toList();
    for (final c in toRemove) {
      c.removeFromParent();
    }
  }

  void _applySpeedMultiplierToObstacles(double multiplier) {
    final baseObstacleSpeed = spawner.obstacleSpeed;
    for (final obs in world.children.whereType<Obstacle>()) {
      obs.speed = baseObstacleSpeed * multiplier;
    }
  }

  void onCoinCollected() {
    if (!_isRunning || gameState == null) return;
    gameState!.collectFuelCoin();
    audioManager?.playUiTap();
    _triggerHaptic(HapticFeedback.lightImpact);
  }

  void onHazardHit(HazardType type) {
    if (!_isRunning || gameState == null) return;

    gameState!.incrementHazardsHit();

    switch (type) {
      case HazardType.pothole:
        _applyPotholeEffect();
      case HazardType.nailsGlass:
        _applyNailsGlassEffect();
      case HazardType.barricade:
        _applyBarricadeEffect();
      case HazardType.oilSpill:
        _applyOilSpillEffect();
      case HazardType.trafficCone:
        _applyTrafficConeEffect();
    }
  }

  void _applyDeadlinePenalty(double amount) {
    _deadlineProgress += amount;
    _deadlineProgress = _deadlineProgress.clamp(0.0, 1.0);
    gameState?.setDeadlineRemaining(1.0 - _deadlineProgress);
  }

  void _applyPotholeEffect() {
    double speedPenalty = 0.40;
    if (gameState != null) {
      final suspLevel = gameState!.getUpgradeLevel('suspension');
      if (suspLevel > 0) {
        final suspUpgrade = allUpgrades.firstWhere((u) => u.id == 'suspension');
        speedPenalty = suspUpgrade.tiers[suspLevel - 1].effectValue;
      }
    }

    _reducedSpeedMultiplier = 1.0 - speedPenalty;
    _currentSpeedMultiplier = _reducedSpeedMultiplier;
    _isSpeedReduced = true;
    _speedRecoveryTimer = 0;

    road.scrollSpeed = _baseScrollSpeed * _currentSpeedMultiplier;
    _applySpeedMultiplierToObstacles(_currentSpeedMultiplier);

    _applyDeadlinePenalty(0.04);

    _joltTimer = 0.15;
    _joltOffset = Vector2(0, -8);

    audioManager?.playPotholeCrunch();
    _triggerHaptic(HapticFeedback.mediumImpact);
  }

  void _applyNailsGlassEffect() {
    double driftDuration = 4.0;
    if (gameState != null) {
      final tiresLevel = gameState!.getUpgradeLevel('tires');
      if (tiresLevel > 0) {
        final tiresUpgrade = allUpgrades.firstWhere((u) => u.id == 'tires');
        driftDuration = tiresUpgrade.tiers[tiresLevel - 1].effectValue;
      }
    }

    player.applyFlatTireDrift(driftDuration);
    _applyDeadlinePenalty(0.03);

    audioManager?.playNailsPop();
    _triggerHaptic(HapticFeedback.lightImpact);
  }

  void _applyBarricadeEffect() {
    gameState!.loseLife();
    _applyDeadlinePenalty(0.06);

    _shakeTimer = 0.3;
    _shakeIntensity = 6;

    audioManager?.playBarricadeCrash();
    _triggerHaptic(HapticFeedback.heavyImpact);

    if (gameState!.lives <= 0) {
      _endRun(GameOverReason.wrecked);
    }
  }

  void _applyOilSpillEffect() {
    _oilSlideTimer = 2.0;
    _oilSlideForce = (_random.nextBool() ? 1 : -1) * 120.0;

    _reducedSpeedMultiplier = 0.75;
    _currentSpeedMultiplier = _reducedSpeedMultiplier;
    _isSpeedReduced = true;
    _speedRecoveryTimer = 0;

    road.scrollSpeed = _baseScrollSpeed * _currentSpeedMultiplier;
    _applySpeedMultiplierToObstacles(_currentSpeedMultiplier);

    _applyDeadlinePenalty(0.05);

    _joltTimer = 0.1;
    _joltOffset = Vector2(6, 0);

    audioManager?.playPotholeCrunch();
    _triggerHaptic(HapticFeedback.mediumImpact);
  }

  void _applyTrafficConeEffect() {
    _reducedSpeedMultiplier = 0.80;
    _currentSpeedMultiplier = _reducedSpeedMultiplier;
    _isSpeedReduced = true;
    _speedRecoveryTimer = 0;

    road.scrollSpeed = _baseScrollSpeed * _currentSpeedMultiplier;
    _applySpeedMultiplierToObstacles(_currentSpeedMultiplier);

    _applyDeadlinePenalty(0.02);

    _joltTimer = 0.1;
    _joltOffset = Vector2(0, -4);

    audioManager?.playUiTap();
    _triggerHaptic(HapticFeedback.lightImpact);
  }

  void _triggerHaptic(Future<void> Function() hapticMethod) {
    if (gameState?.vibrationEnabled ?? false) {
      hapticMethod();
    }
  }

  void _endRun(GameOverReason reason) {
    _isRunning = false;
    gameState!.setDistanceTraveled(_distanceTraveled);
    gameState!.setGameOverReason(reason);
    gameState!.setScreen(GameScreen.gameOver);
    audioManager?.playGameOver();
    _triggerHaptic(HapticFeedback.heavyImpact);
  }

  void completeRoute() {
    if (_isPlayingDeliveryAnimation) return;
    _isRunning = false;
    _isPlayingDeliveryAnimation = true;

    // Check if player collected enough fuel coins
    if (gameState != null && !gameState!.hasSufficientFuel) {
      gameState!.setDistanceTraveled(_distanceTraveled);
      gameState!.setGameOverReason(GameOverReason.outOfFuel);
      gameState!.setScreen(GameScreen.gameOver);
      audioManager?.playGameOver();
      _triggerHaptic(HapticFeedback.heavyImpact);
      _isPlayingDeliveryAnimation = false;
      return;
    }

    // Play delivery animation at the player's position
    final deliveryAnim = DeliveryAnimation(
      position: player.position.clone(),
      onComplete: () {
        _isPlayingDeliveryAnimation = false;
        gameState!.setDistanceTraveled(_distanceTraveled);
        gameState!.setScreen(GameScreen.routeComplete);
        audioManager?.playReceiptPrint();
      },
    );
    world.add(deliveryAnim);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isRunning) return;

    // Oil slide effect
    if (_oilSlideTimer > 0) {
      _oilSlideTimer -= dt;
      player.moveHorizontally(_oilSlideForce * dt);
      if (_oilSlideTimer <= 0) {
        _oilSlideForce = 0;
      }
    }

    // Speed recovery from pothole/oil/cone — lerp from reduced back to 1.0
    if (_isSpeedReduced) {
      _speedRecoveryTimer += dt;
      const recoveryDuration = 3.0;
      final t = (_speedRecoveryTimer / recoveryDuration).clamp(0.0, 1.0);
      _currentSpeedMultiplier = _reducedSpeedMultiplier + (1.0 - _reducedSpeedMultiplier) * t;
      road.scrollSpeed = _baseScrollSpeed * _currentSpeedMultiplier;
      _applySpeedMultiplierToObstacles(_currentSpeedMultiplier);
      if (t >= 1.0) {
        _isSpeedReduced = false;
        _currentSpeedMultiplier = 1.0;
        road.scrollSpeed = _baseScrollSpeed;
        _applySpeedMultiplierToObstacles(1.0);
      }
    }

    // Distance tracking
    _distanceTraveled += road.scrollSpeed * dt * 0.1;
    gameState?.setDistanceTraveled(_distanceTraveled);

    // Deadline tracking
    _deadlineProgress += _deadlineFillRate * dt;
    _deadlineProgress = _deadlineProgress.clamp(0, 1);
    gameState?.setDeadlineRemaining(1.0 - _deadlineProgress);

    if (_deadlineProgress >= 0.8 && !_deadlineWarningPlayed) {
      _deadlineWarningPlayed = true;
      audioManager?.playDeadlineWarning();
    }

    // Win condition
    if (_distanceTraveled >= _targetDistance) {
      completeRoute();
      return;
    }

    // Lose condition - deadline
    if (_deadlineProgress >= 1.0) {
      _endRun(GameOverReason.fired);
      return;
    }

    // Camera shake
    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
      final shakeX = (_random.nextDouble() - 0.5) * 2 * _shakeIntensity;
      final shakeY = (_random.nextDouble() - 0.5) * 2 * _shakeIntensity;
      camera.viewfinder.position = Vector2(shakeX, shakeY);
      if (_shakeTimer <= 0) {
        camera.viewfinder.position = Vector2.zero();
      }
    }

    // Camera jolt
    if (_joltTimer > 0) {
      _joltTimer -= dt;
      final t = (_joltTimer / 0.15).clamp(0.0, 1.0);
      camera.viewfinder.position = _joltOffset * t;
      if (_joltTimer <= 0) {
        camera.viewfinder.position = Vector2.zero();
      }
    }
  }

  void _positionPlayer() {
    final screenSize = camera.viewport.size;
    player.position = Vector2(
      screenSize.x / 2,
      screenSize.y * 0.8,
    );
    final roadLeft = (screenSize.x - screenSize.x * RoadBackground.roadWidthRatio) / 2;
    final roadRight = roadLeft + screenSize.x * RoadBackground.roadWidthRatio;
    player.setBounds(roadLeft, roadRight);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isMounted) {
      _positionPlayer();
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (_isRunning) {
      player.moveHorizontally(info.delta.global.x);
    }
  }
}
