import 'package:flutter/material.dart';

/// Option lists for Brand Studio selectors. Mirrors the web source 1:1:
///   - IdentitySection.jsx  (business types, style presets)
///   - VoiceVisualSection.jsx (palettes, voices, aesthetic themes)
///   - ContentPrefsSection.jsx (face preference, default pillars)
///
/// Keep ids/labels/swatch hex values identical to the web so saved values
/// round-trip cleanly between onboarding, the web app, and this app.

/// Simple id + label pair (business types, styles, aesthetic themes).
class BrandOption {
  final String id;
  final String label;
  const BrandOption(this.id, this.label);
}

/// Voice tone option with a subtitle line.
class VoiceOption {
  final String id;
  final String label;
  final String sub;
  const VoiceOption(this.id, this.label, this.sub);
}

/// Color palette option with its 4 swatch colors.
class PaletteOption {
  final String id;
  final String name;
  final List<Color> swatches;
  const PaletteOption(this.id, this.name, this.swatches);
}

/// Max simultaneously-selected visual styles. Matches web's MAX_STYLES.
const int kMaxStyles = 3;

/// Business types — IdentitySection.jsx BUSINESS_TYPES.
const List<BrandOption> kBusinessTypes = <BrandOption>[
  BrandOption('restaurant', 'Restaurant'),
  BrandOption('salon', 'Salon'),
  BrandOption('gym', 'Gym'),
  BrandOption('cafe', 'Cafe'),
  BrandOption('realestate', 'Real estate'),
  BrandOption('clinic', 'Clinic'),
  BrandOption('clothing', 'Clothing store'),
  BrandOption('other', 'Something else'),
];

/// Visual style presets — IdentitySection.jsx STYLE_PRESETS.
const List<BrandOption> kStylePresets = <BrandOption>[
  BrandOption('clean-luxury', 'Clean luxury'),
  BrandOption('bold-modern', 'Bold modern'),
  BrandOption('warm-friendly', 'Warm friendly'),
  BrandOption('premium-dark', 'Premium dark'),
  BrandOption('minimal-white', 'Minimal white'),
  BrandOption('vibrant-trendy', 'Vibrant trendy'),
];

/// Color palettes — VoiceVisualSection.jsx PALETTES. Hex values copied verbatim.
const List<PaletteOption> kPalettes = <PaletteOption>[
  PaletteOption('terracotta', 'Terracotta noir', <Color>[
    Color(0xFF1C1B19),
    Color(0xFFF47B42),
    Color(0xFFF1E4D2),
    Color(0xFFFFFFFF),
  ]),
  PaletteOption('rose', 'Rose marble', <Color>[
    Color(0xFF2A1F1B),
    Color(0xFFD88B72),
    Color(0xFFF5E5E2),
    Color(0xFFFBF7F4),
  ]),
  PaletteOption('jade', 'Jade calm', <Color>[
    Color(0xFF0F2A24),
    Color(0xFF3F8F7B),
    Color(0xFFE8EFEA),
    Color(0xFFFFFFFF),
  ]),
  PaletteOption('mono', 'Mono ivory', <Color>[
    Color(0xFF0A0A0A),
    Color(0xFF3F3F46),
    Color(0xFFE5E5E5),
    Color(0xFFFAFAF7),
  ]),
  PaletteOption('sun', 'Sun citrus', <Color>[
    Color(0xFF1A1A1A),
    Color(0xFFE8A33D),
    Color(0xFFFFE9C2),
    Color(0xFFFFFFFF),
  ]),
  PaletteOption('plum', 'Plum velvet', <Color>[
    Color(0xFF1A0E22),
    Color(0xFF7B3F8A),
    Color(0xFFE9D9EE),
    Color(0xFFFBF7F4),
  ]),
];

/// Voice tones — VoiceVisualSection.jsx VOICES.
const List<VoiceOption> kVoices = <VoiceOption>[
  VoiceOption('professional', 'Professional', 'Calm, expert, polished'),
  VoiceOption('friendly', 'Friendly', 'Warm, conversational'),
  VoiceOption('premium', 'Premium', 'Refined, understated'),
  VoiceOption('bold', 'Bold', 'Direct, confident'),
  VoiceOption('trustworthy', 'Trustworthy', 'Honest, dependable'),
  VoiceOption('fun', 'Fun', 'Playful, witty, light'),
];

/// Aesthetic themes — VoiceVisualSection.jsx AESTHETIC_THEMES.
const List<BrandOption> kAestheticThemes = <BrandOption>[
  BrandOption('editorial', 'Editorial'),
  BrandOption('organic', 'Organic'),
  BrandOption('minimal', 'Minimal'),
  BrandOption('maximalist', 'Maximalist'),
  BrandOption('cinematic', 'Cinematic'),
];

/// Face preference options — ContentPrefsSection.jsx FACE_PREFERENCE_OPTIONS.
const List<BrandOption> kFacePreferenceOptions = <BrandOption>[
  BrandOption('appears_in_content', 'Yes — show me in posts'),
  BrandOption('no_face', 'No — keep me out of posts'),
];

/// Fallback content pillar suggestions — ContentPrefsSection.jsx
/// DEFAULT_PILLAR_SUGGESTIONS.
const List<String> kDefaultPillarSuggestions = <String>[
  'Education',
  'Inspiration',
  'Behind the scenes',
  'Tips',
  'Stories',
];
