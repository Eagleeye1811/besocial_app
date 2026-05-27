import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/brand_controller/brand_controller.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../data/dto/brand_patch_dto.dart';
import '../../../data/models/brand_profile_model.dart';
import 'brand_options.dart';
import 'section_card.dart';

/// Voice & visual — color palette grid (with swatches), voice tone grid (with
/// subtitles), aesthetic theme pills. Disabled until personalization is set
/// during onboarding. Mirrors VoiceVisualSection.jsx.
class VoiceVisualSection extends StatefulWidget {
  final BrandProfileModel profile;
  const VoiceVisualSection({super.key, required this.profile});

  @override
  State<VoiceVisualSection> createState() => _VoiceVisualSectionState();
}

class _VoiceVisualSectionState extends State<VoiceVisualSection> {
  String? _paletteId;
  String? _voiceId;
  String? _aestheticId;

  bool get _isInitialized => widget.profile.personalization != null;

  @override
  void initState() {
    super.initState();
    final p = widget.profile.personalization ?? const <String, dynamic>{};
    _paletteId = p['color_palette_id'] as String?;
    _voiceId = p['voice_tone_id'] as String?;
    _aestheticId = p['aesthetic_theme'] as String?;
  }

  Future<void> _save() async {
    final controller = Get.find<BrandController>();
    await controller.patchSection(BrandPatchDto(
      colorPaletteId: _paletteId,
      voiceToneId: _voiceId,
      aestheticTheme: _aestheticId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BrandController>();
    return BrandSectionCard(
      eyebrow: 'Voice & visual',
      title: 'How everything sounds and looks',
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
                const BrandSubLabel('Color palette'),
                const SizedBox(height: 10),
                _paletteGrid(),
                const SizedBox(height: 22),
                const BrandSubLabel('Voice tone'),
                const SizedBox(height: 10),
                _voiceGrid(),
                const SizedBox(height: 22),
                const BrandSubLabel('Aesthetic theme'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: kAestheticThemes
                      .map((a) => BrandChip(
                            label: a.label,
                            active: _aestheticId == a.id,
                            onTap: () => setState(() => _aestheticId = a.id),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paletteGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: kPalettes.map((palette) {
        final active = _paletteId == palette.id;
        return InkWell(
          onTap: () => setState(() => _paletteId = palette.id),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(
                color: active ? AppColors.accent : AppColors.line,
                width: active ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: palette.swatches
                      .map((c) => Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: c,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0x0F18181B),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  palette.name,
                  style: TextStyle(
                    fontFamily: AppFonts.ui,
                    fontFamilyFallback: AppFonts.uiFallback,
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _voiceGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.7,
      children: kVoices.map((v) {
        final active = _voiceId == v.id;
        return InkWell(
          onTap: () => setState(() => _voiceId = v.id),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: active ? AppColors.accentSoft : AppColors.white,
              border: Border.all(
                color: active ? AppColors.accent : AppColors.line,
                width: active ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  v.label,
                  style: TextStyle(
                    fontFamily: AppFonts.ui,
                    fontFamilyFallback: AppFonts.uiFallback,
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: active ? AppColors.accentInk : AppColors.ink2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  v.sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.ui,
                    fontFamilyFallback: AppFonts.uiFallback,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: active ? AppColors.accentInk : AppColors.ink3,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
