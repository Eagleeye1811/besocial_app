import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/shortlist_controller/shortlist_controller.dart';
import '../../../core/constants/generation_error_copy.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/shortlist_item_model.dart';
import 'mode2_config_sheet.dart';

// State-driven tints (mirrors ShortlistCard.jsx). Greens/reds match the web
// hex values; orange uses the shared accent token.
const Color _greenBorder = Color(0xFFB7DCBE);
const Color _greenBg = Color(0xFFEDF7EE);
const Color _greenInk = Color(0xFF15803D);
const Color _redBorder = Color(0xFFF0C9C0);
const Color _redBg = Color(0xFFFBF1EE);
const Color _redIcon = Color(0xFFE8B6A8);
const Color _redTitle = Color(0xFF8B3A1F);
const Color _redBody = Color(0xFF6B3318);

/// One card in the shortlist. Thumbnail + reference on the left, a fully
/// state-driven action column below. Card border/shadow, the generated
/// badge, the generating status line, and the failed-state error box are all
/// driven by [ShortlistItemModel.generationStatus]. Mirrors the web
/// `ShortlistCard.jsx`, resized for mobile.
class ShortlistCard extends StatelessWidget {
  final ShortlistItemModel item;
  const ShortlistCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShortlistController>();
    final status = item.generationStatus;
    final isGenerating = status == ShortlistGenerationStatus.generating;
    final isGenerated = status == ShortlistGenerationStatus.generated;
    final isFailed = status == ShortlistGenerationStatus.failed;

    final borderColor = isGenerated
        ? _greenBorder
        : isFailed
            ? const Color(0xFFF4C7C7)
            : isGenerating
                ? AppColors.accent
                : AppColors.line;

    final shadow = isGenerating
        ? const [
            BoxShadow(
              color: Color(0x29F47B42),
              offset: Offset(0, 10),
              blurRadius: 26,
            ),
          ]
        : isGenerated
            ? const [
                BoxShadow(
                  color: Color(0x1A15803D),
                  offset: Offset(0, 6),
                  blurRadius: 18,
                ),
              ]
            : isFailed
                ? const [
                    BoxShadow(
                      color: Color(0x1A992A2A),
                      offset: Offset(0, 6),
                      blurRadius: 18,
                    ),
                  ]
                : AppShadows.card;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(
          color: borderColor,
          width: isGenerating ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _thumbnail(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '@${item.authorHandle}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppFonts.ui,
                              fontFamilyFallback: AppFonts.uiFallback,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        if (isGenerated)
                          const _GeneratedBadge()
                        else
                          _ActionMenu(item: item),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: AppColors.ink2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${item.slideCount} slide${item.slideCount == 1 ? '' : 's'} · ${item.format}',
                      style: TextStyle(
                        fontFamily: AppFonts.mono,
                        fontFamilyFallback: AppFonts.monoFallback,
                        fontSize: 10.5,
                        color: AppColors.ink4,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StateActions(item: item, controller: controller),
        ],
      ),
    );
  }

  Widget _thumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 76,
        height: 96,
        child: item.thumbnailUrl == null
            ? Container(
                color: AppColors.surface2,
                alignment: Alignment.center,
                child: const Icon(Icons.image_outlined, color: AppColors.ink4),
              )
            : CachedNetworkImage(
                imageUrl: item.thumbnailUrl!,
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
    );
  }
}

/// The state-driven action block under the card body. Switches between the
/// ready CTA, the generating status panel, the generated success button, and
/// the failed error box.
class _StateActions extends StatelessWidget {
  final ShortlistItemModel item;
  final ShortlistController controller;
  const _StateActions({required this.item, required this.controller});

