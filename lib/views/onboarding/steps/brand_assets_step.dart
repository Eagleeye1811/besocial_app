import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controllers/onboarding_controller/onboarding_controller.dart';
import '../../../core/network/api_config.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../repository/session_repository/session_repository.dart';
import '../widgets/foot_bar.dart';
import '../widgets/step_head.dart';
import '../widgets/step_shell.dart';

/// Step 7 — mirrors `BrandAssetsStep.jsx`.
///
/// Three optional upload groups: people photos (up to 4, circular thumbs),
/// product/space photos (up to 4, square thumbs), brand logo (one).
/// Each upload posts to `POST /api/v1/onboarding/assets/upload` via
/// `controller.uploadAsset(kind, slot, file)` which returns a relative
/// asset URL. Previews are fetched against the auth-gated `/uploads`
/// route with `?t=<session_token>` appended, mirroring the web pattern
/// (browser <img> can't attach Authorization headers, and Flutter's
/// `Image.network` doesn't ride Dio's interceptors either).
///
/// Mobile adaptation: the web's side-by-side 2-column layout (people +
/// products on the left, logo + reassurance on the right) is stacked
/// vertically with each group rendered as a self-contained `_UploadGroup`
/// card. The per-group grids are tuned for phone widths: 4 circular
/// 72×72 slots for people; 3 square ~100px slots for products; one
/// full-width tile for logo.
class BrandAssetsStep extends StatefulWidget {
  const BrandAssetsStep({super.key});

  @override
  State<BrandAssetsStep> createState() => _BrandAssetsStepState();
}

class _BrandAssetsStepState extends State<BrandAssetsStep> {
  final OnboardingController _c = Get.find<OnboardingController>();
  final SessionRepository _session = GetIt.I<SessionRepository>();
  final ImagePicker _picker = ImagePicker();

  // Local asset state. Kept in the view (not the controller) because
  // back-nav from /fetching-posts is one-way in the wizard and these
  // values are also stored server-side — re-fetchable from the brand
  // profile post-onboarding.
  _AssetItem? _logo;
  final List<_AssetItem> _people = <_AssetItem>[];
  final List<_AssetItem> _products = <_AssetItem>[];

  // Per-slot uploading + error state. Key format: 'logo' | 'people:<i>' |
  // 'products:<i>'.
  final Set<String> _uploading = <String>{};
  final Map<String, String> _errors = <String, String>{};

  String? _sessionToken;

  static const int _maxPeople = 4;
  static const int _maxProducts = 4;

  @override
  void initState() {
    super.initState();
    _session.getSessionToken().then((t) {
      if (!mounted) return;
      setState(() => _sessionToken = t);
    });
  }

  String _previewUrl(String relativeUrl) {
    // Backend returns paths like `/uploads/{sid}/logo.png` mounted under the
    // /api/v1/onboarding prefix. The /uploads route is auth-gated; for
    // Image.network previews (no header support) we attach the session
    // token as ?t=.
    final base =
        '${ApiConfig.baseUrl}/api/v1/onboarding$relativeUrl';
    if (_sessionToken == null) return base;
    return '$base?t=${Uri.encodeQueryComponent(_sessionToken!)}';
  }

  // ---------------------------------------------------------------------------
  // Upload handlers
  // ---------------------------------------------------------------------------

