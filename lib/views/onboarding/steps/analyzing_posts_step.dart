import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/network/api_config.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/post_data_model.dart';
import '../widgets/step_head.dart';
import '../widgets/step_shell.dart';

/// Step (display 5) — mirrors `AnalyzingPostsStep.jsx`. Pure UI animation:
/// steps a scanner across the user's actual recent posts (from /analyze) at
/// 2s/post, then forwards to detected-style. No API call here; posts come
/// from the store populated by step 4's /analyze response.
class AnalyzingPostsStep extends StatefulWidget {
  const AnalyzingPostsStep({super.key});

  @override
  State<AnalyzingPostsStep> createState() => _AnalyzingPostsStepState();
}

class _AnalyzingPostsStepState extends State<AnalyzingPostsStep> {
  final OnboardingController _c = Get.find<OnboardingController>();

  int _currentIdx = 0;
  Timer? _stepTimer;
  Timer? _exitTimer;

  late final List<PostDataModel> _posts;

  @override
  void initState() {
    super.initState();
    // Web caps at 4 to keep the row one-shot and the animation snappy.
    _posts = _c.analyzedPosts.take(4).toList();

    if (_posts.isEmpty) {
      // Nothing to scan — exit promptly so the user isn't stuck.
      _exitTimer = Timer(const Duration(milliseconds: 600), _exit);
      return;
    }

    _stepTimer = Timer.periodic(const Duration(seconds: 2), (t) {
      if (!mounted) return;
      setState(() {
        _currentIdx = _currentIdx >= _posts.length
            ? _currentIdx
            : _currentIdx + 1;
      });
      if (_currentIdx >= _posts.length) {
        t.cancel();
        _exitTimer = Timer(const Duration(seconds: 1), _exit);
      }
    });
  }

  void _exit() {
    if (!mounted) return;
    _c.completeAnalyzingPosts();
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _exitTimer?.cancel();
    super.dispose();
  }

  _PostState _stateAt(int i) {
    if (i < _currentIdx) return _PostState.analyzed;
    if (i == _currentIdx) return _PostState.scanning;
    return _PostState.queued;
  }

  @override
  Widget build(BuildContext context) {
    final handle = (_c.instagramHandle.value ?? '').trim();
    final total = _posts.length;
    final allDone = _currentIdx >= total;
    final headlineText = total == 0
        ? 'Reading your recent posts'
        : allDone
            ? 'All posts analyzed'
            : 'Analyzing post ${_currentIdx + 1} of $total';

    return StepShell(
      head: StepHead(
        eyebrow: 'Step 5 of 8 · Studying your feed',
        title: total == 0
            ? 'Reading your recent posts'
            : 'Reading your $total latest posts',
        sub: "We're sampling colors, captions, and engagement signals from "
            'your most recent posts to ground every recommendation.',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LiveBadge(handle: handle),
          const SizedBox(height: 16),
          if (total == 0)
            const _EmptyState()
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.66,
              ),
              itemCount: total,
              itemBuilder: (ctx, i) => _PostScanCard(
                index: i,
                post: _posts[i],
                state: _stateAt(i),
              ),
            ),
          const SizedBox(height: 16),
          _BottomLogStrip(headline: headlineText),
        ],
      ),
    );
  }
}

enum _PostState { queued, scanning, analyzed }

