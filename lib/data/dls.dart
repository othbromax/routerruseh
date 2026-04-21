import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color sunBakedAsphalt = Color(0xFF2A2B2E);
  static const Color scuffedBlack = Color(0xFF121212);
  static const Color grimyPaper = Color(0xFFE8E3D8);

  static const Color hazardMustard = Color(0xFFF4C430);
  static const Color trafficConeOrange = Color(0xFFFF5A00);

  static const Color brakeLightCrimson = Color(0xFFD10000);
  static const Color dashboardGreen = Color(0xFF39FF14);
  static const Color fadedRoadLineWhite = Color(0xFFD9D9D9);

  static const Color overlayDark = Color(0xCC121212);
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle display = GoogleFonts.teko(
    fontSize: 60,
    fontWeight: FontWeight.w700,
    color: AppColors.hazardMustard,
    letterSpacing: 4,
    height: 1.1,
  );

  static TextStyle header = GoogleFonts.teko(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    color: AppColors.fadedRoadLineWhite,
    height: 1.1,
  );

  static TextStyle body = GoogleFonts.teko(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: AppColors.fadedRoadLineWhite,
    height: 1.2,
  );

  static TextStyle finePrint = GoogleFonts.teko(
    fontSize: 15,
    fontWeight: FontWeight.w300,
    color: AppColors.fadedRoadLineWhite,
    height: 1.2,
  );
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 8;
  static const double sm = 16;
  static const double md = 24;
  static const double lg = 32;
  static const double xl = 48;
  static const double xxl = 64;
}

class AppWidgets {
  AppWidgets._();

  static ButtonStyle primaryButton = ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(AppColors.hazardMustard),
    foregroundColor: WidgetStatePropertyAll(AppColors.scuffedBlack),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 48, vertical: 16),
    ),
    shape: const WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
    elevation: const WidgetStatePropertyAll(0),
    textStyle: WidgetStatePropertyAll(
      GoogleFonts.teko(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    ),
  );

  static ButtonStyle secondaryButton = ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(AppColors.sunBakedAsphalt),
    foregroundColor: WidgetStatePropertyAll(AppColors.fadedRoadLineWhite),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 32, vertical: 12),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: AppColors.fadedRoadLineWhite.withValues(alpha: 0.3), width: 2),
      ),
    ),
    elevation: const WidgetStatePropertyAll(0),
    textStyle: WidgetStatePropertyAll(
      GoogleFonts.teko(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    ),
  );

  static Widget hardShadowButton({
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = true,
  }) {
    return Stack(
      children: [
        Positioned(
          left: 4,
          top: 4,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isPrimary ? 48 : 32,
              vertical: isPrimary ? 16 : 12,
            ),
            color: AppColors.scuffedBlack,
            child: Text(label, style: TextStyle(color: Colors.transparent, fontSize: isPrimary ? 24 : 20)),
          ),
        ),
        ElevatedButton(
          style: isPrimary ? primaryButton : secondaryButton,
          onPressed: onPressed,
          child: Text(label),
        ),
      ],
    );
  }
}
