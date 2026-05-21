/// Centralized string and integer keys used by Hive, secure storage, and
/// non-sensitive preferences. Anything written to persistent storage names
/// itself from this file so the box/key universe is searchable.
class AppKeys {
  AppKeys._();

  static const HiveBoxNames hiveBoxes = HiveBoxNames._();
  static const SecureStorageKeys secureKeys = SecureStorageKeys._();
  static const PrefKeys prefs = PrefKeys._();
  static const EnvKeys env = EnvKeys._();
  // Hive type IDs live on [HiveTypeIds] directly (static const) so they're
  // usable inside `@HiveType(typeId: …)` annotations, which require
  // compile-time constants.
}

class HiveBoxNames {
  const HiveBoxNames._();

  /// Non-sensitive key/value preferences (theme, last-tab, etc.).
  String get settings => 'settings';

  // Feature caches — declared here for visibility; each phase opens the box
  // it owns inside its repository module rather than eagerly here.
  String get usersCache => 'cache_users';
  String get draftsCache => 'cache_drafts';
  String get shortlistCache => 'cache_shortlist';
  String get brandCache => 'cache_brand';
}

class SecureStorageKeys {
  const SecureStorageKeys._();

  String get jwt => 'auth_jwt';
  String get sessionId => 'session_id';
  String get sessionToken => 'session_token';
  String get inviteToken => 'invite_token';
  String get instagramConnectedAt => 'ig_connected_at';
}

class PrefKeys {
  const PrefKeys._();

  String get lastSeenOnboardingStep => 'last_seen_onboarding_step';
  String get hasCompletedOnboarding => 'has_completed_onboarding';
  String get lastDashboardTab => 'last_dashboard_tab';
}

/// Reserve `typeId` ranges so adapters in later phases never collide.
///
/// `static const` so values resolve at compile time — required by Hive's
/// `@HiveType(typeId: …)` annotation.
class HiveTypeIds {
  HiveTypeIds._();

  // 0–19: identity & session
  static const int userModel = 0;
  static const int sessionModel = 1;

  // 20–39: feed / discovery
  static const int discoverPost = 20;
  static const int trendingPost = 21;
  static const int recentPost = 22;

  // 40–59: shortlist / drafts / generation
  static const int shortlistItem = 40;
  static const int draft = 41;
  static const int generationJob = 42;
  static const int mode2Config = 43;
  static const int shortlistGenerationStatus = 44;

  // 60–79: brand
  static const int brandProfile = 60;
  static const int brandAsset = 61;

  // 80–99: instagram
  static const int instagramStatus = 80;

  // 100+ reserved for niche/analysis sub-models.
}

class EnvKeys {
  const EnvKeys._();

  String get apiBaseUrl => 'API_BASE_URL';
}
