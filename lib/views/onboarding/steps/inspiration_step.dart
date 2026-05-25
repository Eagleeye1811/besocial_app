import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/network/api_config.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/trending_post_model.dart';
import '../widgets/step_head.dart';
import '../widgets/step_shell.dart';

/// Step 8 — mirrors `InspirationStep.jsx`.
///
/// The web reference renders the inspiration feed as a *grid* (the previous
/// swipe-deck flow was retired). The user picks one post they want to riff
/// on by tapping its Save button; the first save shortlists the post on the
/// backend (`POST /onboarding/swipe action=shortlisted`), seeds
/// `picked_post_id`, and hands off to Google OAuth — generation reads
/// `picked_post_id` after the OAuth callback promotes the session onto the
/// user record. All of that is already wired in
/// [OnboardingController.swipePost].
///
/// Mobile adaptation:
/// - 2-column grid (web uses `auto-fill minmax(220px)` — fits 4–5 across on
///   desktop; phones get 2 across at ~165px wide).
/// - Each card: image with carousel arrows + dot indicator, type/likes
///   badges, owner handle, caption (2-line clamp), Save CTA.
/// - The web's right-rail "How it works" panel collapses into a single
///   compact hint strip above the grid; the "What we're learning" panel
///   is dropped (purely decorative on desktop, would steal vertical space
///   on phone).
/// - Skip button is *not* surfaced (the web's grid version also doesn't
///   surface it — skipping is implicit/scroll-past). The controller still
///   exposes `swipePost(shortlisted: false)` if a polish pass wants to add
///   long-press-to-skip later.
/// - Signup modal is not needed: the mobile `swipePost(true)` auto-fires
///   `_triggerGoogleHandoff` which pushes the in-app OAuth WebView — the
///   in-app flow replaces the web's modal+redirect dance.
class InspirationStep extends StatefulWidget {
  const InspirationStep({super.key});

  @override
  State<InspirationStep> createState() => _InspirationStepState();
}

class _InspirationStepState extends State<InspirationStep> {
  final OnboardingController _c = Get.find<OnboardingController>();

  // Local UI state — not in the controller because it doesn't survive
  // the wizard navigation by design (a fresh grid mount means a fresh
  // pick), and the controller already owns the shortlisted/skipped sets.
  String? _savingId;
  final Map<String, int> _slideIndices = <String, int>{};
  bool _refreshing = false;

  /// Build the proxy URL for an IG CDN image, or return null for an empty
  /// original (so the card can render a graceful placeholder instead of
  /// kicking CachedNetworkImage with a malformed URL).
  String? _proxiedUrl(String original) {
    if (original.trim().isEmpty) return null;
    return '${ApiConfig.baseUrl}/api/v1/onboarding/profile-image?url=${Uri.encodeQueryComponent(original)}';
  }

  String _typeBadge(TrendingPostModel card) {
    if (card.isCarousel) return 'CAROUSEL';
    switch (card.mediaType) {
      case 'GraphVideo':
        return 'VIDEO';
      case 'GraphImage':
        return 'PHOTO';
      default:
        return card.mediaType.isEmpty
            ? 'POST'
            : card.mediaType.toUpperCase();
    }
  }

  String _formatCount(int n) {
    if (n < 1000) return n.toString();
    if (n < 1000000) return '${(n / 1000).toStringAsFixed(n < 10000 ? 1 : 0)}K';
    return '${(n / 1000000).toStringAsFixed(1)}M';
  }

  String _ownerHandle(TrendingPostModel card) =>
      card.ownerUsername.isEmpty ? 'Instagram post' : '@${card.ownerUsername}';

  Future<void> _handleSave(TrendingPostModel card) async {
    if (_savingId != null) return;
    setState(() => _savingId = card.postId);
    await _c.swipePost(postId: card.postId, shortlisted: true);
    // The controller fires the Google handoff inside swipePost on first save,
    // pushing the OAuth WebView and unmounting this view. Clear the flag in
    // case we're still mounted (failure path).
    if (!mounted) return;
    setState(() => _savingId = null);
  }

