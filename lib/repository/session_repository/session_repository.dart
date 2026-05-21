import 'package:uuid/uuid.dart';

import '../../core/services/secure_storage_service.dart';

/// Owns the anonymous onboarding session pair (`X-Session-ID` + `X-Session-Token`).
///
/// The web client generates a UUID v4 the first time it ever needs one and
/// reuses it across the entire onboarding wizard. We mirror that behaviour —
/// `ensureSessionId()` returns the existing id or mints a new one on demand.
/// The matching session token is minted later by `POST /onboarding/profile`
/// and stored via [acceptSessionToken].
class SessionRepository {
  final SecureStorageService _secure;
  final Uuid _uuid;

  SessionRepository(this._secure, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  /// Return the persisted session id, generating and storing a new UUID v4
  /// the first time it is requested. Idempotent.
  Future<String> ensureSessionId() async {
    final existing = await _secure.readSessionId();
    if (existing != null && existing.isNotEmpty) return existing;
    final fresh = _uuid.v4();
    await _secure.writeSessionId(fresh);
    return fresh;
  }

  Future<String?> getSessionId() => _secure.readSessionId();

  Future<String?> getSessionToken() => _secure.readSessionToken();

  /// Persist the HMAC token returned by the backend's `POST /onboarding/profile`
  /// so subsequent onboarding requests can attach `X-Session-Token`.
  Future<void> acceptSessionToken(String token) =>
      _secure.writeSessionToken(token);

  /// Wipe the session pair — used after OAuth promotion (the session has been
  /// promoted to a user) and on explicit logout.
  Future<void> clear() => _secure.clearSessionPair();
}