  Future<void> _pickAndUploadLogo() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) return;

    setState(() {
      _uploading.add('logo');
      _errors.remove('logo');
    });

    final result = await _c.uploadAsset(
      kind: 'logo',
      slot: null,
      file: File(picked.path),
    );

    if (!mounted) return;
    setState(() {
      _uploading.remove('logo');
      if (result != null) {
        _logo = _AssetItem(url: result.url, filename: _basename(picked.path));
      } else {
        _errors['logo'] =
            _c.errorMessage.value ?? 'Upload failed. Try again.';
      }
    });
  }

  Future<void> _pickAndUploadMulti({
    required String kind,
    required List<_AssetItem> bucket,
    required int max,
  }) async {
    final picked = await _picker.pickMultiImage(imageQuality: 90);
    if (picked.isEmpty) return;

    final available = max - bucket.length;
    if (available <= 0) return;

    final batch = picked.take(available).toList();
    for (int i = 0; i < batch.length; i++) {
      final file = batch[i];
      final slot = bucket.length;
      final key = '$kind:$slot';

      setState(() {
        _uploading.add(key);
        _errors.remove(key);
      });

      final result = await _c.uploadAsset(
        kind: kind,
        slot: slot,
        file: File(file.path),
      );

      if (!mounted) return;
      setState(() {
        _uploading.remove(key);
        if (result != null) {
          bucket.add(
            _AssetItem(url: result.url, filename: _basename(file.path)),
          );
        } else {
          _errors[key] =
              _c.errorMessage.value ?? 'Upload failed. Try again.';
        }
      });
    }
  }

  String _basename(String path) =>
      path.split(Platform.pathSeparator).last.split('/').last;

  bool get _hasAssets =>
      _logo != null || _people.isNotEmpty || _products.isNotEmpty;

  String? _aggregateError(String prefix) {
    final messages = _errors.entries
        .where((e) => e.key.startsWith(prefix) && e.value.isNotEmpty)
        .map((e) => e.value)
        .toList();
    return messages.isEmpty ? null : messages.last;
  }

  bool _isUploading(String prefix) =>
      _uploading.any((k) => k.startsWith(prefix));

  @override
  Widget build(BuildContext context) {
    return StepShell(
      head: const StepHead(
        eyebrow: 'Step 7 of 8',
        title: 'Add a few of your real assets',
        sub:
            "Photos of you, your team, your space, your products — and your logo. We'll weave them into post designs so the feed feels truly yours.",
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _UploadGroup(
            icon: Icons.people_outline,
            eyebrow: 'YOUR FACE & TEAM',
            title: 'People photos',
            hint:
                'Headshots and candid shots — used for testimonial frames, founder posts, and team intros.',
            optional: true,
            ctaLabel: 'Add headshot',
            onCta: _people.length < _maxPeople &&
                    !_isUploading('people:')
                ? () => _pickAndUploadMulti(
                      kind: 'people',
                      bucket: _people,
                      max: _maxPeople,
                    )
                : null,
            errorMessage: _aggregateError('people:'),
            child: _PeopleGrid(
              items: _people,
              maxSlots: _maxPeople,
              previewUrl: _previewUrl,
              uploading: _isUploading('people:'),
              onRemove: (i) => setState(() => _people.removeAt(i)),
              onAdd: () => _pickAndUploadMulti(
                kind: 'people',
                bucket: _people,
                max: _maxPeople,
              ),
            ),
          ),
          const SizedBox(height: 14),

          _UploadGroup(
            icon: Icons.photo_camera_outlined,
            eyebrow: 'PRODUCTS & SPACE',
            title: 'Product or asset photos',
            hint:
                'Anything you want to feature — products, interiors, raw materials, or before/after shots.',
            optional: true,
            ctaLabel: 'Upload assets',
            onCta: _products.length < _maxProducts &&
                    !_isUploading('products:')
                ? () => _pickAndUploadMulti(
                      kind: 'products',
                      bucket: _products,
                      max: _maxProducts,
                    )
                : null,
            errorMessage: _aggregateError('products:'),
            child: _ProductGrid(
              items: _products,
              maxSlots: _maxProducts,
              previewUrl: _previewUrl,
              uploading: _isUploading('products:'),
              onRemove: (i) => setState(() => _products.removeAt(i)),
              onAdd: () => _pickAndUploadMulti(
                kind: 'products',
                bucket: _products,
                max: _maxProducts,
              ),
            ),
          ),
          const SizedBox(height: 14),

          _UploadGroup(
            icon: Icons.auto_awesome_outlined,
            eyebrow: 'BRAND MARK',
            title: 'Brand logo',
            hint:
                "SVG or transparent PNG works best. We'll auto-fit it onto covers, watermarks, and templates.",
            errorMessage: _errors['logo'],
            child: _logo != null
                ? _LogoCard(
                    asset: _logo!,
                    previewUrl: _previewUrl,
                    onReplace: _uploading.contains('logo')
                        ? null
                        : _pickAndUploadLogo,
                    onRemove: () => setState(() => _logo = null),
                  )
                : _LogoUploadTile(
                    uploading: _uploading.contains('logo'),
                    onTap: _uploading.contains('logo')
                        ? null
                        : _pickAndUploadLogo,
                  ),
          ),
          const SizedBox(height: 16),

          const _PrivacyReassurance(),
          const SizedBox(height: 4),
        ],
      ),
      footer: FootBar(
        left: Text(
          _hasAssets
              ? 'Looking good — add more or continue'
              : 'You can add brand assets later from settings',
          style: const TextStyle(fontSize: 13, color: AppColors.ink3),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        primary: FootBarPrimaryButton(
          label: 'Continue',
          icon: Icons.arrow_forward,
          onPressed: _c.completeBrandAssets,
        ),
      ),
    );
  }
}

