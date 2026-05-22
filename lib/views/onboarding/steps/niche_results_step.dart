import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/foot_bar.dart';
import '../widgets/step_head.dart';
import '../widgets/step_shell.dart';

/// Step 4 — mirrors `NicheResultsStep.jsx`. Shows the full post-analyze
/// snapshot: profile card, niche tiers, performance metrics, then editable
/// hashtags and topics. "Looks good" PATCHes business_type + edited_niche.
class NicheResultsStep extends GetView<OnboardingController> {
  const NicheResultsStep({super.key});

  @override
  Widget build(BuildContext context) {
    return StepShell(
      head: const StepHead(
        eyebrow: 'Analysis complete',
        title: "Here's what we found",
        sub: 'A snapshot of your profile, niche, and how your content is '
            'performing today.',
      ),
      body: Obx(() {
        final n = controller.niche.value;
        if (n == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final profile = controller.profileData.value ?? const {};
        final analysis = controller.analysis.value;
        final displayName = (controller.brandName.value ?? '').trim().isNotEmpty
            ? controller.brandName.value!.trim()
            : 'Your brand';
        final handle = (controller.instagramHandle.value ?? '').trim();
        final city = (controller.brandCity.value ?? '').trim();
        final handleLine = city.isNotEmpty ? '@$handle · $city' : '@$handle';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileCard(
              displayName: displayName,
              handleLine: handleLine,
              biography: profile['biography'] as String?,
              mediaCount: (profile['media_count'] as num?) ?? 0,
              followerCount: (profile['follower_count'] as num?) ?? 0,
              followingCount: (profile['following_count'] as num?) ?? 0,
              dreamNarrative: n.dreamNarrative,
            ),
            const SizedBox(height: 14),
            _NicheTiersCard(
              primary: n.niche,
              sub: n.subNiche,
              micro: n.microNiche,
            ),
            const SizedBox(height: 14),
            _PerformanceCard(
              postsPerWeek: analysis?.postsPerWeek ?? 0,
              followerCount: (profile['follower_count'] as num?) ?? 0,
              followingCount: (profile['following_count'] as num?) ?? 0,
            ),
            const SizedBox(height: 14),
            _HashtagsCard(
              confirmed: controller.confirmedHashtags,
              suggested: controller.suggestedHashtags,
              onTap: controller.toggleHashtag,
            ),
            const SizedBox(height: 14),
            _TopicsCard(
              confirmed: controller.confirmedTopics,
              suggested: controller.suggestedTopics,
              onTap: controller.toggleTopic,
            ),
            Obx(() {
              final err = controller.errorMessage.value;
              if (err == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _ErrorBanner(message: err),
              );
            }),
          ],
        );
      }),
      footer: Obx(() => FootBar(
            left: const Text(
              'You can edit any of this from settings later.',
              style: TextStyle(fontSize: 13, color: AppColors.ink3),
            ),
            primary: FootBarPrimaryButton(
              label: 'Looks good',
              icon: Icons.arrow_forward,
              loading: controller.isLoading.value,
              onPressed: controller.submitNicheEdits,
            ),
          )),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile card — gradient-ring initials avatar, name, handle·city, bio, 3 stats
// + the dream narrative quote on a tinted footer.
// ---------------------------------------------------------------------------

class _ProfileCard extends StatelessWidget {
  final String displayName;
  final String handleLine;
  final String? biography;
  final num mediaCount;
  final num followerCount;
  final num followingCount;
  final String dreamNarrative;

  const _ProfileCard({
    required this.displayName,
    required this.handleLine,
    required this.biography,
    required this.mediaCount,
    required this.followerCount,
    required this.followingCount,
    required this.dreamNarrative,
  });

  String get _initials {
    final src = displayName == 'Your brand'
        ? handleLine.replaceFirst('@', '')
        : displayName;
    if (src.isEmpty) return '?';
    return src.substring(0, src.length < 2 ? 1 : 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GradientRingAvatar(initials: _initials, size: 56),
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
                          fontFamily: AppFonts.display,
                          fontFamilyFallback: AppFonts.displayFallback,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        handleLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppFonts.mono,
                          fontFamilyFallback: AppFonts.monoFallback,
                          fontSize: 12,
                          color: AppColors.ink3,
                        ),
                      ),
                      if ((biography ?? '').isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          biography!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: AppColors.ink2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatCell(label: 'Posts', value: _formatCount(mediaCount)),
                _StatCell(
                    label: 'Followers', value: _formatCount(followerCount)),
                _StatCell(
                    label: 'Following', value: _formatCount(followingCount)),
              ],
            ),
          ),
          if (dreamNarrative.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.line2)),
              ),
              child: Text(
                '"$dreamNarrative"',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontStyle: FontStyle.italic,
                  height: 1.55,
                  color: AppColors.ink2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Niche tiers — three labeled tiles: Primary / Sub / Micro.
// ---------------------------------------------------------------------------

class _NicheTiersCard extends StatelessWidget {
  final String primary;
  final String sub;
  final String micro;
  const _NicheTiersCard({
    required this.primary,
    required this.sub,
    required this.micro,
  });

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _TierTile(
              label: 'Primary niche',
              value: primary,
              accent: false,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _TierTile(label: 'Sub niche', value: sub, accent: true),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _TierTile(
              label: 'Micro niche',
              value: micro,
              accent: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _TierTile extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;
  const _TierTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent ? AppColors.accentSoft : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: AppFonts.mono,
              fontFamilyFallback: AppFonts.monoFallback,
              fontSize: 9.5,
              letterSpacing: 0.5,
              color: AppColors.ink3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.displayFallback,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: accent ? AppColors.accentInk : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Performance card — posts/week + follower:following ratio.
// ---------------------------------------------------------------------------

class _PerformanceCard extends StatelessWidget {
  final double postsPerWeek;
  final num followerCount;
  final num followingCount;
  const _PerformanceCard({
    required this.postsPerWeek,
    required this.followerCount,
    required this.followingCount,
  });

  String get _ratio {
    if (followingCount == 0) return 'N/A';
    final ratio = followerCount / followingCount;
    return ratio.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CURRENT PERFORMANCE',
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontFamilyFallback: AppFonts.monoFallback,
              fontSize: 10.5,
              letterSpacing: 0.5,
              color: AppColors.ink3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Posting consistency',
                  value: postsPerWeek.toStringAsFixed(1),
                  unit: 'posts / week',
                  highlight: false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: 'Follower : Following',
                  value: '$_ratio : 1',
                  unit: 'Healthy ratio',
                  highlight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final bool highlight;
  const _MetricTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppFonts.mono,
              fontFamilyFallback: AppFonts.monoFallback,
              fontSize: 9.5,
              letterSpacing: 0.5,
              color: AppColors.ink3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.displayFallback,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style: TextStyle(
              fontSize: 11.5,
              color: highlight ? AppColors.good : AppColors.ink3,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hashtags card — confirmed (accent chips, tap to remove)
// + suggested (dashed outline, tap to add).
// ---------------------------------------------------------------------------

class _HashtagsCard extends StatelessWidget {
  final List<String> confirmed;
  final List<String> suggested;
  final ValueChanged<String> onTap;
  const _HashtagsCard({
    required this.confirmed,
    required this.suggested,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONFIRMED HASHTAGS',
                      style: TextStyle(
                        fontFamily: AppFonts.mono,
                        fontFamilyFallback: AppFonts.monoFallback,
                        fontSize: 10.5,
                        letterSpacing: 0.5,
                        color: AppColors.ink3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Tap to remove · we'll use these in every post",
                      style: TextStyle(fontSize: 12, color: AppColors.ink2),
                    ),
                  ],
                ),
              ),
              Text(
                '${confirmed.length} active',
                style: const TextStyle(
                  fontFamily: AppFonts.mono,
                  fontFamilyFallback: AppFonts.monoFallback,
                  fontSize: 11,
                  color: AppColors.ink3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (confirmed.isEmpty)
            const Text(
              'None confirmed yet — pick a few from suggested below.',
              style: TextStyle(fontSize: 12, color: AppColors.ink3),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: confirmed
                  .map((t) => _ConfirmedChip(
                        label: '#$t',
                        onTap: () => onTap(t),
                      ))
                  .toList(),
            ),
          if (suggested.isNotEmpty) ...[
            const SizedBox(height: 14),
            const _DashedDivider(),
            const SizedBox(height: 10),
            const Row(
              children: [
                Icon(Icons.auto_awesome, size: 12, color: AppColors.accent),
                SizedBox(width: 4),
                Text(
                  'SUGGESTED · TAP TO ADD',
                  style: TextStyle(
                    fontFamily: AppFonts.mono,
                    fontFamilyFallback: AppFonts.monoFallback,
                    fontSize: 10.5,
                    letterSpacing: 0.5,
                    color: AppColors.ink3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: suggested
                  .map((t) => _SuggestedChip(
                        label: '#$t',
                        onTap: () => onTap(t),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Topics card — confirmed (filled rows with ✕) + suggested (dashed rows with +).
// ---------------------------------------------------------------------------

class _TopicsCard extends StatelessWidget {
  final List<String> confirmed;
  final List<String> suggested;
  final ValueChanged<String> onTap;
  const _TopicsCard({
    required this.confirmed,
    required this.suggested,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONFIRMED KEYWORDS',
                      style: TextStyle(
                        fontFamily: AppFonts.mono,
                        fontFamilyFallback: AppFonts.monoFallback,
                        fontSize: 10.5,
                        letterSpacing: 0.5,
                        color: AppColors.ink3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'The themes our AI will write around',
                      style: TextStyle(fontSize: 12, color: AppColors.ink2),
                    ),
                  ],
                ),
              ),
              Text(
                '${confirmed.length} active',
                style: const TextStyle(
                  fontFamily: AppFonts.mono,
                  fontFamilyFallback: AppFonts.monoFallback,
                  fontSize: 11,
                  color: AppColors.ink3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (confirmed.isEmpty)
            const Text(
              'None confirmed yet — pick a few from suggested below.',
              style: TextStyle(fontSize: 12, color: AppColors.ink3),
            )
          else
            ...confirmed.map((k) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _TopicRow(
                    label: k,
                    confirmed: true,
                    onTap: () => onTap(k),
                  ),
                )),
          if (suggested.isNotEmpty) ...[
            const SizedBox(height: 12),
            const _DashedDivider(),
            const SizedBox(height: 10),
            const Row(
              children: [
                Icon(Icons.auto_awesome, size: 12, color: AppColors.accent),
                SizedBox(width: 4),
                Text(
                  'SUGGESTED KEYWORDS · TAP TO ADD',
                  style: TextStyle(
                    fontFamily: AppFonts.mono,
                    fontFamilyFallback: AppFonts.monoFallback,
                    fontSize: 10.5,
                    letterSpacing: 0.5,
                    color: AppColors.ink3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...suggested.map((k) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _TopicRow(
                    label: k,
                    confirmed: false,
                    onTap: () => onTap(k),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  final String label;
  final bool confirmed;
  final VoidCallback onTap;
  const _TopicRow({
    required this.label,
    required this.confirmed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: confirmed ? AppColors.accentSoft : AppColors.white,
          border: Border.all(
            color: confirmed ? const Color(0xFFF4D7C4) : AppColors.line,
            style: confirmed ? BorderStyle.solid : BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              confirmed ? Icons.check : Icons.add,
              size: 14,
              color: confirmed ? AppColors.accentInk : AppColors.ink3,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: confirmed ? FontWeight.w600 : FontWeight.w500,
                  color: confirmed ? AppColors.accentInk : AppColors.ink2,
                ),
              ),
            ),
            if (confirmed)
              const Icon(Icons.close, size: 14, color: AppColors.accentInk),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared subwidgets.
// ---------------------------------------------------------------------------

class _ConfirmedChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ConfirmedChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.accentSoft,
          border: Border.all(color: AppColors.accent),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.accentInk,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.close, size: 12, color: AppColors.accentInk),
          ],
        ),
      ),
    );
  }
}

class _SuggestedChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestedChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            color: AppColors.line,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 12, color: AppColors.ink3),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.ink2,
              ),
            ),
          ],
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
            fontFamily: AppFonts.display,
            fontFamilyFallback: AppFonts.displayFallback,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
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

class _GradientRingAvatar extends StatelessWidget {
  final String initials;
  final double size;
  const _GradientRingAvatar({required this.initials, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2.5),
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
      child: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.ink,
        ),
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontFamily: AppFonts.display,
            fontFamilyFallback: AppFonts.displayFallback,
            fontSize: size * 0.32,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _CardShell({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: LayoutBuilder(
        builder: (ctx, c) {
          const dashWidth = 4.0;
          const dashGap = 3.0;
          final n = (c.maxWidth / (dashWidth + dashGap)).floor();
          return Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              n,
              (_) => const SizedBox(
                width: dashWidth,
                height: 1,
                child: DecoratedBox(
                    decoration: BoxDecoration(color: AppColors.line)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 13, color: AppColors.ink2),
      ),
    );
  }
}

String _formatCount(num n) {
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return n.toString();
}
