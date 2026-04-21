import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:route_rush/data/dls.dart';
import 'package:route_rush/data/game_state.dart';
import 'package:route_rush/data/route_data.dart';

class GarageScreen extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onBack;

  const GarageScreen({
    super.key,
    required this.gameState,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scuffedBlack,
      child: SafeArea(
        child: ListenableBuilder(
          listenable: gameState,
          builder: (context, _) => Column(
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
                      'THE GARAGE',
                      style: AppTextStyles.header.copyWith(fontSize: 32),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.sunBakedAsphalt,
                        border: Border.all(
                          color: AppColors.hazardMustard.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.hazardMustard,
                              border: Border.all(color: AppColors.trafficConeOrange, width: 1.5),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${gameState.coins}',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.hazardMustard,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 2, color: AppColors.fadedRoadLineWhite.withValues(alpha: 0.1)),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  itemCount: allUpgrades.length,
                  itemBuilder: (context, index) {
                    return _UpgradeCard(
                      upgrade: allUpgrades[index],
                      currentLevel: gameState.getUpgradeLevel(allUpgrades[index].id),
                      coins: gameState.coins,
                      onPurchase: () => _purchaseUpgrade(allUpgrades[index]),
                      onCantAfford: () => _triggerHapticError(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _purchaseUpgrade(UpgradeDefinition upgrade) {
    final currentLevel = gameState.getUpgradeLevel(upgrade.id);
    if (currentLevel >= upgrade.tiers.length) return;

    final tier = upgrade.tiers[currentLevel];
    if (gameState.spendCoins(tier.cost)) {
      gameState.setUpgradeLevel(upgrade.id, currentLevel + 1);
      gameState.saveProgress();
      if (gameState.vibrationEnabled) {
        HapticFeedback.mediumImpact();
      }
    }
  }

  void _triggerHapticError() {
    if (gameState.vibrationEnabled) {
      HapticFeedback.heavyImpact();
    }
  }
}

class _UpgradeCard extends StatefulWidget {
  final UpgradeDefinition upgrade;
  final int currentLevel;
  final int coins;
  final VoidCallback onPurchase;
  final VoidCallback onCantAfford;

  const _UpgradeCard({
    required this.upgrade,
    required this.currentLevel,
    required this.coins,
    required this.onPurchase,
    required this.onCantAfford,
  });

  @override
  State<_UpgradeCard> createState() => _UpgradeCardState();
}

class _UpgradeCardState extends State<_UpgradeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  bool get isMaxed => widget.currentLevel >= widget.upgrade.tiers.length;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onTapCantAfford() {
    _shakeController.forward(from: 0);
    widget.onCantAfford();
  }

  @override
  Widget build(BuildContext context) {
    final nextTier = isMaxed ? null : widget.upgrade.tiers[widget.currentLevel];
    final canAfford = nextTier != null && widget.coins >= nextTier.cost;
    final currentTierLabel = widget.currentLevel > 0
        ? widget.upgrade.tiers[widget.currentLevel - 1].label
        : 'Stock';

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeAnimation.value, 0),
        child: child,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.sunBakedAsphalt,
          border: Border.all(
            color: AppColors.fadedRoadLineWhite.withValues(alpha: 0.15),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.upgrade.name.toUpperCase(),
                  style: AppTextStyles.header.copyWith(fontSize: 24),
                ),
                const Spacer(),
                Row(
                  children: List.generate(widget.upgrade.tiers.length, (i) {
                    return Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: i < widget.currentLevel
                            ? AppColors.dashboardGreen
                            : AppColors.scuffedBlack,
                        border: Border.all(
                          color: i < widget.currentLevel
                              ? AppColors.dashboardGreen.withValues(alpha: 0.5)
                              : AppColors.fadedRoadLineWhite.withValues(alpha: 0.2),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.upgrade.description,
              style: AppTextStyles.finePrint.copyWith(
                color: AppColors.fadedRoadLineWhite.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Text(
                  'CURRENT: $currentTierLabel',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.fadedRoadLineWhite.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (isMaxed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.dashboardGreen.withValues(alpha: 0.15),
                      border: Border.all(color: AppColors.dashboardGreen.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'MAXED',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.dashboardGreen,
                        fontSize: 14,
                        letterSpacing: 2,
                      ),
                    ),
                  )
                else
                  Opacity(
                    opacity: canAfford ? 1.0 : 0.4,
                    child: GestureDetector(
                      onTap: canAfford ? widget.onPurchase : _onTapCantAfford,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: canAfford ? AppColors.hazardMustard : AppColors.sunBakedAsphalt,
                          border: Border.all(
                            color: canAfford
                                ? AppColors.hazardMustard
                                : AppColors.fadedRoadLineWhite.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'UPGRADE',
                              style: AppTextStyles.body.copyWith(
                                color: canAfford ? AppColors.scuffedBlack : AppColors.fadedRoadLineWhite,
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.hazardMustard,
                                border: Border.all(color: AppColors.trafficConeOrange, width: 1),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${nextTier!.cost}',
                              style: AppTextStyles.body.copyWith(
                                color: canAfford ? AppColors.scuffedBlack : AppColors.hazardMustard,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
