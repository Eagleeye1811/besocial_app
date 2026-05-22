import 'package:get/get.dart';

import '../../data/models/user_model.dart';
import '../../repository/auth_repository/auth_repository.dart';
import '../../repository/session_repository/session_repository.dart';
import '../network/api_exception.dart';
import 'logger_service.dart';
import 'secure_storage_service.dart';

/// Owns JWT lifecycle and the observable [currentUser] reactive state.
///
/// State is exposed as GetX `Rx` so any view that wants to react to login /
/// logout (auth-gated routes, profile chips, settings) just listens. The
/// service itself stays free of UI concerns — the in-app OAuth WebView
/// and its redirect handling live in `AuthController` + `OAuthWebView`.
class AuthService {
  final AuthRepository _repo;
  final SessionRepository _session;
  final SecureStorageService _secure;
  final LoggerService _log;

  final Rxn<UserModel> _currentUser = Rxn<UserModel>();
  final RxBool _isReady = false.obs;

  AuthService({
    required AuthRepository repo,
    required SessionRepository session,
    required SecureStorageService secure,
    required LoggerService log,
  })  : _repo = repo,
        _session = session,
        _secure = secure,
        _log = log;

  Rxn<UserModel> get currentUserRx => _currentUser;
  UserModel? get currentUser => _currentUser.value;
  bool get isAuthenticated => _currentUser.value != null;
  RxBool get isReadyRx => _isReady;

  /// Called once from the splash screen. Reads the persisted JWT (if any)
  /// and validates it by fetching `/auth/me`; clears the token on
  /// `INVALID_TOKEN` / `USER_NOT_FOUND` so the user is bounced to welcome.
  ///
  /// **Never throws.** Any failure (network down, secure-storage glitch,
  /// unexpected exception) results in `_currentUser = null` and a logged
  /// warning, so the splash always has a routing answer.
  Future<void> bootFromStorage() async {
    try {
      final String? jwt = await _secure.readJwt();
      if (jwt == null || jwt.isEmpty) {
        _currentUser.value = null;
        return;
      }
      try {
        final user = await _repo.getCurrentUser();
        _currentUser.value = user;
        _log.i('AuthService boot: signed in as ${user.email}');
      } on ApiException catch (e) {
        // The repository unwraps Dio for us, so we receive `ApiException`
        // directly. `INVALID_TOKEN` / `USER_NOT_FOUND` mean the stored JWT
        // is truly dead — wipe it. Anything else (timeout, network, 5xx)
        // is a transient blip; keep the JWT for the next launch.
        if (e.code == 'INVALID_TOKEN' || e.code == 'USER_NOT_FOUND') {
          _log.w(
              'AuthService boot: stored JWT rejected (${e.code}); clearing');
          await _secure.clearJwt();
        } else {
          _log.w(
              'AuthService boot: /me failed (${e.code}); keeping JWT, routing to welcome');
        }
        _currentUser.value = null;
      }
    } catch (e, st) {
      // Catch-all so the splash never deadlocks on us. Examples that land
      // here: secure-storage platform exception, programmer error in the
      // repository layer, etc.
      _log.e('AuthService boot: unexpected failure', error: e, stackTrace: st);
      _currentUser.value = null;
    } finally {
      _isReady.value = true;
    }
  }

  /// Persist a freshly-issued JWT and refresh the user. Called by
  /// `AuthController` after the OAuth WebView returns a token. The session
  /// pair is wiped because the backend has already promoted the anonymous
  /// session into the user account.
  Future<void> acceptOAuthJwt(String token) async {
    await _secure.writeJwt(token);
    await _session.clear();
    final user = await _repo.getCurrentUser();
    _currentUser.value = user;
    _log.i('AuthService: signed in as ${user.email}');
  }

  /// Wipe all credentials and observable state. Backend has no logout
  /// endpoint, so this is purely local.
  Future<void> logout() async {
    await _secure.clearAll();
    _currentUser.value = null;
    _log.i('AuthService: logged out');
  }
}
