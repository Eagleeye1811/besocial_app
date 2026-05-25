import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/session_model.dart';
import '../widgets/step_shell.dart';

/// Loading screen between brand-assets and inspiration. Mirrors
/// `FetchingPostsStep.jsx` exactly:
///
/// - Animated rotating message ticker (5 lines, 1.2s per line, rests on last)
/// - Concentric orbiting loader rings (accent + ink, counter-rotating)
/// - "ONE MOMENT" eyebrow + headline + paragraph
/// - Active-message pill (mini orange dot + icon + text) below the loader
/// - 5-segment progress ticker at the bottom (active = wider + ink)
/// - Polls `GET /api/v1/onboarding/session` every 10s, max 48 attempts
///   (= 8 min budget — matches the web's MAX_POLLS so a slow backend run
///   doesn't trip on a too-tight cap)
/// - On `status === 'ready'`: load /feed, advance to inspiration
/// - On `status === 'failed'` or timeout: show retry UI
class FetchingPostsStep extends StatefulWidget {
  const FetchingPostsStep({super.key});

  @override
  State<FetchingPostsStep> createState() => _FetchingPostsStepState();
}

enum _PollOutcome { running, failed, timeout }

class _FetchingPostsStepState extends State<FetchingPostsStep>
    with TickerProviderStateMixin {
  final OnboardingController _c = Get.find<OnboardingController>();

  static const Duration _pollInterval = Duration(seconds: 10);
  static const int _maxPolls = 48; // 48 * 10s = 8 min
  static const Duration _messageInterval = Duration(milliseconds: 1200);

  static const List<({IconData icon, String text})> _messages = [
    (icon: Icons.auto_awesome, text: 'Fetching the best posts for you'),
    (
      icon: Icons.people_outline,
      text: 'Understanding your competitors in your niche'
    ),
    (
      icon: Icons.trending_up,
      text: "Sampling what's trending in your category"
    ),
    (
      icon: Icons.remove_red_eye_outlined,
      text: 'Filtering for posts that match your visual style'
    ),
    (
      icon: Icons.auto_fix_high_outlined,
      text: 'Curating a swipeable deck of inspiration'
    ),
  ];

  int _msgIdx = 0;
  Timer? _msgTimer;
  Timer? _pollTimer;
  bool _started = false;
  bool _cancelled = false;
  int _pollCount = 0;
  _PollOutcome _outcome = _PollOutcome.running;

  late final AnimationController _outerRing;
  late final AnimationController _innerRing;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _outerRing = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _innerRing = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: false);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Rotating message ticker — independent of polling, runs purely as
    // decoration so the user sees motion even if the network is quiet.
    _msgTimer = Timer.periodic(_messageInterval, (t) {
      if (!mounted) return;
      if (_msgIdx >= _messages.length - 1) {
        t.cancel();
        return;
      }
      setState(() => _msgIdx += 1);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _startPolling());
  }

  @override
  void dispose() {
    _cancelled = true;
    _msgTimer?.cancel();
    _pollTimer?.cancel();
    _outerRing.dispose();
    _innerRing.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _startPolling() async {
    if (_started) return;
    _started = true;
    _pollCount = 0;
    _outcome = _PollOutcome.running;
    if (mounted) setState(() {});
    _runPoll();
  }

  Future<void> _runPoll() async {
    if (_cancelled || !mounted) return;
    SessionStatusModel? snapshot;
    try {
      snapshot = await _c.getSessionStatus();
    } on ApiException catch (_) {
      // Single-poll error — log via controller's existing error path is
      // not appropriate here; we just keep retrying like the web does.
      snapshot = null;
    }

    if (_cancelled || !mounted) return;

    if (snapshot != null) {
      if (snapshot.status == SessionStatus.ready) {
        await _c.loadInspirationFeed(); // calls /feed + replaceWithNext
        return;
      }
      if (snapshot.status == SessionStatus.failed) {
        setState(() => _outcome = _PollOutcome.failed);
        return;
      }
    }

    _pollCount += 1;
    if (_pollCount >= _maxPolls) {
      setState(() => _outcome = _PollOutcome.timeout);
      return;
    }

    _pollTimer = Timer(_pollInterval, _runPoll);
  }

  void _retry() {
    _cancelled = false;
    _started = false;
    Get.offAllNamed<void>(AppRoutes.onboardingBrandDetails);
  }

  @override
  Widget build(BuildContext context) {
    return StepShell(
      showAppBar: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _OrbitingLoader(
              outer: _outerRing,
              inner: _innerRing,
            ),
            const SizedBox(height: 28),
            Text(
              'ONE MOMENT',
              style: TextStyle(
                fontFamily: AppFonts.mono,
                fontFamilyFallback: AppFonts.monoFallback,
                fontSize: 11,
                letterSpacing: 0.8,
                color: AppColors.ink4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Building your inspiration deck',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontFamilyFallback: AppFonts.displayFallback,
                fontSize: 26,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.6,
                height: 1.15,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "We're studying what's working for brands like yours so you "
                'can swipe through the best of the best.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.ink3,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _MessagePill(message: _messages[_msgIdx], pulse: _pulse),
            const SizedBox(height: 22),
            _StepTicker(activeIdx: _msgIdx, total: _messages.length),
            const SizedBox(height: 18),
            if (_outcome != _PollOutcome.running)
              _ErrorBox(outcome: _outcome, onRetry: _retry),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// _OrbitingLoader — three rings: static base, accent arc (cw), ink arc (ccw)
// ============================================================================

class _OrbitingLoader extends StatelessWidget {
  const _OrbitingLoader({required this.outer, required this.inner});

  final AnimationController outer;
  final AnimationController inner;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Static base ring
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.line, width: 2),
            ),
          ),
          // Outer rotating accent arc
          AnimatedBuilder(
            animation: outer,
            builder: (_, __) => CustomPaint(
              size: const Size(110, 110),
              painter: _ArcPainter(
                progress: outer.value,
                color: AppColors.accent,
                strokeWidth: 2,
                sweep: math.pi * 0.5,
              ),
            ),
          ),
          // Inner counter-rotating ink arc
          AnimatedBuilder(
            animation: inner,
            builder: (_, __) => CustomPaint(
              size: const Size(82, 82),
              painter: _ArcPainter(
                progress: -inner.value,
                color: AppColors.ink,
                strokeWidth: 2,
                sweep: math.pi * 0.45,
                opacity: 0.7,
              ),
            ),
          ),
          // Center accent chip
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentSoft,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 20,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.sweep,
    this.opacity = 1,
  });

  final double progress;
  final Color color;
  final double strokeWidth;
  final double sweep;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 1;
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final start = (progress * 2 * math.pi) - (math.pi / 2);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.progress != progress || old.color != color;
}