  Future<void> _refreshDeck() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    await _c.loadInspirationFeed();
    if (!mounted) return;
    setState(() => _refreshing = false);
  }

  void _setSlide(String postId, int idx) =>
      setState(() => _slideIndices[postId] = idx);

  @override
  Widget build(BuildContext context) {
    return StepShell(
      head: const StepHead(
        eyebrow: 'Step 8 of 8 · Inspiration',
        title: 'Your inspiration grid is ready',
        sub:
            "Tap save on what feels right — we'll learn your taste in 60 seconds.",
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            final shortlisted = _c.shortlistedPostIds.toSet();
            return _StatusRow(
              savedCount: shortlisted.length,
              totalInDeck: _c.inspirationFeed.length,
              seenCount: shortlisted.length + _c.skippedPostIds.length,
            );
          }),
          const SizedBox(height: 14),

          const _HowItWorksStrip(),
          const SizedBox(height: 14),

          Obx(() {
            final feed = _c.inspirationFeed.toList();
            final shortlisted = _c.shortlistedPostIds.toSet();
            final skipped = _c.skippedPostIds.toSet();
            final activeDeck = feed
                .where((p) =>
                    !shortlisted.contains(p.postId) &&
                    !skipped.contains(p.postId))
                .toList();

            if (feed.isEmpty) {
              return _LoadingState(refreshing: _refreshing);
            }
            if (activeDeck.isEmpty) {
              return _EmptyDeckState(
                refreshing: _refreshing,
                onReview: _refreshDeck,
              );
            }
            return _Grid(
              cards: activeDeck,
              savingId: _savingId,
              slideIndices: _slideIndices,
              proxiedUrl: _proxiedUrl,
              typeBadge: _typeBadge,
              formatCount: _formatCount,
              ownerHandle: _ownerHandle,
              onSave: _handleSave,
              onSlide: _setSlide,
            );
          }),

          const SizedBox(height: 14),

          Obx(() {
            final err = _c.errorMessage.value;
            if (err == null) return const SizedBox.shrink();
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      err,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================================
// Status row: saved count chip + "X / N" progress.
// ============================================================================

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.savedCount,
    required this.totalInDeck,
    required this.seenCount,
  });

  final int savedCount;
  final int totalInDeck;
  final int seenCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: savedCount > 0
                ? AppColors.accentSoft
                : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color:
                  savedCount > 0 ? AppColors.accentSoft : AppColors.line,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite,
                size: 11,
                color: savedCount > 0
                    ? AppColors.accent
                    : AppColors.ink4,
              ),
              const SizedBox(width: 6),
              Text(
                '$savedCount saved',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: savedCount > 0
                      ? AppColors.accentInk
                      : AppColors.ink3,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          '$seenCount/$totalInDeck',
          style: TextStyle(
            fontFamily: AppFonts.mono,
            fontFamilyFallback: AppFonts.monoFallback,
            fontSize: 11.5,
            color: AppColors.ink3,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// "How it works" compact strip — replaces the desktop right-rail panel.
// ============================================================================

class _HowItWorksStrip extends StatelessWidget {
  const _HowItWorksStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.favorite,
                size: 14, color: AppColors.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.ink2,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: 'Save ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const TextSpan(
                    text:
                        'the post you want to riff on first. Scroll past anything that isn’t your vibe.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Grid of inspiration cards
// ============================================================================

class _Grid extends StatelessWidget {
  const _Grid({
    required this.cards,
    required this.savingId,
    required this.slideIndices,
    required this.proxiedUrl,
    required this.typeBadge,
    required this.formatCount,
    required this.ownerHandle,
    required this.onSave,
    required this.onSlide,
  });

  final List<TrendingPostModel> cards;
  final String? savingId;
  final Map<String, int> slideIndices;
  final String? Function(String) proxiedUrl;
  final String Function(TrendingPostModel) typeBadge;
  final String Function(int) formatCount;
  final String Function(TrendingPostModel) ownerHandle;
  final Future<void> Function(TrendingPostModel) onSave;
  final void Function(String, int) onSlide;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
        // 165px image (1:1) + 145px body breathing room (header 30 + gaps 12
        // + 2-line caption 34 + save button 34 + 20 padding + 15 slack).
        // Bumped from 290 → 310 to clear the ~4px bottom overflow the inner
        // column was reporting on tight phone widths.
        mainAxisExtent: 310,
      ),
      itemBuilder: (_, i) {
        final card = cards[i];
        return _InspirationCard(
          card: card,
          isSaving: savingId == card.postId,
          busy: savingId != null,
          slideIdx: slideIndices[card.postId] ?? 0,
          proxiedUrl: proxiedUrl,
          typeBadge: typeBadge(card),
          likesText: formatCount(card.likeCount),
          commentsText: '${formatCount(card.commentCount)} comments',
          ownerHandle: ownerHandle(card),
          onSave: () => onSave(card),
          onSlide: (idx) => onSlide(card.postId, idx),
        );
      },
    );
  }
}

class _InspirationCard extends StatelessWidget {
  const _InspirationCard({
    required this.card,
    required this.isSaving,
    required this.busy,
    required this.slideIdx,
    required this.proxiedUrl,
    required this.typeBadge,
    required this.likesText,
    required this.commentsText,
    required this.ownerHandle,
    required this.onSave,
    required this.onSlide,
  });

  final TrendingPostModel card;
  final bool isSaving;
  final bool busy;
  final int slideIdx;
  final String? Function(String) proxiedUrl;
  final String typeBadge;
  final String likesText;
  final String commentsText;
  final String ownerHandle;
  final VoidCallback onSave;
  final ValueChanged<int> onSlide;

  List<String> get _slides {
    if (card.isCarousel && card.images.length > 1) return card.images;
    return [card.imageUrl];
  }

