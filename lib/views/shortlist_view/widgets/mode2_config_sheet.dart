import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../controllers/shortlist_controller/shortlist_controller.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/instagram_user_post_model.dart';
import '../../../data/models/mode2_config_model.dart';
import '../../../data/models/shortlist_item_model.dart';
import '../../../repository/instagram_repository/instagram_repository.dart';
import '../../../repository/shortlist_repository/shortlist_repository.dart';
import '../../brand_view/widgets/brand_options.dart';
import 'asset_picker_sheet.dart';

const Duration _kExtractionPollInterval = Duration(milliseconds: 2500);

/// Mode 2 configuration sheet for a shortlist post — full parity with the web
/// `Mode2Panel`.
///
/// `Mode2StyleSource` is the discriminator; each variant gates the override
/// fields, and the Save button assembles a [Mode2ConfigModel] that respects
/// the backend's mutual-exclusivity rules:
///
///   - [Mode2StyleSource.defaultStyle]   → no overrides
///   - [Mode2StyleSource.override]       → requires palette OR tone (≥1)
///   - [Mode2StyleSource.matchOwnPost]   → requires `match_style_post_id`
///   - [Mode2StyleSource.replicateSource]→ no overrides, asset disabled
///
/// Slide texts pre-fill from the source post's OCR (`extractedSlideTexts`) and
/// poll `getShortlist()` while extraction is pending/extracting.
class Mode2ConfigSheet extends StatefulWidget {
  final ShortlistItemModel item;
  final ShortlistController controller;
  final Mode2ConfigModel? initial;

  const Mode2ConfigSheet({
    super.key,
    required this.item,
    required this.controller,
    this.initial,
  });

  static Future<void> show(
    BuildContext context, {
    required String postId,
    required ShortlistController controller,
  }) async {
    // Resolve the full item from the controller's live list so we get
    // slideCount + OCR extraction state. The callers only hand us a postId.
    final item = controller.items.firstWhere(
      (x) => x.postId == postId,
      orElse: () => throw StateError('Shortlist item $postId not found'),
    );
    final initial = await controller.loadConfig(postId);
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Mode2ConfigSheet(
        item: item,
        controller: controller,
        initial: initial,
      ),
    );
  }

  @override
  State<Mode2ConfigSheet> createState() => _Mode2ConfigSheetState();
}

class _Mode2ConfigSheetState extends State<Mode2ConfigSheet> {
  final ShortlistRepository _shortlistRepo = GetIt.I<ShortlistRepository>();

  late Mode2StyleSource _source;
  String? _palette; // null == "None"
  String? _tone; // null == "None"
  String? _matchPostId;
  String? _assetId;

  late int _slideCount;
  late List<TextEditingController> _slideControllers;
  bool _hasUserEditedSlides = false;

  late String _extractionStatus; // pending | extracting | done | failed
  Timer? _pollTimer;

  bool _saving = false;
  bool _savedRecently = false;
  Timer? _savedTimer;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    final item = widget.item;

    _source = init?.styleSource ?? Mode2StyleSource.defaultStyle;
    _palette = init?.paletteOverride;
    _tone = init?.toneOverride;
    _matchPostId = init?.matchStylePostId;
    _assetId = init?.assetId;

    _slideCount = item.slideCount < 1 ? 1 : item.slideCount;
    _extractionStatus = item.extractionStatus ?? 'pending';

    // Seed slide texts: saved edits win; else OCR extraction if done.
    final seed = List<String>.filled(_slideCount, '');
    final saved = init?.editedSlideTexts;
    var hasSavedTexts = false;
    if (saved != null && saved.isNotEmpty) {
      for (var i = 0; i < saved.length && i < _slideCount; i++) {
        seed[i] = saved[i] ?? '';
      }
      hasSavedTexts = seed.any((t) => t.trim().isNotEmpty);
      if (hasSavedTexts) _hasUserEditedSlides = true;
    }
    if (!hasSavedTexts &&
        _extractionStatus == 'done' &&
        (item.extractedSlideTexts?.isNotEmpty ?? false)) {
      final ocr = item.extractedSlideTexts!;
      for (var i = 0; i < ocr.length && i < _slideCount; i++) {
        seed[i] = ocr[i];
      }
    }
    _slideControllers =
        seed.map((t) => TextEditingController(text: t)).toList();

