import 'package:hive/hive.dart';

import '../constants/app_keys.dart';
import 'db_service.dart';

/// Non-sensitive key/value preferences (theme mode, last-seen tab, etc.).
///
/// Backed by the Hive `settings` box that [DbService] opens during init.
/// Anything secret (tokens, credentials) belongs in [SecureStorageService].
class StorageService {
  final DbService _db;
  Box<dynamic>? _box;

  StorageService(this._db);

  Future<void> init() async {
    _box = await _db.openBox<dynamic>(AppKeys.hiveBoxes.settings);
  }

  Box<dynamic> get _required {
    final box = _box;
    if (box == null) {
      throw StateError(
        'StorageService used before init() — call from setupDependencyInjection.',
      );
    }
    return box;
  }

  // ===== Typed getters =====
  String getString(String key, {String defaultValue = ''}) =>
      _required.get(key, defaultValue: defaultValue) as String;

  int getInt(String key, {int defaultValue = 0}) =>
      _required.get(key, defaultValue: defaultValue) as int;

  bool getBool(String key, {bool defaultValue = false}) =>
      _required.get(key, defaultValue: defaultValue) as bool;

  T? get<T>(String key) => _required.get(key) as T?;

  // ===== Setters =====
  Future<void> set<T>(String key, T value) => _required.put(key, value);

  Future<void> remove(String key) => _required.delete(key);

  Future<void> clear() => _required.clear();

  // ===== Domain helpers =====
  String? get lastOnboardingStep =>
      _required.get(AppKeys.prefs.lastSeenOnboardingStep) as String?;

  Future<void> setLastOnboardingStep(String step) =>
      _required.put(AppKeys.prefs.lastSeenOnboardingStep, step);

  bool get hasCompletedOnboarding =>
      _required.get(
        AppKeys.prefs.hasCompletedOnboarding,
        defaultValue: false,
      ) as bool;

  Future<void> setOnboardingCompleted(bool value) =>
      _required.put(AppKeys.prefs.hasCompletedOnboarding, value);
}
