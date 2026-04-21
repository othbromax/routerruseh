import 'package:flutter/material.dart';
import 'package:route_rush/data/dls.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final VoidCallback onBack;

  const PrivacyPolicyScreen({super.key, required this.onBack});

  static const String _policyText = '''
ROUTE RUSH — PRIVACY POLICY

Effective Date: April 2026

This privacy policy applies to the Route Rush mobile application.

DATA COLLECTION
Route Rush does not collect, store, or transmit any personal data. The app does not use analytics, tracking, advertising SDKs, or any third-party services that gather user information.

LOCAL STORAGE
The app stores gameplay progress (such as route completion, upgrade levels, and earned currency) locally on your device. This data never leaves your device and is not accessible to the developer or any third party.

THIRD-PARTY SERVICES
Route Rush does not integrate with any third-party services, advertisement networks, or analytics platforms.

CHILDREN'S PRIVACY
The app does not collect any data from users of any age, including children under 13.

CONTACT
If you have questions about this privacy policy, you may contact the developer through the Google Play listing.

CHANGES
This policy may be updated in future versions of the app. Any changes will be reflected in the app and on the external policy URL.
''';

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
                    'FINE PRINT',
                    style: AppTextStyles.header.copyWith(fontSize: 32),
                  ),
                ],
              ),
            ),
            Container(height: 2, color: AppColors.fadedRoadLineWhite.withValues(alpha: 0.1)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.grimyPaper,
                    border: Border.all(
                      color: AppColors.fadedRoadLineWhite.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _policyText,
                    style: AppTextStyles.finePrint.copyWith(
                      color: AppColors.sunBakedAsphalt.withValues(alpha: 0.8),
                      fontSize: 14,
                      height: 1.5,
                    ),
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
