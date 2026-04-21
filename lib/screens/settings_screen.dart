import 'package:flutter/material.dart';
import 'package:route_rush/data/dls.dart';
import 'package:route_rush/data/game_state.dart';

class SettingsScreen extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onBack;

  const SettingsScreen({
    super.key,
    required this.gameState,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scuffedBlack,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.sunBakedAsphalt,
                        border: Border.all(
                          color: AppColors.fadedRoadLineWhite.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.fadedRoadLineWhite,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'FREQUENCIES',
                    style: AppTextStyles.header.copyWith(fontSize: 32),
                  ),
                ],
              ),
            ),
            Container(height: 2, color: AppColors.fadedRoadLineWhite.withValues(alpha: 0.1)),
            Expanded(
              child: ListenableBuilder(
                listenable: gameState,
                builder: (context, _) => Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      _SettingsToggle(
                        label: 'SOUND EFFECTS',
                        value: gameState.sfxEnabled,
                        onToggle: gameState.toggleSfx,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _SettingsToggle(
                        label: 'MUSIC',
                        value: gameState.musicEnabled,
                        onToggle: gameState.toggleMusic,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _SettingsToggle(
                        label: 'VIBRATION',
                        value: gameState.vibrationEnabled,
                        onToggle: gameState.toggleVibration,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final String label;
  final bool value;
  final VoidCallback onToggle;

  const _SettingsToggle({
    required this.label,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.sunBakedAsphalt,
          border: Border.all(
            color: AppColors.fadedRoadLineWhite.withValues(alpha: 0.15),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextStyles.body.copyWith(fontSize: 20),
            ),
            const Spacer(),
            // Toggle indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                color: value ? AppColors.dashboardGreen.withValues(alpha: 0.2) : AppColors.scuffedBlack,
                border: Border.all(
                  color: value
                      ? AppColors.dashboardGreen
                      : AppColors.fadedRoadLineWhite.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 150),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.all(2),
                  color: value ? AppColors.dashboardGreen : AppColors.fadedRoadLineWhite.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
