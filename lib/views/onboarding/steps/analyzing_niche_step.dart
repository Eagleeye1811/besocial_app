import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../widgets/step_shell.dart';

/// Loading screen between step 3 and step 4. Mirrors
/// `frontend/src/features/onboarding/steps/AnalyzingNicheStep.jsx`:
/// sparkle icon with a rotating arc-ring, a centered "Studying your niche…"
/// headline, a 4-row checklist that advances through idle → doing → done,
/// and a "Did you know?" tip strip. Real navigation is still driven by the
/// /analyze API call (kicked off in initState).
class AnalyzingNicheStep extends StatefulWidget {
  const AnalyzingNicheStep({super.key});

  @override
  State<AnalyzingNicheStep> createState() => _AnalyzingNicheStepState();
}

class _AnalyzingNicheStepState extends State<AnalyzingNicheStep>
    with TickerProviderStateMixin {
  final OnboardingController _c = Get.find<OnboardingController>();

  static const List<({String label, String detail})> _steps = [
    (label: 'Finding your niche', detail: "Women's salon · Luxury"),
    (label: 'Studying the market', detail: 'Mumbai · 240 competitors'),
    (label: 'Discovering audience', detail: 'Reading 1,420 signals…'),
    (label: 'Preparing strategy', detail: 'Synthesizing recommendations'),
  ];

  int _currentIdx = 0;
  Timer? _tick;
  late final AnimationController _ringCtrl;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _tick = Timer.periodic(const Duration(milliseconds: 1000), (t) {
      if (!mounted) return;
      if (_currentIdx >= _steps.length - 1) {
        t.cancel();
        return;
      }
      setState(() => _currentIdx += 1);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _c.beginAnalysis());
  }

  @override
  void dispose() {
    _tick?.cancel();
    _ringCtrl.dispose();
    _c.cancelAnalysis();
    super.dispose();
  }

  _StepStatus _statusFor(int i) {
    if (i < _currentIdx) return _StepStatus.done;
    if (i == _currentIdx) return _StepStatus.doing;
    return _StepStatus.idle;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final availableHeight =
        media.size.height - media.padding.top - media.padding.bottom - 36;

    return StepShell(
      showAppBar: false,
      body: ConstrainedBox(
        constraints: BoxConstraints(minHeight: availableHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Header(ringCtrl: _ringCtrl),
            const SizedBox(height: 28),
            _ChecklistCard(statusFor: _statusFor, steps: _steps),
            const SizedBox(height: 16),
            const _DidYouKnowStrip(),
            const SizedBox(height: 12),
            Obx(() {
              final err = _c.errorMessage.value;
              if (err == null) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line),
                ),
                child: Text(
                  err,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.ink2,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

enum _StepStatus { idle, doing, done }

/// Sparkle icon centered in a white rounded-rect card, with a rotating
/// orange arc-ring orbiting it. Mirrors the SVG `<animateTransform>` ring
/// from the web reference.
class _Header extends StatelessWidget {
  const _Header({required this.ringCtrl});

  final AnimationController ringCtrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 92,
          height: 92,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Halo behind the badge
              Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x1AF47B42), Color(0x00F47B42)],
                    stops: [0.0, 0.7],
                  ),
                ),
              ),
              // Badge
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.line),
                  boxShadow: AppShadows.cardHi,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 28,
                  color: AppColors.accent,
                ),
              ),
              // Rotating arc ring
              AnimatedBuilder(
                animation: ringCtrl,
                builder: (_, __) => CustomPaint(
                  size: const Size(92, 92),
                  painter: _RingPainter(progress: ringCtrl.value),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Studying your niche…',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontFamilyFallback: AppFonts.displayFallback,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Usually takes 20–30 seconds. Don’t close the app.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            color: AppColors.ink3,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 1;
    final base = Paint()
      ..color = AppColors.line2
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, base);

    final arc = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final start = (progress * 2 * math.pi) - (math.pi / 2);
    const sweep = math.pi * 0.9;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({
    required this.statusFor,
    required this.steps,
  });

  final _StepStatus Function(int) statusFor;
  final List<({String label, String detail})> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          for (int i = 0; i < steps.length; i++)
            _ChecklistRow(
              label: steps[i].label,
              detail: steps[i].detail,
              status: statusFor(i),
              isLast: i == steps.length - 1,
            ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.label,
    required this.detail,
    required this.status,
    required this.isLast,
  });

  final String label;
  final String detail;
  final _StepStatus status;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isIdle = status == _StepStatus.idle;
    final isDoing = status == _StepStatus.doing;
    final isDone = status == _StepStatus.done;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDoing ? AppColors.accentSoft.withValues(alpha: 0.35) : null,
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: AppColors.line2),
        ),
      ),
      child: Row(
        children: [
          _StatusDot(status: status),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isIdle ? FontWeight.w500 : FontWeight.w600,
                    color: isIdle ? AppColors.ink4 : AppColors.ink,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDone ? AppColors.ink3 : AppColors.ink3,
                  ),
                ),
              ],
            ),
          ),
          if (isDoing) ...[
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'WORKING',
                style: TextStyle(
                  fontFamily: AppFonts.mono,
                  fontFamilyFallback: AppFonts.monoFallback,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentInk,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          if (isDone) ...[
            const SizedBox(width: 8),
            Text(
              'DONE',
              style: TextStyle(
                fontFamily: AppFonts.mono,
                fontFamilyFallback: AppFonts.monoFallback,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.good,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final _StepStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case _StepStatus.done:
        return Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.ink,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.check, size: 13, color: Colors.white),
        );
      case _StepStatus.doing:
        return Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.accentSoft,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.8,
              color: AppColors.accent,
            ),
          ),
        );
      case _StepStatus.idle:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.line, width: 1.5),
          ),
        );
    }
  }
}

class _DidYouKnowStrip extends StatelessWidget {
  const _DidYouKnowStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.bolt, size: 16, color: AppColors.accent),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.ink3,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: 'Did you know? ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink2,
                    ),
                  ),
                  const TextSpan(
                    text:
                        'Salons in Mumbai post on average 4.2× per week. We’ll suggest a cadence that fits you.',
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
