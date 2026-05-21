import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller/auth_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/invite_field.dart';

/// Mirrors `features/onboarding/steps/WelcomeStep.jsx` from the website.
/// The web layout is a two-column grid with a decorative preview pane on
/// the right; mobile collapses to the left column only.
class WelcomeView extends GetView<AuthController> {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(),
              const SizedBox(height: 36),
              _buildInviteForm(),
              const SizedBox(height: 28),
              _buildSignInDivider(),
              const SizedBox(height: 20),
              _buildGoogleButton(),
              const SizedBox(height: 24),
              _buildRequestAccessLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.displayFallback,
              fontSize: 44,
              fontWeight: FontWeight.w500,
              height: 1.02,
              letterSpacing: -1.5,
              color: AppColors.ink,
            ),
            children: [
              const TextSpan(text: 'Grow Instagram\n'),
              TextSpan(
                text: 'with ',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  color: AppColors.ink2,
                ),
              ),
              TextSpan(
                text: 'AI.',
                style: TextStyle(color: AppColors.accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Made for local businesses. Generate on-brand carousels and '
          'captions in minutes — no agency required.',
          style: TextStyle(
            fontFamily: AppFonts.ui,
            fontFamilyFallback: AppFonts.uiFallback,
            fontSize: 16,
            height: 1.5,
            color: AppColors.ink2,
          ),
        ),
      ],
    );
  }

  Widget _buildInviteForm() {
    return Obx(() {
      final error = controller.errorMessage.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InviteField(
            controller: controller.inviteCodeField,
            enabled: !controller.isBusy,
            onSubmitted: (_) => controller.validateInviteAndStart(),
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isBusy
                  ? null
                  : controller.validateInviteAndStart,
              child: Text(
                controller.isValidatingInvite.value
                    ? 'Checking code…'
                    : 'Start setup',
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSignInDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontFamilyFallback: AppFonts.monoFallback,
              fontSize: 11,
              color: AppColors.ink4,
              letterSpacing: 0.44,
            ),
          ),
        ),
        const Expanded(child: Divider(height: 1)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return Obx(() {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: controller.isBusy
              ? null
              : () => controller.signInWithGoogle(),
          child: Text(
            controller.isStartingGoogleSignIn.value
                ? 'Redirecting…'
                : 'Sign in with Google',
          ),
        ),
      );
    });
  }

  Widget _buildRequestAccessLink() {
    return Center(
      child: TextButton(
        onPressed: () => Get.toNamed(AppRoutes.requestAccess),
        child: const Text('No invite code?  Request access'),
      ),
    );
  }
}
