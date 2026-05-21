import 'package:flutter/material.dart';

import '../../../core/theme/theme_constants.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Growgram',
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontFamilyFallback: AppFonts.displayFallback,
                fontSize: 48,
                fontWeight: FontWeight.w500,
                letterSpacing: -1.5,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