class _LiveBadge extends StatelessWidget {
  final String handle;
  const _LiveBadge({required this.handle});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.35),
                    blurRadius: 0,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Live · ${handle.isEmpty ? 'your account' : '@$handle'}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.ink2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostScanCard extends StatelessWidget {
  final int index;
  final PostDataModel post;
  final _PostState state;
  const _PostScanCard({
    required this.index,
    required this.post,
    required this.state,
  });

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

  String get _proxiedImage {
    if (post.displayUrl.isEmpty) return '';
    return '${ApiConfig.onboardingProfileImage}?url=${Uri.encodeComponent(post.displayUrl)}';
  }

  ({Color bg, Color fg, Color dot, String label}) get _stateChip {
    switch (state) {
      case _PostState.analyzed:
        return (
          bg: const Color(0xFFE9F0E5),
          fg: const Color(0xFF3E5B36),
          dot: const Color(0xFF5A7A4A),
          label: 'Analyzed',
        );
      case _PostState.scanning:
        return (
          bg: AppColors.accentSoft,
          fg: AppColors.accentInk,
          dot: AppColors.accent,
          label: 'Scanning',
        );
      case _PostState.queued:
        return (
          bg: AppColors.surface,
          fg: AppColors.ink3,
          dot: AppColors.ink4,
          label: 'Queued',
        );
    }
  }

  String _metric() {
    switch (state) {
      case _PostState.analyzed:
        return '${_formatCount(post.likeCount)} likes';
      case _PostState.scanning:
        return 'Sampling colors…';
      case _PostState.queued:
        return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final chip = _stateChip;
    final scanning = state == _PostState.scanning;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: AppColors.surface),
                  if (_proxiedImage.isNotEmpty)
                    Image.network(
                      _proxiedImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surface2,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported_outlined,
                            color: AppColors.ink4),
                      ),
                    ),
                  // Type badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xCC1C1B19),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _typeLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                  // Index
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: const TextStyle(
                          fontFamily: AppFonts.mono,
                          fontFamilyFallback: AppFonts.monoFallback,
                          fontSize: 10,
                          color: AppColors.ink2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Scanning overlay
                  if (scanning) ...[
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.accent.withValues(alpha: 0),
                              AppColors.accent.withValues(alpha: 0.18),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: _ScanLine(),
                      ),
                    ),
                    ..._cornerBrackets(),
                  ],
                  // Analyzed check
                  if (state == _PostState.analyzed)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3E5B36),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            size: 14, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.caption.isEmpty ? 'Untitled post' : post.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      color: AppColors.ink2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: chip.bg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: chip.dot,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              chip.label,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: chip.fg,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          _metric(),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppFonts.mono,
                            fontFamilyFallback: AppFonts.monoFallback,
                            fontSize: 10.5,
                            color: AppColors.ink3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Iterable<Widget> _cornerBrackets() {
    const dim = 12.0;
    const sw = 2.0;
    return [
      Positioned(
        top: 6,
        left: 6,
        child: SizedBox(
          width: dim,
          height: dim,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.accent, width: sw),
                left: BorderSide(color: AppColors.accent, width: sw),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        top: 6,
        right: 6,
        child: SizedBox(
          width: dim,
          height: dim,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.accent, width: sw),
                right: BorderSide(color: AppColors.accent, width: sw),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 6,
        left: 6,
        child: SizedBox(
          width: dim,
          height: dim,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.accent, width: sw),
                left: BorderSide(color: AppColors.accent, width: sw),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 6,
        right: 6,
        child: SizedBox(
          width: dim,
          height: dim,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.accent, width: sw),
                right: BorderSide(color: AppColors.accent, width: sw),
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

class _ScanLine extends StatefulWidget {
  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Align(
          alignment: Alignment(0, -1 + 2 * _ctrl.value),
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0),
                  AppColors.accent,
                  AppColors.accent.withValues(alpha: 0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BottomLogStrip extends StatelessWidget {
  final String headline;
  const _BottomLogStrip({required this.headline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.accentSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome,
                size: 14, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '✓ Signals · ⤳ Colors · — Tone',
                  style: TextStyle(
                    fontFamily: AppFonts.mono,
                    fontFamilyFallback: AppFonts.monoFallback,
                    fontSize: 11,
                    color: AppColors.ink3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.center,
      child: const Column(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.accent,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Loading recent posts…',
            style: TextStyle(color: AppColors.ink3, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

String _formatCount(num n) {
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return n.toString();
}
