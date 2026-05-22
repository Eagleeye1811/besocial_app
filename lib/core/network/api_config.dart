/// Centralized API Endpoint Registry for the BeSocial Independent Client.
///
/// Paths mirror the FastAPI routers in `../besocial/backend/src/api/routes/`.
/// Every router there mounts under `/api/v1/...`, so `baseUrl` is the bare
/// host and each constant includes the full `/api/v1` prefix verbatim.
class ApiConfig {
  // Production host of the FastAPI backend. Confirmed via
  // `docker-compose.yml` in the backend repo (frontend bake-in arg
  // `VITE_API_BASE_URL: https://api.growgram.app/api/v1`) and verified
  // live: GET /health returns the standard envelope and the cert SAN is
  // `api.growgram.app`. Override at run time for local dev:
  //   flutter run --dart-define=API_BASE_URL=http://<LAN-IP>:8000
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.growgram.app',
  );

  // ==========================================
  // Authentication & Session Endpoints
  // (src/api/routes/auth.py — prefix /api/v1/auth)
  // Backend is Google OAuth + invite-gated signup; no password login/register.
  // ==========================================
  static const String googleAuthorizeUrl = '$baseUrl/api/v1/auth/google';
  static const String googleCallback = '$baseUrl/api/v1/auth/google/callback';
  static const String inviteValidate = '$baseUrl/api/v1/auth/invite/validate';
  static const String currentUser = '$baseUrl/api/v1/auth/me';

  // ==========================================
  // User Profile Endpoints
  // (src/api/routes/onboarding.py — prefix /api/v1/onboarding,
  //  src/api/routes/brand.py — prefix /api/v1/brand)
  // ==========================================
  static const String onboardingProfile = '$baseUrl/api/v1/onboarding/profile';
  static const String onboardingProfileImage = '$baseUrl/api/v1/onboarding/profile-image';
  static const String onboardingSession = '$baseUrl/api/v1/onboarding/session';
  static const String brandProfile = '$baseUrl/api/v1/brand';

  // ==========================================
  // Social Engine & Content Feed Endpoints
  // (src/api/routes/dashboard/*.py — prefix /api/v1/dashboard)
  // ==========================================
  static const String homeFeed = '$baseUrl/api/v1/dashboard/home';
  static const String recentPosts = '$baseUrl/api/v1/dashboard/recent-posts';
  static const String trendingFeed = '$baseUrl/api/v1/dashboard/trending';
  static const String discoverFeed = '$baseUrl/api/v1/dashboard/discover/feed';
  static const String discoverSwipe = '$baseUrl/api/v1/dashboard/discover/swipe';
  static const String discoverRefresh = '$baseUrl/api/v1/dashboard/discover/refresh';
  static const String drafts = '$baseUrl/api/v1/dashboard/drafts';
  static const String shortlist = '$baseUrl/api/v1/dashboard/shortlist';
}
