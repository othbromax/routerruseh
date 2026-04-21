import 'dart:async';
import 'package:flutter/material.dart';
import 'package:route_rush/data/dls.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFade;
  late Animation<double> _headlightSpread;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5)),
    );

    _headlightSpread = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8)),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 2800), widget.onComplete);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scuffedBlack,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Headlight beams
              Center(
                child: Opacity(
                  opacity: _headlightSpread.value * 0.3,
                  child: Container(
                    width: 300 * _headlightSpread.value,
                    height: 300 * _headlightSpread.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.hazardMustard.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Logo text
              Center(
                child: Opacity(
                  opacity: _logoFade.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('ROUTE', style: AppTextStyles.display.copyWith(fontSize: 64)),
                      Transform.translate(
                        offset: const Offset(0, -12),
                        child: Text('RUSH', style: AppTextStyles.display.copyWith(fontSize: 64)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
