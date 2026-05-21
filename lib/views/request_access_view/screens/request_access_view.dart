import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/theme_constants.dart';

/// Mirrors `pages/RequestAccessPage.jsx`. Shown when a user without an invite
/// code taps the "Request access" link on welcome.
class RequestAccessView extends StatelessWidget {
  const RequestAccessView({super.key});

  static const String _supportEmail = 'hello@growgram.app';
  static const String _mailtoBody =
      'mailto:$_supportEmail?subject=Growgram%20access%20request';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Get.back<void>,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Growgram is invite-only right now',
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontFamilyFallback: AppFonts.displayFallback,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                  letterSpacing: -0.8,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "We're rolling out access in small batches to keep the "
                'experience tight.',
                style: TextStyle(
                  fontFamily: AppFonts.ui,
                  fontFamilyFallback: AppFonts.uiFallback,
                  fontSize: 16,
                  height: 1.5,
                  color: AppColors.ink2,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _copyMailto(context),
                  child: const Text('Email us for access'),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _supportEmail,
                style: TextStyle(
                  fontFamily: AppFonts.mono,
                  fontFamilyFallback: AppFonts.monoFallback,
                  fontSize: 13,
                  color: AppColors.ink3,
                ),
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () => Get.offNamed(AppRoutes.welcome),
                  child: const Text('Already have an invite code?  Sign in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// `url_launcher` isn't a project dependency yet, so we keep this thin:
  /// copy the mailto link to the clipboard and surface a snackbar. Phase 11
  /// (Brand) adds `url_launcher` for asset links — we can swap to that
  /// dependency here once it's available.
  Future<void> _copyMailto(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _mailtoBody));
    if (!context.mounted) return;
    Get.snackbar(
      'Link copied',
      "Paste it into your mail app to reach the team.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
