import 'package:flutter/material.dart';

import '../../../controllers/shortlist_controller/shortlist_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/models/mode2_config_model.dart';

/// Mode 2 configuration sheet for a shortlist post.
///
/// `Mode2StyleSource` is the discriminator: each variant gates which
/// override fields are visible. The save button assembles a [Mode2ConfigModel]
/// that respects the backend's mutual-exclusivity rules
/// (see `src/models/mode2_config.py:_check_style_source_consistency`):
///
///   - [Mode2StyleSource.defaultStyle]   → no overrides
///   - [Mode2StyleSource.override]       → requires palette + tone
///   - [Mode2StyleSource.matchOwnPost]   → requires `match_style_post_id`
///   - [Mode2StyleSource.replicateSource]→ no overrides
class Mode2ConfigSheet extends StatefulWidget {
  final String postId;
  final ShortlistController controller;
  final Mode2ConfigModel? initial;

  const Mode2ConfigSheet({
    super.key,
    required this.postId,
    required this.controller,
    this.initial,
  });

  static Future<void> show(
    BuildContext context, {
    required String postId,
    required ShortlistController controller,
  }) async {
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
        postId: postId,
        controller: controller,
        initial: initial,
      ),
    );
  }

  @override
  State<Mode2ConfigSheet> createState() => _Mode2ConfigSheetState();
}

class _Mode2ConfigSheetState extends State<Mode2ConfigSheet> {
  late Mode2StyleSource _source;
  late final TextEditingController _palette;
  late final TextEditingController _tone;
  late final TextEditingController _matchPostId;
  late final TextEditingController _assetId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    _source = init?.styleSource ?? Mode2StyleSource.defaultStyle;
    _palette = TextEditingController(text: init?.paletteOverride ?? '');
    _tone = TextEditingController(text: init?.toneOverride ?? '');
    _matchPostId = TextEditingController(text: init?.matchStylePostId ?? '');
    _assetId = TextEditingController(text: init?.assetId ?? '');
  }

  @override
  void dispose() {
    _palette.dispose();
    _tone.dispose();
    _matchPostId.dispose();
    _assetId.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    switch (_source) {
      case Mode2StyleSource.defaultStyle:
      case Mode2StyleSource.replicateSource:
        return true;
      case Mode2StyleSource.override:
        return _palette.text.trim().isNotEmpty &&
            _tone.text.trim().isNotEmpty;
      case Mode2StyleSource.matchOwnPost:
        return _matchPostId.text.trim().isNotEmpty;
    }
  }

  Future<void> _save() async {
    if (!_isFormValid || _saving) return;
    setState(() => _saving = true);
    final patch = Mode2ConfigModel(
      styleSource: _source,
      paletteOverride: _source == Mode2StyleSource.override
          ? _palette.text.trim()
          : null,
      toneOverride:
          _source == Mode2StyleSource.override ? _tone.text.trim() : null,
      matchStylePostId: _source == Mode2StyleSource.matchOwnPost
          ? _matchPostId.text.trim()
          : null,
      assetId: _assetId.text.trim().isEmpty ? null : _assetId.text.trim(),
    );
    final ok = await widget.controller.saveConfig(widget.postId, patch);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                Text(
                  'Style for this post',
                  style: TextStyle(
                    fontFamily: AppFonts.display,
                    fontFamilyFallback: AppFonts.displayFallback,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Override your brand voice or palette for this one "
                  'generation, or match a specific post you already own.',
                  style: TextStyle(fontSize: 13, color: AppColors.ink3),
                ),
                const SizedBox(height: 16),
                ..._sourceTiles(),
                const SizedBox(height: 16),
                ..._variantFields(),
              ],
            ),
          ),
          _ActionBar(
            saving: _saving,
            canSave: _isFormValid,
            onSave: _save,
          ),
        ],
      ),
    );
  }

  List<Widget> _sourceTiles() {
    const tiles = [
      (Mode2StyleSource.defaultStyle, 'Brand default',
          'Use the voice and palette from your brand profile.'),
      (Mode2StyleSource.override, 'Override for this post',
          'Pick a different palette and voice just this time.'),
      (Mode2StyleSource.matchOwnPost, 'Match one of your posts',
          'Generate in the style of a high-performing post you already own.'),
      (Mode2StyleSource.replicateSource, 'Replicate the source',
          "Mirror the look and feel of the inspiration post directly."),
    ];
    return tiles
        .map((t) => _OptionTile(
              source: t.$1,
              label: t.$2,
              sub: t.$3,
              selected: _source == t.$1,
              onTap: () => setState(() => _source = t.$1),
            ))
        .toList();
  }

  List<Widget> _variantFields() {
    switch (_source) {
      case Mode2StyleSource.defaultStyle:
      case Mode2StyleSource.replicateSource:
        return const <Widget>[];
      case Mode2StyleSource.override:
        return [
          _LabeledField(
            label: 'Palette id',
            controller: _palette,
            hint: 'e.g. warm',
          ),
          _LabeledField(
            label: 'Voice id',
            controller: _tone,
            hint: 'e.g. crisp',
          ),
          _LabeledField(
            label: 'Asset id (optional)',
            controller: _assetId,
            hint: 'Asset id from /brand/assets',
          ),
        ];
      case Mode2StyleSource.matchOwnPost:
        return [
          _LabeledField(
            label: 'Match style of post id',
            controller: _matchPostId,
            hint: 'IG post id from /users/me/instagram-posts',
          ),
          _LabeledField(
            label: 'Asset id (optional)',
            controller: _assetId,
            hint: 'Asset id from /brand/assets',
          ),
        ];
    }
  }
}

class _OptionTile extends StatelessWidget {
  final Mode2StyleSource source;
  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.source,
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentSoft : AppColors.white,
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.line,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 18,
                color: selected ? AppColors.accent : AppColors.ink4,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color:
                            selected ? AppColors.accentInk : AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      sub,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: AppColors.ink3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontFamilyFallback: AppFonts.monoFallback,
              fontSize: 11,
              letterSpacing: 0.44,
              color: AppColors.ink4,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final bool saving;
  final bool canSave;
  final VoidCallback onSave;

  const _ActionBar({
    required this.saving,
    required this.canSave,
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
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
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
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
