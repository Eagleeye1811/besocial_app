import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/theme_constants.dart';

/// App-wide top bar for the signed-in dashboard surfaces. Growgram logo +
/// wordmark on the left, a settings button on the right. Rendered by default
/// from [DashShell] so every tab shares one consistent header.
class DashTopBar extends StatelessWidget implements PreferredSizeWidget {
  const DashTopBar({super.key});

  static const double _barHeight = 56;

  @override
  Size get preferredSize => const Size.fromHeight(_barHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: _barHeight,
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/images/growgram_logo.svg',
            height: 26,
            semanticsLabel: 'Growgram logo',
          ),
          const SizedBox(width: 9),
          Text(
            'Growgram',
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.displayFallback,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.36,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          color: AppColors.ink2,
          tooltip: 'Settings',
          onPressed: () => Get.toNamed<void>(AppRoutes.settings),
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.line),
      ),
    );
  }
}
