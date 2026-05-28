import 'package:flutter/widgets.dart';

/// Lightweight responsive helpers for adapting components across phone sizes.
///
/// Baseline width is 390pt (≈ iPhone 14 / mid-range Android). [scale] linearly
/// adjusts a baseline pixel value to the current screen width, clamped to a
/// sane band (0.85×–1.15×) so very small phones don't crush UI and very
/// wide ones don't sprawl.
///
/// Usage:
/// ```dart
/// final pad = Responsive.scale(context, 20);          // ~17 on 360w, ~23 on 430w
/// final fontSize = Responsive.scale(context, 14);
/// if (Responsive.isCompact(context)) … else …
/// final cols = Responsive.pick(context, compact: 1, regular: 2);
/// ```
class Responsive {
  Responsive._();

  /// Phones under this width need tighter paddings / shorter labels.
  static const double compactBreakpoint = 360;

  /// Larger phones / phablets get a touch more breathing room.
  static const double largeBreakpoint = 430;

  static const double _baselineWidth = 390;
  static const double _minRatio = 0.85;
  static const double _maxRatio = 1.15;

  static double widthOf(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double heightOf(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static bool isCompact(BuildContext context) =>
      widthOf(context) < compactBreakpoint;

  static bool isLarge(BuildContext context) =>
      widthOf(context) >= largeBreakpoint;

  /// Width-driven scale factor, clamped to [_minRatio]–[_maxRatio].
  static double scaleFactor(BuildContext context) {
    final w = widthOf(context);
    return (w / _baselineWidth).clamp(_minRatio, _maxRatio);
  }

  /// Scale a baseline value by the current screen width.
  static double scale(BuildContext context, double baseline) =>
      baseline * scaleFactor(context);

  /// Pick one of two values based on compact-vs-regular.
  static T pick<T>(
    BuildContext context, {
    required T compact,
    required T regular,
  }) =>
      isCompact(context) ? compact : regular;
}
