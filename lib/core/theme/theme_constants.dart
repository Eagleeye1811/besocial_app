import 'package:flutter/material.dart';

/// Design tokens mirrored from the website's source of truth:
/// `../besocial/frontend/src/styles/tokens.js`.
///
/// Every value here exists 1:1 in that file. Do not add new tokens without a
/// matching addition on the web side — branding parity is the whole point.
class AppColors {
  AppColors._();

  // Ink scale — text & high-contrast UI.
  static const Color ink = Color(0xFF18181B);
  static const Color ink2 = Color(0xFF3F3F46);
  static const Color ink3 = Color(0xFF71717A);
  static const Color ink4 = Color(0xFFA1A1AA);

  // Hairlines / dividers.
  static const Color line = Color(0xFFEAEAEA);
  static const Color line2 = Color(0xFFF1F1F0);

  // Surfaces.
  static const Color surface = Color(0xFFFAFAF9);
  static const Color surface2 = Color(0xFFF4F4F2);
  static const Color white = Color(0xFFFFFFFF);

  // Accent (brand orange).
  static const Color accent = Color(0xFFF47B42);
  static const Color accentSoft = Color(0xFFFEF1E9);
  static const Color accentInk = Color(0xFF9A3F11);

  // Status.
  static const Color good = Color(0xFF16A34A);
}

/// Font families exactly as declared in `tokens.js`. The website does not bundle
/// these — it relies on locally-installed copies with a system fallback. Wire
/// them into `pubspec.yaml` (or pull from `google_fonts`) before they render
/// on-device; otherwise Flutter falls through to the platform default.
class AppFonts {
  AppFonts._();

  static const String display = 'Inter Tight';
  static const String ui = 'Inter';
  static const String mono = 'JetBrains Mono';

  /// Fallback chain (`tokens.js` order) used wherever Flutter accepts it.
  static const List<String> displayFallback = <String>[
    'Inter',
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'sans-serif',
  ];
  static const List<String> uiFallback = <String>[
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'sans-serif',
  ];
  static const List<String> monoFallback = <String>[
    'SF Mono',
    'ui-monospace',
    'Menlo',
    'monospace',
  ];
}

/// Elevation tokens converted from the CSS `box-shadow` strings in `tokens.js`.
/// CSS `inset` is not representable as a Flutter `BoxShadow`, so the `ring`
/// token from the website is exposed as a 1px [BorderSide] instead.
class AppShadows {
  AppShadows._();

  // 0 1px 1px rgba(24,24,27,0.04), 0 4px 12px rgba(24,24,27,0.04)
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: Color(0x0A18181B),
      offset: Offset(0, 1),
      blurRadius: 1,
    ),
    BoxShadow(
      color: Color(0x0A18181B),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  // 0 1px 1px rgba(24,24,27,0.05),
  // 0 8px 24px rgba(24,24,27,0.06),
  // 0 24px 60px rgba(24,24,27,0.06)
  static const List<BoxShadow> cardHi = <BoxShadow>[
    BoxShadow(
      color: Color(0x0D18181B),
      offset: Offset(0, 1),
      blurRadius: 1,
    ),
    BoxShadow(
      color: Color(0x0F18181B),
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
    BoxShadow(
      color: Color(0x0F18181B),
      offset: Offset(0, 24),
      blurRadius: 60,
    ),
  ];

  // 0 24px 80px rgba(24,24,27,0.18), 0 6px 20px rgba(24,24,27,0.10)
  static const List<BoxShadow> pop = <BoxShadow>[
    BoxShadow(
      color: Color(0x2E18181B),
      offset: Offset(0, 24),
      blurRadius: 80,
    ),
    BoxShadow(
      color: Color(0x1A18181B),
      offset: Offset(0, 6),
      blurRadius: 20,
    ),
  ];

  /// CSS: `inset 0 0 0 1px #EAEAEA` — use as a [Border] on the target widget.
  static const BorderSide ring = BorderSide(color: AppColors.line, width: 1);
}
