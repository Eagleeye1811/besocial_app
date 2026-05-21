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
      await _session.ensureSessionId();
      _log.i('Invite accepted; routing into onboarding');
      // Phase 4 will register `AppRoutes.onboardingBusiness` etc. For now,
      // stay on welcome — the user can sign in with Google to test e2e.
      Get.snackbar(
        'Invite accepted',
        'Onboarding wizard arrives in Phase 4.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (e) {
      errorMessage.value = resolveApiExceptionMessage(e);
    } finally {
      isValidatingInvite.value = false;
    }
  }

  /// Returning-user path. Open Google OAuth in the in-app WebView with only
  /// the session id (no invite token) — the backend skips the invite gate
  /// when `google_sub` already maps to a user.
  Future<void> signInWithGoogle({String? inviteToken}) async {
    if (isBusy) return;
    isStartingGoogleSignIn.value = true;
    errorMessage.value = null;

    try {
      final sessionId = await _session.ensureSessionId();
      final authorizeUrl = await _authRepo.getGoogleAuthorizeUrl(
        sessionId: sessionId,
        inviteToken: inviteToken,
      );

      final result = await Get.toNamed<dynamic>(
        AppRoutes.oauthWebview,
        arguments: authorizeUrl,
      );

      if (result is! OAuthResult) {
        // User dismissed via system gesture before the WebView dispatched.
        return;
      }
      switch (result) {
        case OAuthSuccess():
          await _auth.acceptOAuthJwt(result.token);
          await _secure.clearInviteToken();
          Get.offAllNamed(AppRoutes.home);
        case OAuthError():
          if (result.reason == OAuthError.clientCancelled) return;
          errorMessage.value = _oauthErrorCopy(result.reason);
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
