import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/network/api_config.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/step_head.dart';
import '../widgets/step_shell.dart';

/// Step 3 — mirrors `BrandDetailsStep.jsx`. Collects brand name, city,
/// description, and IG handle, plus a "Find my profile" lookup that calls
/// POST /onboarding/profile (which mints the session token). The user then
/// taps "Analyse" inline on the result card to advance.
class BrandDetailsStep extends StatefulWidget {
  const BrandDetailsStep({super.key});

  @override
  State<BrandDetailsStep> createState() => _BrandDetailsStepState();
}

class _BrandDetailsStepState extends State<BrandDetailsStep> {
  final OnboardingController _c = Get.find<OnboardingController>();

  late final TextEditingController _name;
  late final TextEditingController _city;
  late final TextEditingController _description;
  late final TextEditingController _handle;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: _c.brandName.value ?? '')
      ..addListener(() => _c.brandName.value = _name.text);
    _city = TextEditingController(text: _c.brandCity.value ?? '')
      ..addListener(() => _c.brandCity.value = _city.text);
    _description = TextEditingController(text: _c.brandDescription.value ?? '')
      ..addListener(() => _c.brandDescription.value = _description.text);
    _handle = TextEditingController(text: _c.instagramHandle.value ?? '')
      ..addListener(_onHandleChanged);
  }

  void _onHandleChanged() {
    _c.instagramHandle.value = _handle.text;
    _c.resetProfileFetch();
  }

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _description.dispose();
    _handle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StepShell(
      head: const StepHead(
        eyebrow: 'Step 3 of 8',
        title: 'Tell us about your brand',
        sub: 'A few quick details so our AI can study your niche and '
            'competitors.',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LabeledField(label: 'Business name', controller: _name),
          _LabeledField(label: 'City', controller: _city, hint: 'Mumbai'),
          _LabeledField(
            label: 'Short description',
            controller: _description,
            minLines: 3,
            maxLines: 5,
            hint:
                'One sentence about who you serve and what makes you different.',
          ),
          _LabeledField(
            label: 'Instagram handle',
            controller: _handle,
            prefixText: '@',
            hint: "We'll fetch your public profile to personalize your setup.",
          ),
          const SizedBox(height: 4),
          // Obx reads the Rx form fields directly so it rebuilds as the user
          // types — TextEditingController.text is not observable.
          Obx(() {
            final handleVal = (_c.instagramHandle.value ?? '').trim();
            final state = _c.profileFetchState.value;
            final canFind =
                handleVal.length >= 2 && state == ProfileFetchState.idle;
            if (!canFind) return const SizedBox.shrink();
            return Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _c.findProfile,
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Find my profile'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            );
          }),
          Obx(() {
            switch (_c.profileFetchState.value) {
              case ProfileFetchState.idle:
                return const SizedBox.shrink();
              case ProfileFetchState.fetching:
                return const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: _FetchingCard(),
                );
              case ProfileFetchState.error:
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _ErrorCard(
                    code: _c.profileFetchErrorCode.value,
                    message: _c.profileFetchErrorMessage.value,
                  ),
                );
              case ProfileFetchState.fetched:
                final name = (_c.brandName.value ?? '').trim();
                final city = (_c.brandCity.value ?? '').trim();
                final description = (_c.brandDescription.value ?? '').trim();
                final handleVal = (_c.instagramHandle.value ?? '').trim();
                final isReady = name.isNotEmpty &&
                    city.isNotEmpty &&
                    description.isNotEmpty &&
                    handleVal.length >= 2;
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _ProfilePreviewCard(
                    profile: _c.profileData.value ?? const {},
                    handle: handleVal,
                    brandName: name,
                    canAnalyse: isReady,
                    onAnalyse: _c.continueToAnalysis,
                  ),
                );
            }
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Subwidgets
// ---------------------------------------------------------------------------

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? prefixText;
  final int minLines;
  final int maxLines;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.hint,
    this.prefixText,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: AppFonts.mono,
              fontFamilyFallback: AppFonts.monoFallback,
              fontSize: 11,
              letterSpacing: 0.44,
              color: AppColors.ink4,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            minLines: minLines,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixText: prefixText,
              hintText: hint,
            ),
          ),
        ],
      ),
    );
  }
}

