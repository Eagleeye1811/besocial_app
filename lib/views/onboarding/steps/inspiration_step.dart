import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/step_head.dart';
import '../widgets/step_shell.dart';

/// Step 8 — mirrors `InspirationStep.jsx`. Renders the inspiration feed as
/// a one-card-at-a-time stack with explicit heart/skip buttons (full swipe
/// gestures are a polish follow-up). The first heart shortlists the post
/// and hands off to Google OAuth — see [OnboardingController.swipePost].
class InspirationStep extends StatefulWidget {
  const InspirationStep({super.key});

  @override
  State<InspirationStep> createState() => _InspirationStepState();
}

class _InspirationStepState extends State<InspirationStep> {
  final OnboardingController _c = Get.find<OnboardingController>();
  int _index = 0;

  void _next() => setState(() => _index += 1);

  @override
  Widget build(BuildContext context) {
    return StepShell(
      head: const StepHead(
        eyebrow: 'Step 8 of 8 · Inspiration',
        title: 'Your inspiration grid is ready',
        sub: 'Heart what speaks to you. The first heart unlocks generation.',
      ),
      body: Obx(() {
        final feed = _c.inspirationFeed;
        if (feed.isEmpty) {
          return _emptyOrLoading();
        }
        if (_index >= feed.length) {
          return _allDone();
        }
        final card = feed[_index];
        return Column(
          children: [
            _CardPreview(
              imageUrl: card.imageUrl,
              caption: card.caption,
              ownerHandle: card.ownerUsername,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Skip'),
                    onPressed: () async {
                      await _c.swipePost(
                          postId: card.postId, shortlisted: false);
                      _next();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.favorite, size: 18),
                    label: const Text('Heart'),
                    onPressed: () async {
                      await _c.swipePost(
                          postId: card.postId, shortlisted: true);
                      _next();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Card ${_index + 1} of ${feed.length}',
              style: TextStyle(fontSize: 12, color: AppColors.ink3),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final err = _c.errorMessage.value;
              if (err == null) return const SizedBox.shrink();
              return Text(
                err,
                style:
                    const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
              );
            }),
          ],
        );
      }),
    );
  }

  Widget _emptyOrLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.accent),
          ),
          const SizedBox(height: 12),
          Text(
            "Loading your grid…",
            style:
                TextStyle(fontSize: 13, color: AppColors.ink3),
          ),
        ],
      ),
    );
  }

  Widget _allDone() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "That's the whole grid",
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.displayFallback,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "If nothing matched, you can review skipped posts or jump "
            'straight into generation.',
            style: TextStyle(fontSize: 14, color: AppColors.ink3),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Review skipped'),
                onPressed: () async {
                  await _c.loadInspirationFeed();
                  if (mounted) setState(() => _index = 0);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardPreview extends StatelessWidget {
  final String imageUrl;
  final String caption;
  final String ownerHandle;
  const _CardPreview({
    required this.imageUrl,
    required this.caption,
    required this.ownerHandle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 5,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.surface2),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surface2,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported_outlined,
                      color: AppColors.ink4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '@$ownerHandle',
                    style: TextStyle(
                      fontFamily: AppFonts.mono,
                      fontFamilyFallback: AppFonts.monoFallback,
                      fontSize: 12,
                      color: AppColors.ink3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    caption,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.ink2,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
