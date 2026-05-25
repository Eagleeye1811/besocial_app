import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';

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

  /// Open Google OAuth in the device's default browser (external app).
  ///
  /// Google blocks OAuth in embedded WebViews under its "secure browser
  /// policy" — `disallowed_useragent` errors and `403 Access blocked: This
  /// app's request is invalid`. The fix is to use the system browser
  /// (Chrome / Safari) via `url_launcher` with `LaunchMode.externalApplication`.
  ///
  /// Callback handling: the backend redirects to
  ///   `FRONTEND_URL/auth/callback#token=<jwt>[&new_user=1]`
  /// or `FRONTEND_URL/auth/callback?error=<code>` on failure. For the
  /// callback to land back inside the app, the device must treat that URL
  /// as an app/universal link (`app_links` picks up the URI on Android via
  /// the manifest intent-filter and on iOS via associated domains). If the
  /// native link config isn't wired yet, the callback opens in the browser
  /// instead — the app times out after 5 minutes and the user re-tries.
  ///
  /// - Welcome's "Sign in with Google" link calls this with no [inviteToken]
  ///   (returning user) and no override on [destinationRoute] — lands at
  ///   `/home`.
  /// - The inspiration step's first-heart handoff calls this with the
  ///   stored invite token (new-user signup) and `destinationRoute =
  ///   AppRoutes.onboardingGenerating` so the wizard resumes JWT-gated.
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

      // Listen on the OS link channel *before* we launch the browser, so
      // we don't miss a fast callback. `app_links` emits URIs delivered to
      // the app via intent (Android) or NSUserActivity (iOS).
      final result = await _launchAndAwaitCallback(authorizeUrl);

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
      }
    } on ApiException catch (e) {
      errorMessage.value = resolveApiExceptionMessage(e);
    } finally {
      isStartingGoogleSignIn.value = false;
    }
  }

  /// Launch [authorizeUrl] in the system browser and await the OAuth
  /// callback URI that lands back in the app via `app_links`. Returns
  /// [OAuthError.clientCancelled] if the launch fails or the callback
  /// never arrives within the 5-minute budget.
  Future<OAuthResult> _launchAndAwaitCallback(String authorizeUrl) async {
    final appLinks = AppLinks();
    final completer = Completer<OAuthResult>();
    StreamSubscription<Uri>? sub;
    Timer? timeout;

    void finish(OAuthResult result) {
      if (completer.isCompleted) return;
      completer.complete(result);
      sub?.cancel();
      timeout?.cancel();
    }

    sub = appLinks.uriLinkStream.listen(
      (uri) {
        _log.i('OAuth callback uri received: ${uri.toString()}');
        if (!_isCallbackUri(uri)) return;
        finish(_parseCallback(uri));
      },
      onError: (Object e, StackTrace st) {
        _log.w('app_links stream error: $e');
      },
    );

    timeout = Timer(const Duration(minutes: 5), () {
      _log.w('OAuth callback timed out after 5 minutes');
      finish(const OAuthError(OAuthError.clientCancelled));
    });

    final launched = await launchUrl(
      Uri.parse(authorizeUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      finish(const OAuthError(OAuthError.clientCancelled));
      _log.w('launchUrl returned false for $authorizeUrl');
    }

    return completer.future;
  }

  bool _isCallbackUri(Uri uri) =>
      uri.path.endsWith('/auth/callback') ||
      uri.path.endsWith('/onboarding/instagram-connect');

  OAuthResult _parseCallback(Uri uri) {
    final error = uri.queryParameters['error'];
    if (error != null) return OAuthError(error);

    final fragmentParams = uri.fragment.isEmpty
        ? const <String, String>{}
        : Uri.splitQueryString(uri.fragment);
    final token = fragmentParams['token'];
    final newUserFlag = fragmentParams['new_user'];

    if (token == null || token.isEmpty) {
      return const OAuthError(OAuthError.clientMissingToken);
    }
    return OAuthSuccess(token: token, isNewUser: newUserFlag == '1');
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
