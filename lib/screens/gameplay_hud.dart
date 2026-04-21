import 'dart:math';

import 'package:flutter/material.dart';
import 'package:route_rush/data/dls.dart';
import 'package:route_rush/data/game_state.dart';
import 'package:route_rush/data/route_data.dart';

class GameplayHud extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onPause;

  const GameplayHud({
    super.key,
    required this.gameState,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    final routeDef = getRouteDefinition(gameState.currentRoute);

    return SafeArea(
      child: ListenableBuilder(
        listenable: gameState,
        builder: (context, _) {
          final deadlineProgress = 1.0 - gameState.deadlineRemaining;

          return Stack(
            children: [
              Positioned(
                top: AppSpacing.xs,
                left: 0,
                right: 0,
                child: _DistanceOdometer(
                  distance: gameState.distanceTraveled,
                  target: routeDef.targetDistance,
                ),
              ),
              Positioned(
                top: AppSpacing.xs,
                right: AppSpacing.sm,
                child: _PauseButton(onPressed: onPause),
              ),
              Positioned(
                bottom: AppSpacing.xl,
                left: AppSpacing.sm,
                child: _ChassisIntegrity(lives: gameState.lives),
              ),
              Positioned(
                bottom: AppSpacing.xl,
                left: 0,
                right: 0,
                child: Center(
                  child: _FuelGauge(
                    collected: gameState.fuelCoinsCollected,
                    required_: routeDef.requiredCoins,
                  ),
                ),
              ),
              Positioned(
                top: AppSpacing.xxl,
                right: AppSpacing.sm,
                bottom: AppSpacing.xl + 48,
                child: _DeadlineGauge(progress: deadlineProgress),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DistanceOdometer extends StatelessWidget {
  final double distance;
  final double target;

  const _DistanceOdometer({required this.distance, required this.target});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.scuffedBlack.withValues(alpha: 0.8),
          border: Border.all(color: AppColors.fadedRoadLineWhite.withValues(alpha: 0.3)),
        ),
        child: Text(
          '${distance.toInt()} / ${target.toInt()} m',
          style: AppTextStyles.body.copyWith(
            color: AppColors.hazardMustard,
            fontSize: 20,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PauseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.trafficConeOrange,
          border: Border.all(color: AppColors.hazardMustard, width: 2),
        ),
        child: const Center(
          child: Icon(Icons.warning_amber_rounded, color: AppColors.scuffedBlack, size: 28),
        ),
      ),
    );
  }
}

class _ChassisIntegrity extends StatelessWidget {
  final int lives;

  const _ChassisIntegrity({required this.lives});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.scuffedBlack.withValues(alpha: 0.8),
        border: Border.all(color: AppColors.fadedRoadLineWhite.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          final isActive = index < lives;
          return Padding(
            padding: EdgeInsets.only(left: index > 0 ? 6 : 0),
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.dashboardGreen : AppColors.scuffedBlack,
                border: Border.all(
                  color: isActive
                      ? AppColors.dashboardGreen.withValues(alpha: 0.5)
                      : AppColors.fadedRoadLineWhite.withValues(alpha: 0.2),
                  width: 2,
                ),
                boxShadow: isActive
                    ? [BoxShadow(color: AppColors.dashboardGreen.withValues(alpha: 0.4), blurRadius: 8)]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DeadlineGauge extends StatefulWidget {
  final double progress;

  const _DeadlineGauge({required this.progress});

  @override
  State<_DeadlineGauge> createState() => _DeadlineGaugeState();
}

class _DeadlineGaugeState extends State<_DeadlineGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _trembleController;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _trembleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && widget.progress >= 0.8) {
          _trembleController.forward(from: 0);
        }
      });
  }

  @override
  void didUpdateWidget(covariant _DeadlineGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress >= 0.8 && !_trembleController.isAnimating) {
      _trembleController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _trembleController.dispose();
    super.dispose();
  }

  Color _getGaugeColor() {
    if (widget.progress >= 0.9) return AppColors.brakeLightCrimson;
    if (widget.progress >= 0.7) return AppColors.hazardMustard;
    return AppColors.fadedRoadLineWhite;
  }

  @override
  Widget build(BuildContext context) {
    final gaugeColor = _getGaugeColor();

    return AnimatedBuilder(
      animation: _trembleController,
      builder: (context, child) {
        final trembleOffset = widget.progress >= 0.8
            ? Offset((_random.nextDouble() - 0.5) * 3, 0)
            : Offset.zero;
        return Transform.translate(offset: trembleOffset, child: child);
      },
      child: Container(
        width: 24,
        decoration: BoxDecoration(
          color: AppColors.scuffedBlack.withValues(alpha: 0.8),
          border: Border.all(color: AppColors.fadedRoadLineWhite.withValues(alpha: 0.3)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final fillHeight = constraints.maxHeight * widget.progress.clamp(0, 1);
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: fillHeight,
                  child: Container(color: gaugeColor),
                ),
                Positioned(
                  bottom: constraints.maxHeight * 0.9,
                  left: 0,
                  right: 0,
                  child: Container(height: 2, color: AppColors.brakeLightCrimson),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FuelGauge extends StatefulWidget {
  final int collected;
  final int required_;

  const _FuelGauge({required this.collected, required this.required_});

  @override
  State<_FuelGauge> createState() => _FuelGaugeState();
}

class _FuelGaugeState extends State<_FuelGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _prevCollected = 0;

  @override
  void initState() {
    super.initState();
    _prevCollected = widget.collected;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(covariant _FuelGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.collected > _prevCollected) {
      _prevCollected = widget.collected;
      _pulseController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFull = widget.collected >= widget.required_;
    final progress = widget.required_ > 0
        ? (widget.collected / widget.required_).clamp(0.0, 1.0)
        : 0.0;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + _pulseController.value * 0.15 * (1 - _pulseController.value);
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.scuffedBlack.withValues(alpha: 0.85),
          border: Border.all(
            color: isFull
                ? AppColors.dashboardGreen.withValues(alpha: 0.7)
                : AppColors.hazardMustard.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_gas_station,
              color: isFull ? AppColors.dashboardGreen : AppColors.hazardMustard,
              size: 18,
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 60,
              height: 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.sunBakedAsphalt,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isFull ? AppColors.dashboardGreen : AppColors.hazardMustard,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${widget.collected}/${widget.required_}',
              style: AppTextStyles.body.copyWith(
                color: isFull ? AppColors.dashboardGreen : AppColors.fadedRoadLineWhite,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