// ============================================================================
// _AssetItem
// ============================================================================

class _AssetItem {
  final String url;
  final String filename;
  const _AssetItem({required this.url, required this.filename});
}

// ============================================================================
// _UploadGroup — the cardlike container with icon chip + eyebrow + title +
// hint + optional CTA in the header, then arbitrary content + error below.
// ============================================================================

class _UploadGroup extends StatelessWidget {
  const _UploadGroup({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.hint,
    required this.child,
    this.optional = false,
    this.ctaLabel,
    this.onCta,
    this.errorMessage,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String hint;
  final Widget child;
  final bool optional;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: AppColors.ink2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            eyebrow,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppFonts.mono,
                              fontFamilyFallback: AppFonts.monoFallback,
                              fontSize: 10.5,
                              letterSpacing: 0.5,
                              color: AppColors.ink4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (optional) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Optional',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: AppColors.ink4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppFonts.display,
                        fontFamilyFallback: AppFonts.displayFallback,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hint,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.ink3,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (ctaLabel != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: _GhostButton(
                icon: Icons.add,
                label: ctaLabel!,
                onPressed: onCta,
              ),
            ),
          ],
          const SizedBox(height: 14),
          child,
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: const TextStyle(fontSize: 12, color: AppColors.ink2),
            ),
          ],
        ],
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13, color: AppColors.ink2),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
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
// People grid — 4 circular slots in a row.
// ============================================================================

class _PeopleGrid extends StatelessWidget {
  const _PeopleGrid({
    required this.items,
    required this.maxSlots,
    required this.previewUrl,
    required this.uploading,
    required this.onRemove,
    required this.onAdd,
  });

  final List<_AssetItem> items;
  final int maxSlots;
  final String Function(String) previewUrl;
  final bool uploading;
  final ValueChanged<int> onRemove;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      tiles.add(_ThumbTile(
        previewUrl: previewUrl(items[i].url),
        label: items[i].filename,
        circle: true,
        onRemove: () => onRemove(i),
      ));
    }
    if (items.length < maxSlots) {
      tiles.add(_AddSlot(
        circle: true,
        uploading: uploading,
        onTap: onAdd,
      ));
    }
    while (tiles.length < maxSlots) {
      tiles.add(const _EmptySlot(circle: true));
    }

    return Row(
      children: List.generate(maxSlots * 2 - 1, (i) {
        if (i.isOdd) return const SizedBox(width: 8);
        return Expanded(child: tiles[i ~/ 2]);
      }),
    );
  }
}

// ============================================================================
// Product grid — 3 square slots per row, wraps to next row at 4th.
// ============================================================================

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({
    required this.items,
    required this.maxSlots,
    required this.previewUrl,
    required this.uploading,
    required this.onRemove,
    required this.onAdd,
  });

  final List<_AssetItem> items;
  final int maxSlots;
  final String Function(String) previewUrl;
  final bool uploading;
  final ValueChanged<int> onRemove;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      tiles.add(_ThumbTile(
        previewUrl: previewUrl(items[i].url),
        label: items[i].filename,
        onRemove: () => onRemove(i),
      ));
    }
    if (items.length < maxSlots) {
      tiles.add(_AddSlot(uploading: uploading, onTap: onAdd));
    }

    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: tiles,
    );
  }
}

// ============================================================================
// Thumb tile — image preview with remove badge + optional caption.
// ============================================================================

class _ThumbTile extends StatelessWidget {
  const _ThumbTile({
    required this.previewUrl,
    required this.label,
    required this.onRemove,
    this.circle = false,
  });

