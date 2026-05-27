/// Maps the backend's canonical generation error codes to user-facing copy
/// and suggested next actions. Ported 1:1 from the web source of truth:
/// `../besocial/frontend/src/features/dashboard/lib/generationErrors.js`.
///
/// Backend codes (from Tier 4H):
///   - IP_RESTRICTION:           copyrighted content (characters, logos)
///   - CONTENT_SAFETY_BLOCKED:   Gemini safety filter
///   - IMAGE_GENERATION_FAILED:  generic Gemini failure (retryable)
///   - GEMINI_API_ERROR:         API-level failure (retryable)
///   - VISION_ANALYSIS_FAILED:   couldn't read source post
///   - REFERENCE_POST_NOT_FOUND: source post unavailable
///
/// Pre-Tier-4H jobs may have raw exception class names as `error_code`
/// (e.g. `VisionAnalysisError`) — mapped via [_legacyAliases] below.
library;

/// Action types — UI decides how to render each. The shortlist card reads
/// these to build the appropriate button.
///   - [retry]:     "Try again" — re-runs generation with same config.
///   - [customize]: "Customize this post" — opens the Mode 2 sheet to
///                  change config.
///   - [remove]:    "Remove from shortlist" — no retry path.
enum GenerationErrorAction { retry, customize, remove }

/// Resolved, displayable shape for a failed generation: title + message +
/// 1–2 contextual actions.
class GenerationErrorDisplay {
  final String title;
  final String message;
  final GenerationErrorAction primaryAction;
  final GenerationErrorAction? secondaryAction;

  const GenerationErrorDisplay({
    required this.title,
    required this.message,
    required this.primaryAction,
    this.secondaryAction,
  });
}

const Map<String, GenerationErrorDisplay> _errorMap = {
  'IP_RESTRICTION': GenerationErrorDisplay(
    title: 'Protected content detected',
    message:
        'This source post contains copyrighted material (characters, brand '
        'logos, or recognizable artwork). Try a different style source — your '
        'brand defaults or a custom palette.',
    primaryAction: GenerationErrorAction.customize,
    secondaryAction: GenerationErrorAction.remove,
  ),
  'CONTENT_SAFETY_BLOCKED': GenerationErrorDisplay(
    title: 'Blocked by content safety',
    message:
        "Gemini's safety filter blocked this generation. Try removing any "
        'attached assets, or pick a different style source.',
    primaryAction: GenerationErrorAction.customize,
    secondaryAction: GenerationErrorAction.remove,
  ),
  'IMAGE_GENERATION_FAILED': GenerationErrorDisplay(
    title: 'Generation failed',
    message:
        'Something went wrong during image rendering. Try again — most '
        'generation issues clear up on a retry.',
    primaryAction: GenerationErrorAction.retry,
    secondaryAction: GenerationErrorAction.remove,
  ),
  'GEMINI_API_ERROR': GenerationErrorDisplay(
    title: 'Generation failed',
    message: 'The image API hit an error. Try again in a moment.',
    primaryAction: GenerationErrorAction.retry,
    secondaryAction: GenerationErrorAction.remove,
  ),
  'VISION_ANALYSIS_FAILED': GenerationErrorDisplay(
    title: "Couldn't read the source post",
    message:
        "We couldn't analyze this post's visuals. The image may be too complex "
        'or the content type unsupported. Try a different post.',
    primaryAction: GenerationErrorAction.remove,
    secondaryAction: null,
  ),
  'REFERENCE_POST_NOT_FOUND': GenerationErrorDisplay(
    title: 'Source post unavailable',
    message:
        "We can't find the source post anymore — it may have been deleted on "
        'Instagram. Remove it from your shortlist and try a different one.',
    primaryAction: GenerationErrorAction.remove,
    secondaryAction: null,
  ),
};

/// Pre-Tier-4H raw-class-name aliases — keep working until those jobs age out
/// of the system.
const Map<String, String> _legacyAliases = {
  'VisionAnalysisError': 'VISION_ANALYSIS_FAILED',
  'ImageGenerationError': 'IMAGE_GENERATION_FAILED',
  'ReferencePostNotFoundError': 'REFERENCE_POST_NOT_FOUND',
};

/// Catch-all for unknown codes. Same retry-or-remove options as a generic
/// image-generation failure.
const GenerationErrorDisplay _defaultError = GenerationErrorDisplay(
  title: 'Generation failed',
  message:
      'Something went wrong. Try again, or pick a different post if it keeps '
      'failing.',
  primaryAction: GenerationErrorAction.retry,
  secondaryAction: GenerationErrorAction.remove,
);

/// Resolve an [code] (and optional [fallbackMessage] from the backend's
/// `error_message`) into a [GenerationErrorDisplay].
///
/// - Known canonical code → mapped entry.
/// - Known legacy class name → mapped via alias.
/// - Unknown code → [_defaultError] (with its own canned message).
/// - No code at all → [_defaultError] with the fallback message overridden
///   (so we still show whatever the backend said, even if uncategorised).
GenerationErrorDisplay resolveGenerationError(
  String? code,
  String? fallbackMessage,
) {
  if (code == null || code.isEmpty) {
    return GenerationErrorDisplay(
      title: _defaultError.title,
      message: (fallbackMessage != null && fallbackMessage.isNotEmpty)
          ? fallbackMessage
          : _defaultError.message,
      primaryAction: _defaultError.primaryAction,
      secondaryAction: _defaultError.secondaryAction,
    );
  }

  final canonical = _legacyAliases[code] ?? code;
  return _errorMap[canonical] ?? _defaultError;
}
