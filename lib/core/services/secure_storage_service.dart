import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_keys.dart';

/// Encrypted storage for credentials only: JWT, the onboarding session pair,
/// and any short-lived OAuth tokens. Non-sensitive prefs belong in
/// [StorageService] (Hive) instead.
///
/// iOS uses Keychain with `first_unlock_this_device` so a logged-in user can
/// resume after reboot without re-entering biometrics. Android uses the
/// library default (`EncryptedSharedPreferences` was deprecated upstream and
/// is now provided transparently).
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  // ===== JWT =====
  Future<String?> readJwt() => _storage.read(key: AppKeys.secureKeys.jwt);

  Future<void> writeJwt(String token) =>
      _storage.write(key: AppKeys.secureKeys.jwt, value: token);

  Future<void> clearJwt() => _storage.delete(key: AppKeys.secureKeys.jwt);

  // ===== Onboarding session ID =====
  Future<String?> readSessionId() =>
      _storage.read(key: AppKeys.secureKeys.sessionId);

  Future<void> writeSessionId(String id) =>
      _storage.write(key: AppKeys.secureKeys.sessionId, value: id);

  Future<void> clearSessionId() =>
      _storage.delete(key: AppKeys.secureKeys.sessionId);

  // ===== Onboarding session token (minted by POST /onboarding/profile) =====
  Future<String?> readSessionToken() =>
      _storage.read(key: AppKeys.secureKeys.sessionToken);

  Future<void> writeSessionToken(String token) =>
      _storage.write(key: AppKeys.secureKeys.sessionToken, value: token);

  Future<void> clearSessionToken() =>
      _storage.delete(key: AppKeys.secureKeys.sessionToken);

  // ===== Convenience: read/write/clear both at once =====
  Future<({String? id, String? token})> readSessionPair() async {
    final id = await readSessionId();
    final token = await readSessionToken();
    return (id: id, token: token);
  }

  Future<void> writeSessionPair({
    required String sessionId,
    required String sessionToken,
  }) async {
    await writeSessionId(sessionId);
    await writeSessionToken(sessionToken);
  }

  Future<void> clearSessionPair() async {
    await clearSessionId();
    await clearSessionToken();
  }

  // ===== Short-lived invite token =====
  Future<String?> readInviteToken() =>
      _storage.read(key: AppKeys.secureKeys.inviteToken);

  Future<void> writeInviteToken(String token) =>
      _storage.write(key: AppKeys.secureKeys.inviteToken, value: token);

  Future<void> clearInviteToken() =>
      _storage.delete(key: AppKeys.secureKeys.inviteToken);

  /// Wipe every secret. Called on logout.
  Future<void> clearAll() => _storage.deleteAll();
}
