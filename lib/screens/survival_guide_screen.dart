import 'package:flutter/material.dart';
import 'package:route_rush/data/dls.dart';

class SurvivalGuideScreen extends StatelessWidget {
  final VoidCallback onBack;

  const SurvivalGuideScreen({super.key, required this.onBack});

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
                    'SURVIVAL GUIDE',
                    style: AppTextStyles.header.copyWith(fontSize: 32),
                  ),
                ],
              ),
            ),
            Container(height: 2, color: AppColors.fadedRoadLineWhite.withValues(alpha: 0.1)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  children: [
                    _GuideCard(
                      icon: Icons.swipe,
                      iconColor: AppColors.hazardMustard,
                      title: 'STEER',
                      description: 'Drag left or right anywhere on the lower half of the screen to dodge hazards.',
                    ),
                    _GuideCard(
                      icon: Icons.circle,
                      iconColor: AppColors.sunBakedAsphalt,
                      title: 'POTHOLES',
                      description: 'Dark craters in the road. Hitting one slows you down, costing precious time against the deadline.',
                    ),
                    _GuideCard(
                      icon: Icons.auto_awesome,
                      iconColor: AppColors.fadedRoadLineWhite,
                      title: 'NAILS & GLASS',
                      description: 'Glinting debris fields. Running over them causes a flat tire — your vehicle drifts sideways for several seconds.',
                    ),
                    _GuideCard(
                      icon: Icons.block,
                      iconColor: AppColors.brakeLightCrimson,
                      title: 'BARRICADES',
                      description: 'Heavy barriers. Each hit costs 1 Chassis Integrity. Lose all 3 and your vehicle is totaled.',
                    ),
                    _GuideCard(
                      icon: Icons.water_drop,
                      iconColor: const Color(0xFF663399),
                      title: 'OIL SPILLS',
                      description: 'Dark slick puddles. Driving through one causes your vehicle to slide uncontrollably and lose speed.',
                    ),
                    _GuideCard(
                      icon: Icons.change_history,
                      iconColor: AppColors.trafficConeOrange,
                      title: 'TRAFFIC CONES',
                      description: 'Orange cones scattered on the road. Hitting them causes a brief speed stutter and bumps your vehicle.',
                    ),
                    _GuideCard(
                      icon: Icons.local_gas_station,
                      iconColor: AppColors.hazardMustard,
                      title: 'FUEL COINS',
                      description: 'Collect glowing fuel coins along the route. You must collect enough fuel before reaching the drop-off or you\'ll run dry!',
                    ),
                    _GuideCard(
                      icon: Icons.timer,
                      iconColor: AppColors.trafficConeOrange,
                      title: 'DEADLINE',
                      description: 'The gauge on the right fills over time. If it maxes out before you reach the drop-off distance, you\'re fired.',
                    ),
                    _GuideCard(
                      icon: Icons.flag,
                      iconColor: AppColors.dashboardGreen,
                      title: 'WIN CONDITION',
                      description: 'Reach the target distance and collect enough fuel before the deadline expires. Dodge everything you can for bonus pay.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _GuideCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.sunBakedAsphalt,
        border: Border.all(
          color: AppColors.fadedRoadLineWhite.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.scuffedBlack,
              border: Border.all(color: iconColor.withValues(alpha: 0.4)),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.header.copyWith(
                    fontSize: 20,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.finePrint.copyWith(
                    color: AppColors.fadedRoadLineWhite.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
