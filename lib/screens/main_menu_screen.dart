import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:route_rush/data/dls.dart';
import 'package:route_rush/data/game_state.dart';
import 'package:route_rush/data/route_data.dart';

class MainMenuScreen extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onStartGame;

  const MainMenuScreen({
    super.key,
    required this.gameState,
    required this.onStartGame,
  });

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  static const double _backgroundImageOpacity = 0.22;

  final Random _random = Random();
  double _jitterX = 0;
  double _jitterY = 0;
  Timer? _jitterTimer;

  @override
  void initState() {
    super.initState();
    _jitterTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      if (mounted) {
        setState(() {
          _jitterX = (_random.nextDouble() - 0.5) * 2;
          _jitterY = (_random.nextDouble() - 0.5) * 2;
        });
      }
    });
  }

  @override
  void dispose() {
    _jitterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(_jitterX, _jitterY),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: AppColors.scuffedBlack),
          Positioned.fill(
            child: Opacity(
              opacity: _backgroundImageOpacity,
              child: Image.asset(
                'assets/images/routebg.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                const Spacer(flex: 2),
                Text(
                  'ROUTE',
                  style: AppTextStyles.display.copyWith(fontSize: 72),
                ),
                Transform.translate(
                  offset: const Offset(0, -16),
                  child: Text(
                    'RUSH',
                    style: AppTextStyles.display.copyWith(fontSize: 72),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'ASPHALT & AGONY',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.trafficConeOrange,
                    letterSpacing: 6,
                    fontSize: 16,
                  ),
                ),
                const Spacer(flex: 2),
                _PrimaryActionButton(
                  label: 'TURN IGNITION',
                  onPressed: widget.onStartGame,
                  hapticEnabled: widget.gameState.vibrationEnabled,
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: _MenuButton(
                        label: 'THE GARAGE',
                        onPressed: () => widget.gameState.setScreen(GameScreen.garage),
                        hapticEnabled: widget.gameState.vibrationEnabled,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _MenuButton(
                        label: 'FREQUENCIES',
                        onPressed: () => widget.gameState.setScreen(GameScreen.settings),
                        hapticEnabled: widget.gameState.vibrationEnabled,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _MenuButton(
                        label: 'SURVIVAL GUIDE',
                        onPressed: () => widget.gameState.setScreen(GameScreen.survivalGuide),
                        hapticEnabled: widget.gameState.vibrationEnabled,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _MenuButton(
                        label: 'FINE PRINT',
                        onPressed: () => widget.gameState.setScreen(GameScreen.privacyPolicy),
                        hapticEnabled: widget.gameState.vibrationEnabled,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Route + Coin display
                ListenableBuilder(
                  listenable: widget.gameState,
                  builder: (context, _) => Column(
                    children: [
                      Text(
                        'ROUTE ${widget.gameState.currentRoute} / ${allRoutes.length}',
                        style: AppTextStyles.finePrint.copyWith(
                          color: AppColors.fadedRoadLineWhite.withValues(alpha: 0.5),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.hazardMustard,
                              border: Border.all(color: AppColors.trafficConeOrange, width: 2),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '${widget.gameState.coins} HAZARD PAY',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.hazardMustard,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool hapticEnabled;

  const _PrimaryActionButton({required this.label, required this.onPressed, this.hapticEnabled = true});

  @override
  State<_PrimaryActionButton> createState() => _PrimaryActionButtonState();
}

class _PrimaryActionButtonState extends State<_PrimaryActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        if (widget.hapticEnabled) HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        transform: Matrix4.translationValues(
          _pressed ? 4 : 0,
          _pressed ? 4 : 0,
          0,
        ),
        child: Stack(
          children: [
            if (!_pressed)
              Positioned.fill(
                child: Transform.translate(
                  offset: const Offset(4, 4),
                  child: Container(color: AppColors.scuffedBlack),
                ),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.hazardMustard,
                border: Border.all(
                  color: AppColors.hazardMustard.withValues(alpha: 0.7),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.label,
                style: AppTextStyles.header.copyWith(
                  color: AppColors.scuffedBlack,
                  fontSize: 28,
                  letterSpacing: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool hapticEnabled;

  const _MenuButton({required this.label, required this.onPressed, this.hapticEnabled = true});

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        if (widget.hapticEnabled) HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        transform: Matrix4.translationValues(
          _pressed ? 3 : 0,
          _pressed ? 3 : 0,
          0,
        ),
        child: Stack(
          children: [
            if (!_pressed)
              Positioned.fill(
                child: Transform.translate(
                  offset: const Offset(3, 3),
                  child: Container(color: Colors.black),
                ),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.sunBakedAsphalt,
                border: Border.all(
                  color: AppColors.fadedRoadLineWhite.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.label,
                style: AppTextStyles.body.copyWith(
                  letterSpacing: 1,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