  void _openCustomize(BuildContext context) {
    Mode2ConfigSheet.show(
      context,
      postId: item.postId,
      controller: controller,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (item.generationStatus) {
      case ShortlistGenerationStatus.ready:
        return _ReadyActions(
          onGenerate: () => controller.generate(item),
          onRemove: () => controller.remove(item),
          onCustomize: () => _openCustomize(context),
        );
      case ShortlistGenerationStatus.generating:
        return const _GeneratingPanel();
      case ShortlistGenerationStatus.generated:
        return _GeneratedActions(
          onRemove: () => controller.remove(item),
        );
      case ShortlistGenerationStatus.failed:
        return _FailedState(
          item: item,
          onRetry: () => controller.generate(item),
          onCustomize: () => _openCustomize(context),
          onRemove: () => controller.remove(item),
        );
    }
  }
}

class _ReadyActions extends StatelessWidget {
  final VoidCallback onGenerate;
  final VoidCallback onRemove;
  final VoidCallback onCustomize;
  const _ReadyActions({
    required this.onGenerate,
    required this.onRemove,
    required this.onCustomize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: onGenerate,
          icon: const Icon(Icons.auto_awesome, size: 16),
          label: const Text('Generate post'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.white,
            minimumSize: const Size(0, 46),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Estimated time · ~60 seconds',
                style: TextStyle(fontSize: 11.5, color: AppColors.ink3),
              ),
            ),
            TextButton(
              onPressed: onCustomize,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
                foregroundColor: AppColors.ink2,
              ),
              child: const Text('Customize', style: TextStyle(fontSize: 12.5)),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onRemove,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 28),
              foregroundColor: AppColors.ink3,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Remove from shortlist',
              style: TextStyle(
                fontSize: 11.5,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GeneratingPanel extends StatelessWidget {
  const _GeneratingPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Generating your post…',
                style: TextStyle(
                  fontFamily: AppFonts.ui,
                  fontFamilyFallback: AppFonts.uiFallback,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.line2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const _PulsingDot(),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Drafting captions and laying out your slides',
                  style: TextStyle(fontSize: 12, color: AppColors.ink2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GeneratedActions extends StatelessWidget {
  final VoidCallback onRemove;
  const _GeneratedActions({required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton(
          onPressed: () => Get.offAllNamed(AppRoutes.drafts),
          style: OutlinedButton.styleFrom(
            backgroundColor: _greenBg,
            foregroundColor: _greenInk,
            minimumSize: const Size(0, 46),
            side: const BorderSide(color: _greenBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _CheckCircle(),
              SizedBox(width: 10),
              Text(
                'View in drafts',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 6),
              Icon(Icons.arrow_forward, size: 15, color: _greenInk),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Generated · ready to schedule',
                style: TextStyle(fontSize: 11.5, color: AppColors.ink3),
              ),
            ),
            TextButton(
              onPressed: onRemove,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 28),
                foregroundColor: AppColors.ink3,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Remove from shortlist',
                style: TextStyle(
                  fontSize: 11.5,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: _greenInk,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.check, size: 13, color: AppColors.white),
    );
  }
}

/// Failed-state body. Reads [ShortlistItemModel.generationErrorCode] /
/// `generationError` and renders the mapped title + message + 1–2 contextual
/// action buttons. Mirrors the web `FailedState`.
class _FailedState extends StatelessWidget {
  final ShortlistItemModel item;
  final VoidCallback onRetry;
  final VoidCallback onCustomize;
  final VoidCallback onRemove;
  const _FailedState({
    required this.item,
    required this.onRetry,
    required this.onCustomize,
    required this.onRemove,
  });

  Widget? _actionButton(GenerationErrorAction? action, {required bool accent}) {
    if (action == null) return null;
    final (icon, label) = switch (action) {
      GenerationErrorAction.retry => (Icons.refresh, 'Try again'),
      GenerationErrorAction.customize => (
          Icons.edit_outlined,
          'Customize this post'
        ),
      GenerationErrorAction.remove => (Icons.close, 'Remove from shortlist'),
    };
    final onPressed = switch (action) {
      GenerationErrorAction.retry => onRetry,
      GenerationErrorAction.customize => onCustomize,
      GenerationErrorAction.remove => onRemove,
    };

    if (accent) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 15),
        label: Text(label, overflow: TextOverflow.ellipsis),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.white,
          minimumSize: const Size(0, 38),
          textStyle:
              const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 15),
      label: Text(label, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink2,
        minimumSize: const Size(0, 38),
        side: const BorderSide(color: AppColors.line),
        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final display =
        resolveGenerationError(item.generationErrorCode, item.generationError);
    final primary = _actionButton(display.primaryAction, accent: true);
    final secondary = _actionButton(display.secondaryAction, accent: false);

    final actions = <Widget>[
      if (secondary != null) Expanded(child: secondary),
      if (secondary != null && primary != null) const SizedBox(width: 8),
      if (primary != null) Expanded(child: primary),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _redBg,
        border: Border.all(color: _redBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: _redIcon,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child:
                    const Icon(Icons.close, size: 14, color: AppColors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      display.title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: _redTitle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      display.message,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.5,
                        color: _redBody,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: actions),
          if (item.generationErrorCode != null) ...[
            const SizedBox(height: 8),
            Text(
              item.generationErrorCode!,
              style: TextStyle(
                fontFamily: AppFonts.mono,
                fontFamilyFallback: AppFonts.monoFallback,
                fontSize: 10,
                color: AppColors.ink4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Top-right "Generated" pill with a check (only shown in the generated
/// state). Sits where the action menu normally lives.
class _GeneratedBadge extends StatelessWidget {
  const _GeneratedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _greenBg,
        border: Border.all(color: _greenBorder),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check, size: 12, color: _greenInk),
          SizedBox(width: 5),
          Text(
            'Generated',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _greenInk,
            ),
          ),
        ],
      ),
    );
  }
}

/// Accent dot that fades in/out — the Flutter approximation of the web's
/// `bs-gen-pulse` keyframe animation.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.3).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final ShortlistItemModel item;
  const _ActionMenu({required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShortlistController>();
    return PopupMenuButton<_CardAction>(
      icon: const Icon(Icons.more_horiz, size: 20, color: AppColors.ink3),
      padding: EdgeInsets.zero,
      onSelected: (action) {
        switch (action) {
          case _CardAction.configure:
            Mode2ConfigSheet.show(
              context,
              postId: item.postId,
              controller: controller,
            );
          case _CardAction.remove:
            controller.remove(item);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
            value: _CardAction.configure, child: Text('Configure style')),
        PopupMenuItem(
            value: _CardAction.remove, child: Text('Remove from shortlist')),
      ],
    );
  }
}

enum _CardAction { configure, remove }