// ============================================================================
// _MessagePill — the rotating "Fetching… Filtering…" pill below the loader
// ============================================================================

class _MessagePill extends StatelessWidget {
  const _MessagePill({required this.message, required this.pulse});

  final ({IconData icon, String text}) message;
  final AnimationController pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: Container(
        key: ValueKey<String>(message.text),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.line),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: pulse,
              builder: (_, __) {
                final scale = 1 + (pulse.value * 0.5);
                final alpha = 1 - (pulse.value * 0.4);
                return Container(
                  width: 8 * scale,
                  height: 8 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withValues(alpha: alpha),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            Icon(message.icon, size: 14, color: AppColors.ink2),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// _StepTicker — 5 progress pills, active one wider + ink-colored
// ============================================================================

class _StepTicker extends StatelessWidget {
  const _StepTicker({required this.activeIdx, required this.total});

  final int activeIdx;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == activeIdx;
        final isPast = i < activeIdx;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 28 : 8,
          height: 4,
          decoration: BoxDecoration(
            color: (isActive || isPast) ? AppColors.ink : AppColors.line,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

// ============================================================================
// _ErrorBox — failed or timeout state with Try-again CTA
// ============================================================================

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.outcome, required this.onRetry});

  final _PollOutcome outcome;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isFailed = outcome == _PollOutcome.failed;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            isFailed
                ? 'We hit a snag building your inspiration deck.'
                : 'This is taking longer than expected.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Go back and try again — your earlier setup is saved.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.ink2,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
