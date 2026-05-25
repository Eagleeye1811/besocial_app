import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../core/constants/error_messages.dart';
import '../../core/network/api_exception.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/logger_service.dart';
import '../../core/services/secure_storage_service.dart';
import '../../repository/auth_repository/auth_repository.dart';
import '../../repository/session_repository/session_repository.dart';
import '../../views/oauth_webview/widgets/oauth_result.dart';

/// Mirrors the website's WelcomeStep state — invite-code input on one side
/// and the Google sign-in trigger on the other. Both flows funnel through
/// the in-app [OAuthWebViewView] eventually; the difference is whether an
/// `invite_token` rides along (new-user signup) or not (returning user).
class AuthController extends GetxController {
  final AuthRepository _authRepo = GetIt.I<AuthRepository>();
  final SessionRepository _session = GetIt.I<SessionRepository>();
  final SecureStorageService _secure = GetIt.I<SecureStorageService>();
  final AuthService _auth = GetIt.I<AuthService>();
  final LoggerService _log = GetIt.I<LoggerService>();

  final TextEditingController inviteCodeField = TextEditingController();

  final RxBool isValidatingInvite = false.obs;
  final RxBool isStartingGoogleSignIn = false.obs;
  final RxnString errorMessage = RxnString();

  bool get isBusy =>
      isValidatingInvite.value || isStartingGoogleSignIn.value;

  @override
  void onClose() {
    inviteCodeField.dispose();
    super.onClose();
  }

  /// New-user path. Validate the invite code with the backend, stash the
  /// short-lived `invite_token`, and hand off to the onboarding wizard
  /// (Phase 4). The token is consumed when the user reaches the Google
  /// sign-in step at the end of onboarding.
  Future<void> validateInviteAndStart() async {
    final code = inviteCodeField.text.trim();
    if (code.isEmpty) {
      errorMessage.value = 'Enter your invite code to get started.';
      return;
    }
    if (isBusy) return;

    isValidatingInvite.value = true;
    errorMessage.value = null;
    try {
      final inviteToken = await _authRepo.validateInvite(code);
      await _secure.writeInviteToken(inviteToken);
      // Wipe any stale session pair before minting a fresh one. A leftover
      // session_id from a previous run can already be OAuth-promoted on the
      // backend (sessions.user_id set), which trips MISSING_AUTH on the very
      // next pre-auth call (/profile, /analyze, …) because the backend then
      // demands a JWT we don't yet have.
      await _session.clear();
      await _session.ensureSessionId();
      _log.i('Invite accepted; routing into onboarding wizard');
      Get.offNamed<void>(AppRoutes.onboardingBusinessType);
    } on ApiException catch (e) {
      errorMessage.value = resolveApiExceptionMessage(e);
    } finally {
      isValidatingInvite.value = false;
    }
  }

  /// Open Google OAuth inside the in-app WebView ([OAuthWebViewView]).
  ///
  /// The WebView is configured with a Chrome desktop User-Agent so Google
  /// doesn't reject the request with `disallowed_useragent` (Google's
  /// "secure browser policy" detects the default Android WebView UA which
  /// contains the `; wv)` marker). The WebView's navigation delegate
  /// intercepts the backend redirect to `…/auth/callback#token=<jwt>` and
  /// pops the route with a typed [OAuthResult] — the user never leaves
  /// the app.
  ///
  /// - Welcome's "Sign in with Google" link calls this with no [inviteToken]
  ///   (returning user) and no override on [destinationRoute] — lands at
  ///   `/home`.
  /// - The inspiration step's first-heart handoff calls this with the
  ///   stored invite token (new-user signup) and `destinationRoute =
  ///   AppRoutes.onboardingGenerating` so the wizard resumes JWT-gated
  ///   and the generation step auto-fires `POST /generation`.
  Future<void> signInWithGoogle({
    String? inviteToken,
    String destinationRoute = AppRoutes.home,
  }) async {
    if (isBusy) return;
    isStartingGoogleSignIn.value = true;
    errorMessage.value = null;

    try {
      final sessionId = await _session.ensureSessionId();
      final authorizeUrl = await _authRepo.getGoogleAuthorizeUrl(
        sessionId: sessionId,
        inviteToken: inviteToken,
      );

      // NOTE: do NOT parameterise `Get.toNamed` with `<OAuthResult>`. GetX's
      // routing layer wraps the navigation result in a `Route<dynamic>` and
      // attempts an unchecked cast to `Route<T>` when a generic is supplied —
      // that throws `_TypeError: type 'GetPageRoute<dynamic>' is not a subtype
      // of type 'Route<OAuthResult?>'` at runtime. Take the dynamic payload
      // back and let Dart's pattern matching narrow it on real subtype.
      final dynamic raw = await Get.toNamed(
        AppRoutes.oauthWebview,
        arguments: authorizeUrl,
      );
      final OAuthResult? result = raw is OAuthResult ? raw : null;

      switch (result) {
        case OAuthSuccess():
          await _auth.acceptOAuthJwt(result.token);
          await _secure.clearInviteToken();
          Get.offAllNamed(destinationRoute);
        case OAuthError():
          if (result.reason == OAuthError.clientCancelled) return;
          errorMessage.value = _oauthErrorCopy(result.reason);
        case InstagramConnectSuccess():
          // Should not be reachable from the Google OAuth URL.
          errorMessage.value = 'Unexpected Instagram callback during sign-in.';
          _log.w('signInWithGoogle received InstagramConnectSuccess');
        case null:
          // User dismissed the WebView with the system back gesture before
          // either branch fired (the view's PopScope normally maps this
          // to clientCancelled, but be defensive about a null pop too).
          return;
      }
    } on ApiException catch (e) {
      errorMessage.value = resolveApiExceptionMessage(e);
    } finally {
      isStartingGoogleSignIn.value = false;
    }
  }

  String _oauthErrorCopy(String reason) {
    switch (reason) {
      case 'invite_required':
        return 'You need a valid invite code to create an account.';
      case OAuthError.clientMissingToken:
        return "Sign-in didn't return a token. Try again.";
      default:
        return 'Sign-in failed: $reason';
    }
  }
}
