import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:route_rush/data/dls.dart';

class PauseMenu extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onQuit;
  final bool hapticEnabled;

  const PauseMenu({
    super.key,
    required this.onResume,
    required this.onQuit,
    this.hapticEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scuffedBlack.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'HIT THE BRAKES',
              style: AppTextStyles.display.copyWith(fontSize: 48),
            ),
            const SizedBox(height: AppSpacing.xl),
            _PauseMenuButton(
              label: 'KEEP DRIVING',
              color: AppColors.hazardMustard,
              textColor: AppColors.scuffedBlack,
              onPressed: onResume,
              hapticEnabled: hapticEnabled,
            ),
            const SizedBox(height: AppSpacing.sm),
            _PauseMenuButton(
              label: 'ABANDON ROUTE',
              color: AppColors.sunBakedAsphalt,
              textColor: AppColors.brakeLightCrimson,
              onPressed: onQuit,
              hapticEnabled: hapticEnabled,
            ),
          ],
        ),
      ),
    );
  }
}

class _PauseMenuButton extends StatefulWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;
  final bool hapticEnabled;

  const _PauseMenuButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onPressed,
    this.hapticEnabled = true,
  });

  @override
  State<_PauseMenuButton> createState() => _PauseMenuButtonState();
}

class _PauseMenuButtonState extends State<_PauseMenuButton> {
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
          _pressed ? 4 : 0,
          _pressed ? 4 : 0,
          0,
        ),
        child: Stack(
          children: [
            if (!_pressed)
              Container(
                width: 260,
                height: 56,
                transform: Matrix4.translationValues(4, 4, 0),
                color: Colors.black,
              ),
            Container(
              width: 260,
              height: 56,
              decoration: BoxDecoration(
                color: widget.color,
                border: Border.all(
                  color: widget.textColor.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.label,
                style: AppTextStyles.header.copyWith(
                  color: widget.textColor,
                  fontSize: 22,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
