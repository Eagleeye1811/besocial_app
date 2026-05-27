import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/brand_controller/brand_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/dto/brand_patch_dto.dart';
import '../../../data/models/brand_profile_model.dart';
import 'brand_options.dart';
import 'section_card.dart';

/// Content preferences — face preference, conditional face note, content
/// pillar chips, has-product toggle. Disabled until personalization is set
/// during onboarding. Mirrors ContentPrefsSection.jsx.
class ContentPrefsSection extends StatefulWidget {
  final BrandProfileModel profile;
  const ContentPrefsSection({super.key, required this.profile});

  @override
  State<ContentPrefsSection> createState() => _ContentPrefsSectionState();
}

class _ContentPrefsSectionState extends State<ContentPrefsSection> {
  String? _facePreference;
  late final TextEditingController _faceNote;
  late List<String> _pillars;
  bool _hasProduct = false;

  bool get _isInitialized => widget.profile.personalization != null;

  @override
  void initState() {
    super.initState();
    final p = widget.profile.personalization ?? const <String, dynamic>{};
    _facePreference = p['face_preference'] as String?;
    _faceNote =
        TextEditingController(text: (p['face_in_content'] as String?) ?? '');
    final pillars = p['content_pillars'];
    _pillars = pillars is List ? List<String>.from(pillars) : <String>[];
    _hasProduct = p['has_product'] as bool? ?? false;
  }

  @override
  void dispose() {
    _faceNote.dispose();
    super.dispose();
  }

  /// Suggested pillar chips: prefer the user's confirmed topics from niche
  /// analysis, then suggested topics, then a generic fallback. Mirrors the
  /// web's suggestedPillars resolution.
  List<String> get _suggestedPillars {
    final niche = widget.profile.niche;
    if (niche != null) {
      final confirmed = niche['confirmed_topics'];
      if (confirmed is List && confirmed.isNotEmpty) {
        return confirmed.map((e) => e.toString()).toList();
      }
      final suggested = niche['suggested_topics'];
      if (suggested is List && suggested.isNotEmpty) {
        return suggested.map((e) => e.toString()).toList();
      }
    }
    return kDefaultPillarSuggestions;
  }

  void _togglePillar(String pillar) {
    setState(() {
      if (_pillars.contains(pillar)) {
        _pillars.remove(pillar);
      } else {
        _pillars.add(pillar);
      }
    });
  }

  Future<void> _save() async {
    final controller = Get.find<BrandController>();
    final note = _faceNote.text.trim();
    await controller.patchSection(BrandPatchDto(
      facePreference: _facePreference,
      // Only send the free-form note when the user appears in content.
      faceInContent: _facePreference == 'appears_in_content'
          ? (note.isEmpty ? null : note)
          : null,
      contentPillars: _pillars,
      hasProduct: _hasProduct,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BrandController>();
    final showFaceNote = _facePreference == 'appears_in_content';

    return BrandSectionCard(
      eyebrow: 'Content prefs',
      title: 'What goes into every post',
      actions: _isInitialized
          ? Obx(() => ElevatedButton(
                onPressed: controller.isSaving.value ? null : _save,
                child: Text(controller.isSaving.value ? 'Saving…' : 'Save'),
              ))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isInitialized)
            const BrandDisabledReason(
              "Personalization is set during onboarding. Once it's set, you "
              'can change it here.',
            ),
          BrandDisabledGate(
            disabled: !_isInitialized,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandSubLabel('Do you appear in your content?'),
                const SizedBox(height: 10),
                Row(
                  children: kFacePreferenceOptions.map((opt) {
                    final active = _facePreference == opt.id;
                    final isFirst = opt == kFacePreferenceOptions.first;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: isFirst ? 10 : 0),
                        child: _OptionCard(
                          label: opt.label,
                          active: active,
                          onTap: () =>
                              setState(() => _facePreference = opt.id),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (showFaceNote) ...[
                  const SizedBox(height: 14),
                  BrandLabeledField(
                    label: 'Note for the AI (optional)',
                    controller: _faceNote,
                    hint: 'e.g. Use the cleaner studio photos, not the candid '
                        'ones.',
                    minLines: 2,
                    maxLines: 3,
                  ),
                ],
                const SizedBox(height: 18),
                const BrandSubLabel('Content pillars'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _suggestedPillars
                      .map((pillar) => BrandChip(
                            label: pillar,
                            active: _pillars.contains(pillar),
                            onTap: () => _togglePillar(pillar),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 18),
                _ProductToggle(
                  value: _hasProduct,
                  onChanged: (v) => setState(() => _hasProduct = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width selectable card used for the face-preference choice.
class _OptionCard extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _OptionCard({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: active ? AppColors.accentSoft : AppColors.white,
          border: Border.all(
            color: active ? AppColors.accent : AppColors.line,
            width: active ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.ui,
            fontFamilyFallback: AppFonts.uiFallback,
            fontSize: 13.5,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            color: active ? AppColors.accentInk : AppColors.ink2,
          ),
        ),
      ),
    );
  }
}

/// Has-product checkbox row with label + description. Mirrors the web's
/// "Show product photos in posts" toggle.
class _ProductToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ProductToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: value ? AppColors.accentSoft : AppColors.white,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                activeColor: AppColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Show product photos in posts',
                    style: TextStyle(
                      fontFamily: AppFonts.ui,
                      fontFamilyFallback: AppFonts.uiFallback,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'The AI will use your uploaded product images when '
                    'generating.',
                    style: TextStyle(
                      fontFamily: AppFonts.ui,
                      fontFamilyFallback: AppFonts.uiFallback,
                      fontSize: 12,
                      color: AppColors.ink3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
