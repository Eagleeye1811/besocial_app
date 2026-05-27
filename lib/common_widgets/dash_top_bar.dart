import 'package:flutter/material.dart';
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
          const GrowgramLogo(size: 26),
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

/// The Growgram mark, drawn natively so it always renders (no SVG/asset
/// dependency). A dark rounded-square badge with two orange bars — identical
/// to the website's `Icon name="logo"` (24×24 viewBox, `#18181B` square,
/// `#F47B42` glyph).
class GrowgramLogo extends StatelessWidget {
  final double size;
  const GrowgramLogo({super.key, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GrowgramLogoPainter()),
    );
  }
}

class _GrowgramLogoPainter extends CustomPainter {
  static const Color _badge = Color(0xFF18181B);
  static const Color _glyph = Color(0xFFF47B42);

  @override
  void paint(Canvas canvas, Size size) {
    // Everything is authored in the 24-unit SVG viewBox, then scaled.
    final s = size.width / 24.0;
    Rect r(double l, double t, double rt, double b) =>
        Rect.fromLTRB(l * s, t * s, rt * s, b * s);

    // Dark rounded-square badge.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(7 * s)),
      Paint()..color = _badge,
    );

    // Two orange bars (left edges square, right ends rounded — matching the
    // SVG path), the lower bar slightly wider.
    final cap = Radius.circular(2.7 * s);
    final glyph = Paint()..color = _glyph;
    canvas.drawRRect(
      RRect.fromRectAndCorners(r(7.5, 7.5, 16.4, 12.9),
          topRight: cap, bottomRight: cap),
      glyph,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(r(7.5, 12.9, 17.6, 18.3),
          topRight: cap, bottomRight: cap),
      glyph,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
