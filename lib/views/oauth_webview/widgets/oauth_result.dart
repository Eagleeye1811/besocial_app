/// Result returned from the in-app OAuth WebView via `Get.back(result: …)`.
///
/// The WebView intercepts the backend's redirect to
/// `{FRONTEND_URL}/auth/callback#token=…&new_user=…` (or `?error=…`) and
/// passes a typed result back to whichever controller awaited it, so the
/// caller never has to touch raw URL strings.
sealed class OAuthResult {
  const OAuthResult();
}

class OAuthSuccess extends OAuthResult {
  final String token;
  final bool isNewUser;
  const OAuthSuccess({required this.token, required this.isNewUser});
}

/// Returned when the WebView intercepts the Instagram OAuth callback
/// (`/onboarding/instagram-connect?success=true&username=…`). The backend
/// has already persisted the credentials at this point; the username is
/// passed through purely so the caller can flash a confirmation.
class InstagramConnectSuccess extends OAuthResult {
  final String? username;
  const InstagramConnectSuccess({this.username});
}

class OAuthError extends OAuthResult {
  /// Raw reason string the backend supplied via `?error=…`, or one of the
  /// synthetic client codes ([clientCancelled], [clientMissingToken]) for
  /// flows that never reached the backend.
  final String reason;
  const OAuthError(this.reason);

  static const String clientCancelled = 'cancelled';
  static const String clientMissingToken = 'missing_token';
}
