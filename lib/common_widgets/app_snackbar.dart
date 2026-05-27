import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme/theme_constants.dart';

/// One consistent, app-wide snackbar for confirming important actions.
///
/// Three intents — [success], [error], [info] — share a clean floating card:
/// a tinted icon chip, a bold title and an optional supporting line, a
/// hairline border and a soft lift shadow. Swipe-to-dismiss; auto-dismiss
/// timing scales with intent (errors linger a little longer).
///
/// Usage:
/// ```dart
/// AppSnackbar.success('Saved to gallery', '3 images saved.');
/// AppSnackbar.error('Post failed', 'Check your connection and try again.');
/// AppSnackbar.info('Photo access needed', 'Allow access to save images.');
/// ```
class AppSnackbar {
  AppSnackbar._();

  static void success(String title, [String message = '']) =>
      _show(_SnackKind.success, title, message);

  static void error(String title, [String message = '']) =>
      _show(_SnackKind.error, title, message);

  static void info(String title, [String message = '']) =>
      _show(_SnackKind.info, title, message);

  static void _show(_SnackKind kind, String title, String message) {
    final spec = _SnackSpec.of(kind);

    // Replace any visible snackbar so rapid actions don't stack a queue.
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    Get.showSnackbar(
      GetSnackBar(
        snackPosition: SnackPosition.BOTTOM,
        snackStyle: SnackStyle.FLOATING,
        backgroundColor: AppColors.white,
        borderRadius: 14,
        borderColor: AppColors.line,
        borderWidth: 1,
        maxWidth: 460,
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        padding: const EdgeInsets.all(14),
        duration: spec.duration,
        animationDuration: const Duration(milliseconds: 300),
        forwardAnimationCurve: Curves.easeOutCubic,
        reverseAnimationCurve: Curves.easeInCubic,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        boxShadows: const [
          BoxShadow(
            color: Color(0x2618181B),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
        messageText: _SnackContent(spec: spec, title: title, message: message),
      ),
    );
  }
}

enum _SnackKind { success, error, info }

class _SnackSpec {
  final IconData icon;
  final Color foreground;
  final Color tint;
  final Duration duration;

  const _SnackSpec({
    required this.icon,
    required this.foreground,
    required this.tint,
    required this.duration,
  });

  static _SnackSpec of(_SnackKind kind) {
    switch (kind) {
      case _SnackKind.success:
        return const _SnackSpec(
          icon: Icons.check_rounded,
          foreground: AppColors.good,
          tint: Color(0x1F16A34A),
          duration: Duration(milliseconds: 2600),
        );
      case _SnackKind.error:
        return const _SnackSpec(
          icon: Icons.error_outline_rounded,
          foreground: Color(0xFFDC2626),
          tint: Color(0x1ADC2626),
          duration: Duration(milliseconds: 3600),
        );
      case _SnackKind.info:
        return const _SnackSpec(
          icon: Icons.info_outline_rounded,
          foreground: AppColors.accent,
          tint: AppColors.accentSoft,
          duration: Duration(milliseconds: 2900),
        );
    }
  }
}

class _SnackContent extends StatelessWidget {
  final _SnackSpec spec;
  final String title;
  final String message;

  const _SnackContent({
    required this.spec,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final hasMessage = message.trim().isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: spec.tint,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(spec.icon, color: spec.foreground, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppFonts.ui,
                  fontFamilyFallback: AppFonts.uiFallback,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  color: AppColors.ink,
                ),
              ),
              if (hasMessage) ...[
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontFamily: AppFonts.ui,
                    fontFamilyFallback: AppFonts.uiFallback,
                    fontSize: 12.5,
                    height: 1.35,
                    color: AppColors.ink3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
