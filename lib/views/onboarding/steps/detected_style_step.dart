import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/network/api_config.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/post_data_model.dart';
import '../widgets/foot_bar.dart';
import '../widgets/step_head.dart';
import '../widgets/step_shell.dart';

/// Step 5 branch — mirrors `DetectedStyleStep.jsx`. The user picks one of
/// two ChoiceCards (`pick` or `custom`). The pick card embeds a thumbnail
/// grid of their own posts; tapping a thumbnail PATCHes `picked_post_id`
/// and selects the card. Continue then routes:
///   - `pick` + post selected  → `colors-voice` (skips StyleSelection)
///   - `custom`                → `style-selection`
class DetectedStyleStep extends GetView<OnboardingController> {
  const DetectedStyleStep({super.key});

  @override
  Widget build(BuildContext context) {
    return StepShell(
      head: const StepHead(
        eyebrow: 'Step 5 of 8 · Analysis complete',
        title: "Pick the visual direction we'll generate from",
        sub: 'Either match a specific post, or set your own from scratch.',
      ),
      body: Obx(() {
        final choice = controller.styleChoice.value;
        final pickedId = controller.pickedPostId.value;
        final posts = controller.analyzedPosts.take(4).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Text(
                'How should we generate your posts?',
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontFamilyFallback: AppFonts.displayFallback,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: AppColors.ink,
                ),
              ),
            ),
            _ChoiceCard(
              active: choice == 'pick',
              tag: 'LEAN INTO A WINNER',
              icon: Icons.grid_view,
              title: 'Match a specific post',
              desc: posts.isEmpty
                  ? "Pick one of your latest posts — we'll lift its colors, "
                      'framing and tone.'
                  : "Pick one of your ${posts.length} latest posts — we'll "
                      'lift its colors, framing and tone.',
              onTap: () => controller.styleChoice.value = 'pick',
              child: posts.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'No recent posts found.',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.ink3),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: _PostThumbGrid(
                        posts: posts,
                        selectedId: choice == 'pick' ? pickedId : null,
                        onPick: controller.pickReferencePost,
                      ),
                    ),
            ),
            const SizedBox(height: 14),
            _ChoiceCard(
              active: choice == 'custom',
              tag: 'START FRESH',
              icon: Icons.auto_fix_high,
              title: 'Set your own visual style',
              desc:
                  'Hand-pick palette, fonts, vibe and references. Best for a '
                  'rebrand or pivot.',
              onTap: () => controller.styleChoice.value = 'custom',
              child: const Padding(
                padding: EdgeInsets.only(top: 14),
                child: _CustomStylePreview(),
              ),
            ),
            Obx(() {
              final err = controller.errorMessage.value;
              if (err == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    err,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.ink2),
                  ),
                ),
              );
            }),
          ],
        );
      }),
      footer: Obx(() {
        final choice = controller.styleChoice.value;
        final pickedId = controller.pickedPostId.value;
        final canContinue =
            (choice == 'custom') || (choice == 'pick' && pickedId != null);
        final hint = switch (choice) {
          'pick' when pickedId != null => 'Using this post as reference',
          'pick' => 'Pick a post to use as reference',
          'custom' => "You'll set your style on the next screen",
          _ => 'Pick a direction to continue',
        };
        return FootBar(
          left: Text(
            hint,
            style: const TextStyle(fontSize: 13, color: AppColors.ink3),
          ),
          primary: FootBarPrimaryButton(
            label: 'Continue',
            icon: Icons.arrow_forward,
            onPressed:
                canContinue ? controller.continueFromDetectedStyle : null,
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Choice card — wraps content with active border / shadow.
// ---------------------------------------------------------------------------

class _ChoiceCard extends StatelessWidget {
  final bool active;
  final String tag;
  final IconData icon;
  final String title;
  final String desc;
  final VoidCallback onTap;
  final Widget child;

  const _ChoiceCard({
    required this.active,
    required this.tag,
    required this.icon,
    required this.title,
    required this.desc,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(
              color: active ? AppColors.accent : AppColors.line,
              width: active ? 1.8 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active ? AppColors.accent : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 15,
                      color: active ? Colors.white : AppColors.ink2,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    tag,
                    style: const TextStyle(
                      fontFamily: AppFonts.mono,
                      fontFamilyFallback: AppFonts.monoFallback,
                      fontSize: 10,
                      letterSpacing: 0.6,
                      color: AppColors.ink3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppFonts.display,
                  fontFamilyFallback: AppFonts.displayFallback,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: AppColors.ink,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.ink3,
                  height: 1.45,
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Post thumbnail grid — 4 across (or fewer). Tap PATCHes picked_post_id.
// ---------------------------------------------------------------------------

class _PostThumbGrid extends StatelessWidget {
  final List<PostDataModel> posts;
  final String? selectedId;
  final ValueChanged<String> onPick;
  const _PostThumbGrid({
    required this.posts,
    required this.selectedId,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        const gap = 6.0;
        final n = posts.length.clamp(1, 4);
        final cellWidth = (c.maxWidth - gap * (n - 1)) / n;
        return Row(
          children: List.generate(posts.length, (i) {
            final p = posts[i];
            return Padding(
              padding: EdgeInsets.only(right: i == posts.length - 1 ? 0 : gap),
              child: SizedBox(
                width: cellWidth,
                child: _PostThumb(
                  post: p,
                  selected: selectedId == p.postId,
                  onTap: () => onPick(p.postId),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _PostThumb extends StatelessWidget {
  final PostDataModel post;
  final bool selected;
  final VoidCallback onTap;
  const _PostThumb({
    required this.post,
    required this.selected,
    required this.onTap,
  });

  String get _proxiedImage {
    if (post.displayUrl.isEmpty) return '';
    return '${ApiConfig.onboardingProfileImage}?url=${Uri.encodeComponent(post.displayUrl)}';
  }

  String get _typeLabel {
    switch (post.mediaType) {
      case 'GraphSidecar':
        return 'CAROUSEL';
      case 'GraphVideo':
        return 'VIDEO';
      case 'GraphImage':
        return 'PHOTO';
      default:
        return post.mediaType.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: selected ? AppColors.accent : AppColors.line,
                  width: selected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.25),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: _proxiedImage.isEmpty
                          ? Container(color: AppColors.surface2)
                          : Image.network(
                              _proxiedImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.surface2,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 16,
                                  color: AppColors.ink4,
                                ),
                              ),
                            ),
                    ),
                    Container(
                      color: AppColors.white,
                      padding:
                          const EdgeInsets.fromLTRB(6, 5, 6, 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _typeLabel,
                            style: const TextStyle(
                              fontFamily: AppFonts.mono,
                              fontFamilyFallback: AppFonts.monoFallback,
                              fontSize: 8.5,
                              letterSpacing: 0.5,
                              color: AppColors.ink4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            post.caption.isEmpty
                                ? 'Untitled post'
                                : post.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink2,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (selected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check,
                      size: 11, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom-style preview row inside ChoiceCard B.
// ---------------------------------------------------------------------------

class _CustomStylePreview extends StatelessWidget {
  const _CustomStylePreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (i) => i)
              .map(
                (_) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Container(
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.line2,
                        border: Border.all(
                          color: AppColors.ink4,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        const Text(
          '+ choose colors, fonts, mood',
          style: TextStyle(
            fontFamily: AppFonts.mono,
            fontFamilyFallback: AppFonts.monoFallback,
            fontSize: 11,
            color: AppColors.ink3,
          ),
        ),
      ],
    );
  }
}