    _maybeStartPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _savedTimer?.cancel();
    for (final c in _slideControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Extraction polling
  // ---------------------------------------------------------------------------
  void _maybeStartPolling() {
    if (_extractionStatus != 'pending' && _extractionStatus != 'extracting') {
      return;
    }
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_kExtractionPollInterval, (_) => _pollTick());
  }

  Future<void> _pollTick() async {
    List<ShortlistItemModel> posts;
    try {
      posts = await _shortlistRepo.getShortlist();
    } on ApiException {
      return; // transient; keep polling on the next tick
    }
    if (!mounted) return;

    ShortlistItemModel? updated;
    for (final p in posts) {
      if (p.postId == widget.item.postId) {
        updated = p;
        break;
      }
    }
    if (updated == null) return;

    final newStatus = updated.extractionStatus ?? 'pending';
    final newTexts = updated.extractedSlideTexts ?? const <String>[];

    setState(() {
      _extractionStatus = newStatus;
      if (newStatus == 'done' &&
          newTexts.isNotEmpty &&
          !_hasUserEditedSlides) {
        for (var i = 0; i < newTexts.length && i < _slideCount; i++) {
          _slideControllers[i].text = newTexts[i];
        }
      }
    });

    if (newStatus == 'done' || newStatus == 'failed') {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  // ---------------------------------------------------------------------------
  // Validation + save
  // ---------------------------------------------------------------------------
  bool get _replicateMode => _source == Mode2StyleSource.replicateSource;

  bool get _isFormValid {
    switch (_source) {
      case Mode2StyleSource.defaultStyle:
      case Mode2StyleSource.replicateSource:
        return true;
      case Mode2StyleSource.override:
        return _palette != null || _tone != null;
      case Mode2StyleSource.matchOwnPost:
        return _matchPostId != null && _matchPostId!.isNotEmpty;
    }
  }

  List<String?>? _buildEditedSlideTexts() {
    final cleaned = _slideControllers
        .map((c) => c.text.trim().isEmpty ? null : c.text)
        .toList();
    return cleaned.any((t) => t != null) ? cleaned : null;
  }

  Future<void> _save() async {
    if (!_isFormValid || _saving) return;
    setState(() => _saving = true);

    final patch = Mode2ConfigModel(
      styleSource: _source,
      paletteOverride: _source == Mode2StyleSource.override ? _palette : null,
      toneOverride: _source == Mode2StyleSource.override ? _tone : null,
      matchStylePostId:
          _source == Mode2StyleSource.matchOwnPost ? _matchPostId : null,
      assetId: _replicateMode ? null : _assetId,
      editedSlideTexts: _buildEditedSlideTexts(),
    );

    final ok = await widget.controller.saveConfig(widget.item.postId, patch);
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      setState(() => _savedRecently = true);
      _savedTimer?.cancel();
      _savedTimer = Timer(const Duration(milliseconds: 2400), () {
        if (mounted) setState(() => _savedRecently = false);
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) => Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                _sectionEyebrow('CUSTOMIZE THIS POST'),
                const SizedBox(height: 4),
                Text(
                  'How should we generate this one?',
                  style: TextStyle(
                    fontFamily: AppFonts.display,
                    fontFamilyFallback: AppFonts.displayFallback,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 18),
                _label('Style source'),
                const SizedBox(height: 10),
                _StyleSourceGrid(
                  value: _source,
                  onChanged: (v) => setState(() => _source = v),
                ),
                if (_source == Mode2StyleSource.override) ...[
                  const SizedBox(height: 20),
                  ..._overrideFields(),
                ],
                if (_source == Mode2StyleSource.matchOwnPost) ...[
                  const SizedBox(height: 20),
                  _label(
                    'Match style of one of my posts',
                    trailing: _matchPostId == null ? 'required' : null,
                    trailingIsError: true,
                  ),
                  const SizedBox(height: 8),
                  _MatchPostPicker(
                    value: _matchPostId,
                    onChanged: (id) => setState(() => _matchPostId = id),
                  ),
                ],
                const SizedBox(height: 20),
                _assetSection(context),
                const SizedBox(height: 20),
                _slideTextSection(),
              ],
            ),
          ),
          _ActionBar(
            saving: _saving,
            canSave: _isFormValid,
            savedRecently: _savedRecently,
            onSave: _save,
          ),
        ],
      ),
    );
  }

  List<Widget> _overrideFields() {
    final bothNull = _palette == null && _tone == null;
    return [
      _label(
        'Color palette',
        trailing: bothNull ? 'pick at least one' : null,
        trailingIsError: true,
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          _Pill(
            label: 'None',
            active: _palette == null,
            onTap: () => setState(() => _palette = null),
          ),
          ...kPalettes.map(
            (p) => _Pill(
              label: p.name,
              active: _palette == p.id,
              swatches: p.swatches,
              onTap: () => setState(() => _palette = p.id),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _label('Voice tone'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          _Pill(
            label: 'None',
            active: _tone == null,
            onTap: () => setState(() => _tone = null),
          ),
          ...kVoices.map(
            (v) => _Pill(
              label: v.label,
              sub: v.sub,
              active: _tone == v.id,
              onTap: () => setState(() => _tone = v.id),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _assetSection(BuildContext context) {
    return Opacity(
      opacity: _replicateMode ? 0.55 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(
            'Attach a brand asset',
            trailing:
                _replicateMode ? 'disabled in replicate mode' : 'optional',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (_assetId != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    border: Border.all(color: AppColors.accent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check,
                          size: 13, color: AppColors.accentInk),
                      const SizedBox(width: 6),
                      Text(
                        'Asset attached',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentInk,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  'No asset attached',
                  style: TextStyle(fontSize: 12, color: AppColors.ink3),
                ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: _replicateMode
                    ? null
                    : () async {
                        final picked = await AssetPickerSheet.show(
                          context,
                          initialSelectedId: _assetId,
                        );
                        if (picked != null && mounted) {
                          setState(() => _assetId = picked);
                        }
                      },
                child: Text(_assetId != null ? 'Change' : 'Pick an asset'),
              ),
              if (_assetId != null && !_replicateMode)
                TextButton(
                  onPressed: () => setState(() => _assetId = null),
                  child: Text(
                    'Remove',
                    style: TextStyle(color: AppColors.ink3),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _slideTextSection() {
    final extracting =
        _extractionStatus == 'extracting' || _extractionStatus == 'pending';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Edit slide text', trailing: 'optional'),
        const SizedBox(height: 8),
        if (extracting)
          _statusBanner(
            color: AppColors.surface,
            border: AppColors.line2,
            child: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  'Extracting text from slides…',
                  style: TextStyle(fontSize: 12, color: AppColors.ink3),
                ),
              ],
            ),
          ),
        if (_extractionStatus == 'failed' && !_hasUserEditedSlides)
          _statusBanner(
            color: const Color(0xFFFBF5F5),
            border: const Color(0xFFF0D9D9),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    size: 14, color: Color(0xFF9A6B6B)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Could not extract text — type manually below',
                    style: TextStyle(fontSize: 12, color: Color(0xFF7A5555)),
                  ),
                ),
              ],
            ),
          ),
        ...List.generate(_slideCount, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(color: AppColors.line),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontFamily: AppFonts.mono,
                      fontFamilyFallback: AppFonts.monoFallback,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink2,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _slideControllers[i],
                    onChanged: (_) {
                      if (!_hasUserEditedSlides) {
                        setState(() => _hasUserEditedSlides = true);
                      }
                    },
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: extracting
                          ? 'Slide ${i + 1} — extracting text…'
                          : 'Slide ${i + 1} — leave empty to auto-generate',
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Small shared bits
  // ---------------------------------------------------------------------------
  Widget _statusBanner({
    required Color color,
    required Color border,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }

  Widget _sectionEyebrow(String text) => Text(
        text,
        style: TextStyle(
          fontFamily: AppFonts.mono,
          fontFamilyFallback: AppFonts.monoFallback,
          fontSize: 11,
          letterSpacing: 0.44,
          fontWeight: FontWeight.w600,
          color: AppColors.ink3,
        ),
      );

  Widget _label(String text, {String? trailing, bool trailingIsError = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.ink2,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 6),
          Text(
            trailingIsError ? '· $trailing' : '· $trailing',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: trailingIsError
                  ? const Color(0xFFC0392B)
                  : AppColors.ink3,
            ),
          ),
        ],
      ],
    );
  }
}

// =============================================================================
// Style-source 2x2 grid (mirrors StyleSourceRadio.jsx)
// =============================================================================
class _StyleSourceGrid extends StatelessWidget {
  final Mode2StyleSource value;
  final ValueChanged<Mode2StyleSource> onChanged;

  const _StyleSourceGrid({required this.value, required this.onChanged});

  static const List<(Mode2StyleSource, String, String, IconData)> _options = [
    (
      Mode2StyleSource.defaultStyle,
      'Use my brand defaults',
      'Use the colors, voice, and styles from Brand Studio.',
      Icons.auto_awesome_outlined,
    ),
    (
      Mode2StyleSource.override,
      'Customize for this post',
      'Pick a one-off palette and voice for this generation.',
      Icons.palette_outlined,
    ),
    (
      Mode2StyleSource.matchOwnPost,
      'Match style of one of my posts',
      'Reference an existing post from your Instagram.',
      Icons.camera_alt_outlined,
    ),
    (
      Mode2StyleSource.replicateSource,
      'Replicate this post exactly',
      'Faithfully recreate the source. No brand assets applied.',
      Icons.refresh,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final tileWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: _options.map((o) {
            final active = value == o.$1;
            return SizedBox(
              width: tileWidth,
              child: _StyleSourceTile(
                active: active,
                label: o.$2,
                desc: o.$3,
                icon: o.$4,
                onTap: () => onChanged(o.$1),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _StyleSourceTile extends StatelessWidget {
  final bool active;
  final String label;
  final String desc;
  final IconData icon;
  final VoidCallback onTap;

  const _StyleSourceTile({
    required this.active,
    required this.label,
    required this.desc,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.accentSoft : AppColors.white,
          border: Border.all(
            color: active ? AppColors.accent : AppColors.line,
            width: active ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: active ? AppColors.accentInk : AppColors.ink2,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active ? AppColors.accentInk : AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.4,
                color: active ? AppColors.accentInk : AppColors.ink3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Palette / tone pill (with optional swatch row + subtitle)
// =============================================================================
class _Pill extends StatelessWidget {
  final String label;
  final String? sub;
  final List<Color>? swatches;
  final bool active;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.active,
    required this.onTap,
    this.sub,
    this.swatches,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.accentSoft : AppColors.surface,
          border: Border.all(
            color: active ? AppColors.accent : AppColors.line,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (swatches != null) ...[
              _SwatchRow(colors: swatches!),
              const SizedBox(width: 8),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: active ? AppColors.accentInk : AppColors.ink2,
                  ),
                ),
                if (sub != null)
                  Text(
                    sub!,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: active ? AppColors.accentInk : AppColors.ink3,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SwatchRow extends StatelessWidget {
  final List<Color> colors;
  const _SwatchRow({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: colors
          .map(
            (c) => Container(
              width: 11,
              height: 11,
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.line),
              ),
            ),
          )
          .toList(),
    );
  }
}

// =============================================================================
// Match-own-post picker (mirrors MatchPostDropdown.jsx)
// =============================================================================
class _MatchPostPicker extends StatefulWidget {
  final String? value;
  final ValueChanged<String> onChanged;

  const _MatchPostPicker({required this.value, required this.onChanged});

  @override
  State<_MatchPostPicker> createState() => _MatchPostPickerState();
}

class _MatchPostPickerState extends State<_MatchPostPicker> {
  final InstagramRepository _ig = GetIt.I<InstagramRepository>();

  List<InstagramUserPostModel> _posts = const <InstagramUserPostModel>[];
  bool _loading = true;
  String? _error;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final posts = await _ig.getUserInstagramPosts(limit: 20);
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'INSTAGRAM_NOT_CONNECTED':
          message = 'Connect Instagram in Settings to use this option.';
          break;
        case 'INSTAGRAM_AUTH_FAILED':
          message = 'Instagram authentication expired. Reconnect to refresh.';
          break;
        default:
          message = e.message;
      }
      setState(() {
        _error = message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _infoBox('Loading your Instagram posts…');
    if (_error != null) return _infoBox(_error!);
    if (_posts.isEmpty) return _infoBox('No Instagram posts found yet.');

    InstagramUserPostModel? selected;
    for (final p in _posts) {
      if (p.postId == widget.value) {
        selected = p;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white,
              border:
                  Border.all(color: _open ? AppColors.ink : AppColors.line),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                if (selected != null) ...[
                  _PostThumbnail(post: selected, size: 36),
                  const SizedBox(width: 10),
                  Expanded(child: _postLabel(selected, maxLines: 1)),
                ] else
                  Expanded(
                    child: Text(
                      'Pick a post to match…',
                      style: TextStyle(fontSize: 13, color: AppColors.ink3),
                    ),
                  ),
                Icon(
                  _open ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: AppColors.ink3,
                ),
              ],
            ),
          ),
        ),
        if (_open) ...[
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 280),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _posts.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppColors.line2),
              itemBuilder: (_, i) {
                final p = _posts[i];
                final active = p.postId == widget.value;
                return InkWell(
                  onTap: () {
                    widget.onChanged(p.postId);
                    setState(() => _open = false);
                  },
                  child: Container(
                    color: active ? AppColors.accentSoft : null,
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PostThumbnail(post: p, size: 40),
                        const SizedBox(width: 10),
                        Expanded(child: _postLabel(p, maxLines: 2)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _postLabel(InstagramUserPostModel post, {required int maxLines}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          (post.caption == null || post.caption!.isEmpty)
              ? '(no caption)'
              : post.caption!,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          post.mediaType ?? '',
          style: TextStyle(
            fontFamily: AppFonts.mono,
            fontFamilyFallback: AppFonts.monoFallback,
            fontSize: 10.5,
            color: AppColors.ink3,
          ),
        ),
      ],
    );
  }

  Widget _infoBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: AppColors.ink2),
      ),
    );
  }
}

class _PostThumbnail extends StatelessWidget {
  final InstagramUserPostModel post;
  final double size;

  const _PostThumbnail({required this.post, required this.size});

  String? get _resolvedUrl {
    final raw = post.imageUrl;
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    return '${ApiConfig.baseUrl}$raw';
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolvedUrl;
    // Carousel albums have no single image_url — show a mono "CAR" tile.
    if (post.mediaType == 'CAROUSEL_ALBUM' || url == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          'CAR',
          style: TextStyle(
            fontFamily: AppFonts.mono,
            fontFamilyFallback: AppFonts.monoFallback,
            fontSize: 9,
            color: AppColors.ink3,
            letterSpacing: 0.4,
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) =>
            Container(width: size, height: size, color: AppColors.surface2),
        errorWidget: (_, __, ___) => Container(
          width: size,
          height: size,
          color: AppColors.surface2,
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported_outlined,
              size: 16, color: AppColors.ink4),
        ),
      ),
    );
  }
}

// =============================================================================
// Sticky action bar
// =============================================================================
class _ActionBar extends StatelessWidget {
  final bool saving;
  final bool canSave;
  final bool savedRecently;
  final VoidCallback onSave;

  const _ActionBar({
    required this.saving,
    required this.canSave,
    required this.savedRecently,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (savedRecently) ...[
              const Icon(Icons.check_circle, size: 16, color: AppColors.good),
              const SizedBox(width: 6),
              Text(
                'Saved',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.good,
                ),
              ),
            ],
            const Spacer(),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: (saving || !canSave) ? null : onSave,
              child: saving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Text('Save customization'),
            ),
          ],
        ),
      ),
    );
  }
}
