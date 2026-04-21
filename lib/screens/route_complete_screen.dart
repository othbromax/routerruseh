import 'package:flutter/material.dart';
import 'package:route_rush/data/dls.dart';
import 'package:route_rush/data/game_state.dart';

class RouteCompleteScreen extends StatefulWidget {
  final GameState gameState;
  final int basePay;
  final int timeBonus;
  final int cleanRideBonus;
  final VoidCallback onNextRoute;
  final VoidCallback onGarage;
  final VoidCallback onMainMenu;

  const RouteCompleteScreen({
    super.key,
    required this.gameState,
    required this.basePay,
    required this.timeBonus,
    required this.cleanRideBonus,
    required this.onNextRoute,
    required this.onGarage,
    required this.onMainMenu,
  });

  int get totalPay => basePay + timeBonus + cleanRideBonus;

  @override
  State<RouteCompleteScreen> createState() => _RouteCompleteScreenState();
}

class _RouteCompleteScreenState extends State<RouteCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 1.5),
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
    return Container(
      color: AppColors.scuffedBlack.withValues(alpha: 0.9),
      child: Center(
        child: SlideTransition(
          position: _slideUp,
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
                Center(
                  child: Text(
                    'DELIVERY CONFIRMATION',
                    style: AppTextStyles.header.copyWith(
                      color: AppColors.sunBakedAsphalt,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(height: 2, color: AppColors.sunBakedAsphalt),
                const SizedBox(height: AppSpacing.md),
                // Stamp
                Center(
                  child: Transform.rotate(
                    angle: 0.04,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.dashboardGreen, width: 3),
                      ),
                      child: Text(
                        'PACKAGE DELIVERED',
                        style: AppTextStyles.display.copyWith(
                          color: AppColors.dashboardGreen,
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(height: 1, color: AppColors.sunBakedAsphalt.withValues(alpha: 0.3)),
                const SizedBox(height: AppSpacing.sm),
                _ReceiptLine(label: 'ROUTE', value: '#${widget.gameState.currentRoute}'),
                _ReceiptLine(label: 'DISTANCE', value: '${widget.gameState.distanceTraveled.toInt()} m'),
                _ReceiptLine(label: 'HAZARDS HIT', value: '${widget.gameState.hazardsHit}'),
                _ReceiptLine(label: 'FUEL COLLECTED', value: '${widget.gameState.fuelCoinsCollected}/${widget.gameState.fuelCoinsRequired}'),
                const SizedBox(height: AppSpacing.sm),
                Container(height: 1, color: AppColors.sunBakedAsphalt.withValues(alpha: 0.3)),
                const SizedBox(height: AppSpacing.sm),
                // Payout breakdown
                Text(
                  'PAYOUT',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.sunBakedAsphalt,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                _ReceiptLine(label: 'Base Route Pay', value: '+${widget.basePay}'),
                _ReceiptLine(label: 'Time Bonus', value: '+${widget.timeBonus}'),
                if (widget.cleanRideBonus > 0)
                  _ReceiptLine(label: 'Clean Ride Bonus', value: '+${widget.cleanRideBonus}'),
                const SizedBox(height: AppSpacing.xs),
                Container(height: 2, color: AppColors.sunBakedAsphalt),
                const SizedBox(height: AppSpacing.xs),
                _ReceiptLine(
                  label: 'TOTAL HAZARD PAY',
                  value: '+${widget.totalPay}',
                  isBold: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                _ReceiptButton(
                  label: 'NEXT DROP-OFF',
                  color: AppColors.hazardMustard,
                  textColor: AppColors.scuffedBlack,
                  onPressed: widget.onNextRoute,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: _ReceiptButton(
                        label: 'THE GARAGE',
                        color: AppColors.sunBakedAsphalt,
                        textColor: AppColors.fadedRoadLineWhite,
                        onPressed: widget.onGarage,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: _ReceiptButton(
                        label: 'BACK TO DEPOT',
                        color: AppColors.sunBakedAsphalt,
                        textColor: AppColors.fadedRoadLineWhite,
                        onPressed: widget.onMainMenu,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _ReceiptLine({
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
              fontSize: isBold ? 20 : 15,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: isBold ? AppColors.dashboardGreen : AppColors.sunBakedAsphalt,
              fontSize: isBold ? 20 : 15,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const _ReceiptButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: textColor,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
