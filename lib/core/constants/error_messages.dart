import '../network/api_exception.dart';

/// Backend error `code` → user-facing copy.
///
/// Every code in this map exists in the backend's `exception_handlers.py`
/// or one of its route files. Synthetic `CLIENT_*` codes minted by
/// [ApiException] for transport failures are mapped at the bottom.
///
/// Resolve with [resolveErrorMessage] so unknown codes get a sane fallback
/// instead of raw `code` strings leaking into the UI.
const Map<String, String> _kBackendErrorMessages = <String, String>{
  // Auth / session
  'MISSING_AUTH': 'You need to sign in to continue.',
  'INVALID_TOKEN': 'Your session expired. Sign in again.',
  'USER_NOT_FOUND': "We couldn't find that account.",
  'MISSING_SESSION_ID': 'Something went wrong starting your session.',
  'INVALID_SESSION_ID': 'Your onboarding session is no longer valid.',
  'INVALID_SESSION_TOKEN': 'Your onboarding session is no longer valid.',
  'SESSION_NOT_FOUND': "We couldn't find your onboarding session.",
  'SESSION_NOT_OWNED': "This session doesn't belong to your account.",
  'FORBIDDEN': "You don't have access to this.",

  // Invite gate
  'INVITE_CODE_MISSING': 'Please enter an invite code to continue.',
  'INVITE_CODE_INVALID':
      "That invite code isn't valid. Check the spelling or request access.",

  // Onboarding pipeline
  'USER_NOT_READY':
      "Your account isn't ready yet — finish onboarding first.",
  'NICHE_NOT_INITIALIZED':
      "We're still analyzing your niche. Try again in a moment.",
  'PERSONALIZATION_NOT_INITIALIZED':
      'Finish the style and voice steps before continuing.',

  // Discover / feed
  'NO_DISCOVER_SESSION':
      'Your discover feed needs a refresh. Try again in a moment.',
  'REFRESH_IN_PROGRESS':
      "We're already pulling fresh posts — give it a few seconds.",
  'POST_NOT_FOUND': "We couldn't find that post anymore.",
  'REFERENCE_POST_NOT_FOUND':
      "The post you picked is no longer available.",

  // Shortlist
  'SHORTLIST_ITEM_NOT_FOUND': "That post isn't on your shortlist.",
  'NOT_IN_SHORTLIST': 'Add this post to your shortlist first.',
  'MATCH_STYLE_POST_NOT_FOUND':
      "We couldn't find the post you wanted to match.",

  // Generation
  'JOB_NOT_FOUND': "We couldn't find that generation.",

  // Instagram
  'INSTAGRAM_NOT_CONNECTED':
      'Connect your Instagram account to do that.',
  'INSTAGRAM_POST_FAILED':
      'Instagram rejected the post. Try again, or open Instagram to check status.',

  // Brand assets / files
  'ASSET_NOT_FOUND': "We couldn't find that asset anymore.",
  'FILE_NOT_FOUND': "We couldn't find that file.",
  'STORAGE_WRITE_FAILED':
      "We couldn't save that upload. Try again in a moment.",

  // Generic backend
  'VALIDATION_ERROR': 'Some of those values look off — double-check and retry.',
  'HTTP_ERROR': 'The server returned an error. Please try again.',
  'INTERNAL_ERROR': "Something went wrong on our end. We're looking into it.",
};

const Map<String, String> _kClientErrorMessages = <String, String>{
  ApiException.codeNetwork:
      "You're offline. Check your connection and try again.",
  ApiException.codeTimeout: 'That took too long. Try again.',
  ApiException.codeCancelled: 'Cancelled.',
  ApiException.codeBadResponse:
      "We didn't understand the server's response. Try again.",
  ApiException.codeUnknown: 'Something unexpected happened. Try again.',
};

/// Resolve a backend `code` (or synthetic client code) to a user-facing string.
/// Falls back to [fallbackMessage] (defaulting to a generic) for unknown codes.
String resolveErrorMessage(
  String code, {
  String fallbackMessage = 'Something went wrong. Please try again.',
}) {
  return _kBackendErrorMessages[code] ??
      _kClientErrorMessages[code] ??
      fallbackMessage;
}

/// Convenience overload for an [ApiException]; prefers its `message` if the
/// code is unmapped (since the backend `message` is usually serviceable copy).
String resolveApiExceptionMessage(ApiException exception) {
  return _kBackendErrorMessages[exception.code] ??
      _kClientErrorMessages[exception.code] ??
      exception.message;
}