  final String previewUrl;
  final String label;
  final VoidCallback onRemove;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(circle ? 999 : 10),
            child: Container(
              color: AppColors.surface,
              child: Image.network(
                previewUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 18,
                    color: AppColors.ink4,
                  ),
                ),
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.ink3,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(Icons.close,
                    size: 11, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Add slot — dashed-bordered tile that opens the picker.
// ============================================================================

class _AddSlot extends StatelessWidget {
  const _AddSlot({
    required this.uploading,
    required this.onTap,
    this.circle = false,
  });

  final bool uploading;
  final VoidCallback? onTap;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: uploading ? null : onTap,
          borderRadius: BorderRadius.circular(circle ? 999 : 10),
          child: DottedBorderBox(
            radius: circle ? 999 : 10,
            child: Center(
              child: uploading
                  ? Text(
                      'Uploading…',
                      style: TextStyle(
                        fontFamily: AppFonts.mono,
                        fontFamilyFallback: AppFonts.monoFallback,
                        fontSize: 10,
                        color: AppColors.ink3,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add,
                          size: circle ? 18 : 20,
                          color: AppColors.ink3,
                        ),
                        if (!circle) ...[
                          const SizedBox(height: 2),
                          const Text(
                            'Add',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.ink3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({this.circle = false});
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(circle ? 999 : 10),
          border: Border.all(color: AppColors.line2),
        ),
      ),
    );
  }
}

/// A subtle dashed-style border container. CustomPaint-based for proper
/// dashed look (Flutter's Border doesn't render dashes natively).
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({
    super.key,
    required this.child,
    this.radius = 10,
  });

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedPainter(radius: radius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          color: AppColors.surface,
          padding: const EdgeInsets.all(8),
          child: child,
        ),
      ),
    );
  }
}

class _DashedPainter extends CustomPainter {
  _DashedPainter({required this.radius});
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.line;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dash = 4.0;
    const gap = 3.5;
    for (final m in path.computeMetrics()) {
      double dist = 0;
      while (dist < m.length) {
        final next = (dist + dash).clamp(0, m.length).toDouble();
        canvas.drawPath(m.extractPath(dist, next), paint);
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPainter old) => old.radius != radius;
}

// ============================================================================
// Logo card / upload tile
// ============================================================================

class _LogoCard extends StatelessWidget {
  const _LogoCard({
    required this.asset,
    required this.previewUrl,
    required this.onReplace,
    required this.onRemove,
  });

  final _AssetItem asset;
  final String Function(String) previewUrl;
  final VoidCallback? onReplace;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Logo preview with a subtle checker-ish surface
          Container(
            width: 76,
            height: 76,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                color: AppColors.white,
                child: Image.network(
                  previewUrl(asset.url),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    size: 18,
                    color: AppColors.ink4,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  asset.filename,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Uploaded',
                  style: TextStyle(
                    fontFamily: AppFonts.mono,
                    fontFamilyFallback: AppFonts.monoFallback,
                    fontSize: 11,
                    color: AppColors.ink3,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _GhostButton(
                      icon: Icons.refresh,
                      label: 'Replace',
                      onPressed: onReplace,
                    ),
                    const SizedBox(width: 6),
                    _GhostButton(
                      icon: Icons.close,
                      label: 'Remove',
                      onPressed: onRemove,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoUploadTile extends StatelessWidget {
  const _LogoUploadTile({required this.uploading, required this.onTap});

  final bool uploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: DottedBorderBox(
          radius: 14,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.line2),
                  ),
                  child: uploading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.ink3,
                          ),
                        )
                      : const Icon(Icons.add,
                          size: 20, color: AppColors.ink2),
                ),
                const SizedBox(height: 10),
                Text(
                  uploading ? 'Uploading…' : 'Upload your logo',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'SVG / PNG · up to 5 MB',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.ink3,
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
// Privacy reassurance card (bottom)
// ============================================================================

class _PrivacyReassurance extends StatelessWidget {
  const _PrivacyReassurance();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        border: Border.all(color: AppColors.line2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined,
              size: 15, color: AppColors.accentInk),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Private by default',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentInk,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Your assets are encrypted and only used to generate your posts. Never used to train models or shared with third parties.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.ink2,
                    height: 1.45,
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