  @override
  Widget build(BuildContext context) {
    final slides = _slides;
    final clampedIdx = slideIdx.clamp(0, slides.length - 1);
    final currentUrl = slides[clampedIdx];
    final isCarousel = slides.length > 1;
    final canLeft = isCarousel && clampedIdx > 0;
    final canRight = isCarousel && clampedIdx < slides.length - 1;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isSaving ? 0.6 : 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image area
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: AppColors.surface),
                    // Image: skip the proxy entirely if the original URL is
                    // empty (renders the unavailable placeholder directly).
                    // The /onboarding/profile-image proxy returns HTTP 400
                    // (DISALLOWED_HOST) for non-IG CDN URLs and HTTP 502 for
                    // unreachable CDN URLs — both land in errorWidget.
                    if (proxiedUrl(currentUrl) == null)
                      const _UnavailableImage()
                    else
                      CachedNetworkImage(
                        imageUrl: proxiedUrl(currentUrl)!,
                        key: ValueKey<String>(currentUrl),
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 180),
                        placeholder: (_, __) =>
                            Container(color: AppColors.surface),
                        errorWidget: (context, error, stackTrace) =>
                            const _UnavailableImage(),
                      ),

                    // Carousel arrows
                    if (canLeft)
                      Positioned(
                        left: 6,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _CarouselArrow(
                            icon: Icons.chevron_left,
                            onTap: () => onSlide(clampedIdx - 1),
                          ),
                        ),
                      ),
                    if (canRight)
                      Positioned(
                        right: 6,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _CarouselArrow(
                            icon: Icons.chevron_right,
                            onTap: () => onSlide(clampedIdx + 1),
                          ),
                        ),
                      ),

                    // Dot indicator
                    if (isCarousel)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(slides.length, (i) {
                            final active = i == clampedIdx;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: active ? 12 : 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: active
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x40000000),
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),

                    // Type badge (top-left)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xC71C1B19),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          typeBadge,
                          style: TextStyle(
                            fontFamily: AppFonts.mono,
                            fontFamilyFallback: AppFonts.monoFallback,
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    // Likes badge (top-right)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.favorite_border,
                                size: 10, color: AppColors.ink2),
                            const SizedBox(width: 4),
                            Text(
                              likesText,
                              style: TextStyle(
                                fontFamily: AppFonts.mono,
                                fontFamilyFallback: AppFonts.monoFallback,
                                fontSize: 10,
                                color: AppColors.ink2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Body — Flexible caption (loose fit) lets the text shrink to
              // available height instead of forcing a fixed extent that
              // could overflow when the parent constraint tightens.
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ownerHandle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  commentsText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: AppFonts.mono,
                                    fontFamilyFallback: AppFonts.monoFallback,
                                    fontSize: 10,
                                    color: AppColors.ink3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.camera_alt_outlined,
                            size: 12,
                            color: AppColors.ink3,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          card.caption.isEmpty ? 'No caption' : card.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.ink2,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _SaveButton(
                        isSaving: isSaving,
                        disabled: busy,
                        onTap: onSave,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  const _CarouselArrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.isSaving,
    required this.disabled,
    required this.onTap,
  });

  final bool isSaving;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final effDisabled = disabled || isSaving;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: effDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: effDisabled && !isSaving ? 0.5 : 1,
          child: Container(
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: isSaving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.favorite, size: 13, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// State widgets — loading / empty deck
// ============================================================================

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.refreshing});
  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.line),
            ),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Loading your grid…',
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.displayFallback,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            refreshing
                ? 'Refreshing…'
                : 'Pulling top posts for your niche.',
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.ink3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Neutral placeholder shown when the image URL is empty *or* when the
/// `/profile-image` proxy returns 4xx/5xx (most commonly `DISALLOWED_HOST`
/// for a scraped URL that isn't on the IG CDN allowlist, or
/// `UPSTREAM_UNAVAILABLE` for an expired signed URL). The previous
/// `Icons.broken_image` glyph read as a broken layout — this version is a
/// subtle "no preview" state with a soft gradient and the post's media-type
/// icon, so the card still looks intentional.
class _UnavailableImage extends StatelessWidget {
  const _UnavailableImage();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF1F1F0), Color(0xFFE5E5E2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.image_outlined,
                size: 18,
                color: AppColors.ink3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Preview unavailable',
              style: TextStyle(
                fontFamily: AppFonts.mono,
                fontFamilyFallback: AppFonts.monoFallback,
                fontSize: 10,
                color: AppColors.ink3,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDeckState extends StatelessWidget {
  const _EmptyDeckState({required this.refreshing, required this.onReview});
  final bool refreshing;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.accentSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.refresh,
              size: 24,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "That's the whole grid",
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontFamilyFallback: AppFonts.displayFallback,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Save one to build your first post.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.ink3,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            icon: refreshing
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh, size: 16),
            label: Text(refreshing ? 'Refreshing…' : 'Review the grid'),
            onPressed: refreshing ? null : onReview,
          ),
        ],
      ),
    );
  }
}
