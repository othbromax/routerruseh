import 'package:flutter/material.dart';
import 'package:route_rush/data/dls.dart';
import 'package:route_rush/data/game_state.dart';

class GameOverScreen extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onRetry;
  final VoidCallback onMainMenu;

  const GameOverScreen({
    super.key,
    required this.gameState,
    required this.onRetry,
    required this.onMainMenu,
  });

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideIn = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reason = widget.gameState.gameOverReason;
    final String reasonText;
    final String reasonSubtext;
    switch (reason) {
      case GameOverReason.wrecked:
        reasonText = 'VEHICLE TOTALED';
        reasonSubtext = 'Chassis integrity compromised';
      case GameOverReason.fired:
        reasonText = 'FIRED';
        reasonSubtext = 'Deadline expired';
      case GameOverReason.outOfFuel:
        reasonText = 'OUT OF FUEL';
        reasonSubtext = 'Not enough gas to complete delivery';
    }

    return Container(
      color: AppColors.scuffedBlack.withValues(alpha: 0.9),
      child: Center(
        child: SlideTransition(
          position: _slideIn,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.grimyPaper,
              border: Border.all(color: AppColors.fadedRoadLineWhite.withValues(alpha: 0.5), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Center(
                  child: Text(
                    'TOW TRUCK INVOICE',
                    style: AppTextStyles.header.copyWith(
                      color: AppColors.sunBakedAsphalt,
                      fontSize: 28,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(height: 2, color: AppColors.sunBakedAsphalt),
                const SizedBox(height: AppSpacing.md),
                // Reason stamp
                Center(
                  child: Transform.rotate(
                    angle: -0.05,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.brakeLightCrimson, width: 3),
                      ),
                      child: Text(
                        reasonText,
                        style: AppTextStyles.display.copyWith(
                          color: AppColors.brakeLightCrimson,
                          fontSize: 36,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Center(
                  child: Text(
                    reasonSubtext,
                    style: AppTextStyles.finePrint.copyWith(
                      color: AppColors.sunBakedAsphalt.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(height: 1, color: AppColors.sunBakedAsphalt.withValues(alpha: 0.3)),
                const SizedBox(height: AppSpacing.sm),
                // Stats
                _InvoiceLine(
                  label: 'ROUTE',
                  value: '#${widget.gameState.currentRoute}',
                ),
                _InvoiceLine(
                  label: 'DISTANCE',
                  value: '${widget.gameState.distanceTraveled.toInt()} m',
                ),
                _InvoiceLine(
                  label: 'HAZARDS HIT',
                  value: '${widget.gameState.hazardsHit}',
                ),
                _InvoiceLine(
                  label: 'FUEL COLLECTED',
                  value: '${widget.gameState.fuelCoinsCollected}/${widget.gameState.fuelCoinsRequired}',
                ),
                const SizedBox(height: AppSpacing.md),
                Container(height: 1, color: AppColors.sunBakedAsphalt.withValues(alpha: 0.3)),
                const SizedBox(height: AppSpacing.md),
                // Payout
                _InvoiceLine(
                  label: 'HAZARD PAY',
                  value: '0',
                  isBold: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                // Actions
                _InvoiceButton(
                  label: 'TAKE ANOTHER SHIFT',
                  isPrimary: true,
                  onPressed: widget.onRetry,
                ),
                const SizedBox(height: AppSpacing.xs),
                _InvoiceButton(
                  label: 'BACK TO DEPOT',
                  isPrimary: false,
                  onPressed: widget.onMainMenu,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InvoiceLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _InvoiceLine({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.sunBakedAsphalt.withValues(alpha: 0.7),
              fontSize: isBold ? 20 : 16,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: AppColors.sunBakedAsphalt,
              fontSize: isBold ? 20 : 16,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _InvoiceButton({
    required this.label,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.hazardMustard : AppColors.sunBakedAsphalt,
          foregroundColor: isPrimary ? AppColors.scuffedBlack : AppColors.fadedRoadLineWhite,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: isPrimary ? AppColors.scuffedBlack : AppColors.fadedRoadLineWhite,
            fontSize: 18,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
