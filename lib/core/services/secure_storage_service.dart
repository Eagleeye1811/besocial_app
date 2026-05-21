import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_keys.dart';

/// Encrypted storage for credentials only: JWT, the onboarding session pair,
/// and any short-lived OAuth tokens. Non-sensitive prefs belong in
/// [StorageService] (Hive) instead.
///
/// Android uses `EncryptedSharedPreferences`; iOS uses Keychain with
/// `first_unlock_this_device` so a logged-in user can resume after reboot
/// without re-entering biometrics.
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

  // ===== Onboarding session pair =====
  Future<({String? id, String? token})> readSessionPair() async {
    final id = await _storage.read(key: AppKeys.secureKeys.sessionId);
    final token = await _storage.read(key: AppKeys.secureKeys.sessionToken);
    return (id: id, token: token);
  }

  Future<void> writeSessionPair({
    required String sessionId,
    required String sessionToken,
  }) async {
    await _storage.write(key: AppKeys.secureKeys.sessionId, value: sessionId);
    await _storage.write(
      key: AppKeys.secureKeys.sessionToken,
      value: sessionToken,
    );
  }

  Future<void> clearSessionPair() async {
    await _storage.delete(key: AppKeys.secureKeys.sessionId);
    await _storage.delete(key: AppKeys.secureKeys.sessionToken);
  }

  // ===== Short-lived invite token (between /invite/validate and /google) =====
  Future<String?> readInviteToken() =>
      _storage.read(key: AppKeys.secureKeys.inviteToken);

  Future<void> writeInviteToken(String token) =>
      _storage.write(key: AppKeys.secureKeys.inviteToken, value: token);

  Future<void> clearInviteToken() =>
      _storage.delete(key: AppKeys.secureKeys.inviteToken);

  /// Wipe every secret. Called on logout.
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
