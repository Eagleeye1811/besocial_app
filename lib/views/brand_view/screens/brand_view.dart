import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common_widgets/dash_shell.dart';
import '../../../controllers/brand_controller/brand_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/assets_section.dart';
import '../widgets/content_prefs_section.dart';
import '../widgets/identity_section.dart';
import '../widgets/instagram_section.dart';
import '../widgets/niche_section.dart';
import '../widgets/voice_visual_section.dart';

/// Mirrors `frontend/src/features/brand/pages/BrandPage.jsx` — five
/// independent section cards, each PATCHing its own slice.
class BrandView extends GetView<BrandController> {
  const BrandView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashShell(
      currentTab: DashTab.brand,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: controller.refreshAll,
          child: Obx(() {
            final profile = controller.profile.value;
            final isLoading = controller.isLoading.value;
            final err = controller.errorMessage.value;

            if (profile == null && isLoading) {
              return ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }
            if (profile == null) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 28, color: Color(0xFFDC2626)),
                        const SizedBox(height: 10),
                        Text(
                          err ?? "Couldn't load your brand profile.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13, color: AppColors.ink2),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: controller.refreshAll,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _Header(),
                const SizedBox(height: 16),
                IdentitySection(profile: profile),
                const InstagramSection(),
                NicheSection(profile: profile),
                VoiceVisualSection(profile: profile),
                ContentPrefsSection(profile: profile),
                const AssetsSection(),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _Header extends GetView<BrandController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Brand',
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontFamilyFallback: AppFonts.displayFallback,
            fontSize: 28,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.6,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Edit how every AI-generated post sounds and looks.',
          style: TextStyle(fontSize: 13, color: AppColors.ink3),
        ),
      ],
    );
  }
}