class _FetchingCard extends StatelessWidget {
  const _FetchingCard();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.line2,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.line2,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 90,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.line2,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'Fetching…',
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontFamilyFallback: AppFonts.monoFallback,
              fontSize: 12,
              color: AppColors.ink3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String? code;
  final String? message;
  const _ErrorCard({required this.code, required this.message});

  String? get _hint {
    switch (code) {
      case 'USER_NOT_FOUND':
        return 'Double-check the handle and try again.';
      case 'ACCOUNT_PRIVATE':
        return 'Growgram only works with public Instagram accounts.';
      case 'CLIENT_NETWORK':
        return 'Could not reach the server. Check your connection.';
      case 'UPSTREAM_ERROR':
        return 'Instagram is being slow. Try again in a moment.';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message ?? 'Could not fetch profile. Please try again.',
            style: const TextStyle(fontSize: 13, color: AppColors.ink2),
          ),
          if (_hint != null) ...[
            const SizedBox(height: 6),
            Text(
              _hint!,
              style: const TextStyle(fontSize: 11, color: AppColors.ink3),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfilePreviewCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  final String handle;
  final String brandName;
  final bool canAnalyse;
  final VoidCallback onAnalyse;

  const _ProfilePreviewCard({
    required this.profile,
    required this.handle,
    required this.brandName,
    required this.canAnalyse,
    required this.onAnalyse,
  });

  static String _formatCount(num? n) {
    if (n == null) return '–';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  String get _proxiedAvatar {
    final raw = profile['profile_pic_url'] as String?;
    if (raw == null || raw.isEmpty) return '';
    return '${ApiConfig.onboardingProfileImage}?url=${Uri.encodeComponent(raw)}';
  }

  String get _initials {
    final src = brandName.isNotEmpty ? brandName : handle;
    if (src.isEmpty) return '?';
    return src.substring(0, src.length < 2 ? 1 : 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = brandName.isNotEmpty
        ? brandName
        : (profile['full_name'] as String? ?? handle);
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _GradientAvatar(
                imageUrl: _proxiedAvatar,
                initials: _initials,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@$handle',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppFonts.mono,
                        fontFamilyFallback: AppFonts.monoFallback,
                        fontSize: 12,
                        color: AppColors.ink3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatCell(
                label: 'Posts',
                value: _formatCount(profile['media_count'] as num?),
              ),
              _StatCell(
                label: 'Followers',
                value: _formatCount(profile['follower_count'] as num?),
              ),
              _StatCell(
                label: 'Following',
                value: _formatCount(profile['following_count'] as num?),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canAnalyse ? onAnalyse : null,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Analyse'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.line,
                disabledForegroundColor: AppColors.ink4,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (!canAnalyse) ...[
            const SizedBox(height: 8),
            const Text(
              'Fill the remaining fields to analyse.',
              style: TextStyle(fontSize: 11, color: AppColors.ink3),
            ),
          ],
        ],
      ),
    );
  }
}

class _GradientAvatar extends StatelessWidget {
  final String imageUrl;
  final String initials;
  const _GradientAvatar({required this.imageUrl, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            Color(0xFFF47B42),
            Color(0xFFE1306C),
            Color(0xFFC13584),
            Color(0xFFF47B42),
          ],
        ),
      ),
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _InitialsAvatar(initials: initials),
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Container(color: AppColors.line2);
                },
              )
            : _InitialsAvatar(initials: initials),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;
  const _InitialsAvatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ink,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: AppFonts.mono,
            fontFamilyFallback: AppFonts.monoFallback,
            fontSize: 10,
            letterSpacing: 0.5,
            color: AppColors.ink3,
          ),
        ),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}
