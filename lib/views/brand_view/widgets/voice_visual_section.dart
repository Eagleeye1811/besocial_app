import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/brand_controller/brand_controller.dart';
import '../../../data/dto/brand_patch_dto.dart';
import '../../../data/models/brand_profile_model.dart';
import 'section_card.dart';

class VoiceVisualSection extends StatefulWidget {
  final BrandProfileModel profile;
  const VoiceVisualSection({super.key, required this.profile});

  @override
  State<VoiceVisualSection> createState() => _VoiceVisualSectionState();
}

class _VoiceVisualSectionState extends State<VoiceVisualSection> {
  late final TextEditingController _palette;
  late final TextEditingController _voice;
  late final TextEditingController _aesthetic;

  @override
  void initState() {
    super.initState();
    final p = widget.profile.personalization ?? const <String, dynamic>{};
    _palette = TextEditingController(
        text: (p['color_palette_id'] as String?) ?? '');
    _voice =
        TextEditingController(text: (p['voice_tone_id'] as String?) ?? '');
    _aesthetic = TextEditingController(
        text: (p['aesthetic_theme'] as String?) ?? '');
  }

  @override
  void dispose() {
    _palette.dispose();
    _voice.dispose();
    _aesthetic.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final controller = Get.find<BrandController>();
    await controller.patchSection(BrandPatchDto(
      colorPaletteId:
          _palette.text.trim().isEmpty ? null : _palette.text.trim(),
      voiceToneId: _voice.text.trim().isEmpty ? null : _voice.text.trim(),
      aestheticTheme:
          _aesthetic.text.trim().isEmpty ? null : _aesthetic.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BrandController>();
    return BrandSectionCard(
      eyebrow: 'Voice & visual',
      title: 'How everything sounds and looks',
      actions: Obx(() => ElevatedButton(
            onPressed: controller.isSaving.value ? null : _save,
            child: Text(controller.isSaving.value ? 'Saving…' : 'Save'),
          )),
      child: Column(
        children: [
          BrandLabeledField(
            label: 'Color palette id',
            controller: _palette,
            hint: 'warm · cool · mono · bloom',
          ),
          BrandLabeledField(
            label: 'Voice tone id',
            controller: _voice,
            hint: 'crisp · warm · cheeky · expert',
          ),
          BrandLabeledField(
            label: 'Aesthetic theme',
            controller: _aesthetic,
            hint: 'Free-form, e.g. "editorial-minimal"',
          ),
        ],
      ),
    );
  }
}
