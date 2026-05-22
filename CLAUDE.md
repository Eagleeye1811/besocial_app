# BeSocial Standalone Mobile Project Memory

## Tech Stack & Architecture Architecture
- **Framework:** Flutter & Dart (Stable channel)
- **Architecture Style:** Layer-First Clean Architecture (Presentation, Business Logic, Data Access, Data Sources)
- **State Management & Routing:** GetX (`Obx()`, `GetView<T>`, `Bindings`, `GetPage`)
- **Dependency Injection:** GetIt (`GetIt.instance` / `GetIt.I` Service Locator)
- **Local Persistence:** Hive NoSQL (`HiveObject`, TypeAdapters, Enforced Immutability via copyWith)
- **Networking Engine:** Dio Client with interceptor token authentication handlers

## System Boundaries & Guardrails
- **CRITICAL:** This directory (`besocial_app`) is permanently independent.
- The path `../besocial` contains the existing backend logic. It is **STRICTLY READ-ONLY**. Do not edit models or push changes inside `../besocial`.

## Complete Directory Map & Structural Rules
- `lib/common_widgets/` - Highly reusable UI components. Must remain stateless with NO business logic.
- `lib/controllers/` - State management & business logic. Strictly NO UI code or BuildContext operations.
- `lib/core/` - Stateless app-wide utilities (constants, extensions, helpers, routes, services, theme).
- `lib/data/` - Data definitions split into `models/` (Hive data models) and `dto/` (Data Transfer Objects).
- `lib/repository/` - Data access abstractions serving as the interface between data sources and business logic.
- `lib/views/` - UI screens containing presentational layouts only. Minimal logic.

## Build, Test, & Code-Gen Commands
- Code Generation: `dart run build_runner build --delete-conflicting-outputs`
- Watch Generation: `dart run build_runner watch --delete-conflicting-outputs`
- Analysis: `flutter analyze`
- Testing suites: `flutter test`

## Production Backend
- Canonical FastAPI host: `https://api.growgram.app` (cert SAN matches, `/health` returns the standard envelope).
- `lib/core/network/api_config.dart` defaults `baseUrl` to that host. Override for local dev:
  `flutter run --dart-define=API_BASE_URL=http://<LAN-IP>:8000`
- Source of truth for the hostname is `../besocial/docker-compose.yml` (frontend bake-in arg `VITE_API_BASE_URL`). The FastAPI app itself is host-agnostic.

## Delivery Status — Phase 0 → Phase 13 (complete)
All 13 phases of the Master Action Plan are delivered, manually verified end-to-end against the live backend, and compile cleanly (`flutter analyze`: no issues). The app builds and runs on Android with the network layer hardened (manifest INTERNET permission, off-release `badCertificateCallback` bypass, Dio envelope + error-mapper interceptor chain, repository-wide `unwrapDio` so controllers only ever see `ApiException`).

- **Phase 0** — Project scaffold, tooling, lint baseline.
- **Phase 1** — Core network & services foundation (`api_envelope`, `api_exception`, `dio_client`, `secure_storage_service`, `logger_service`, `polling_service`).
- **Phase 2** — Hive setup, type adapters, registration.
- **Phase 3** — Auth surface: `auth_repository`, `auth_service`, in-app WebView OAuth (`OAuthWebViewView`), invite-gated signup, JWT persistence.
- **Phase 4** — Onboarding repository + the full 15-step onboarding flow with bindings and routes.
- **Phase 5** — Generation pipeline: `generation_repository`, `Poller.until` integration, in-onboarding generation step.
- **Phase 6** — Brand profile & assets (read + PATCH + asset list/upload/delete).
- **Phase 7** — Discover feed (cursor pagination, refresh).
- **Phase 8** — Shortlist (add/remove/refresh, persistence).
- **Phase 9** — Drafts list + result detail sheet (slide carousel inline).
- **Phase 10** — Dashboard home (recent posts, trending, summary cards).
- **Phase 11** — Instagram integration (auth URL, status, post). WebView intercepts `?success=` callback.
- **Phase 12** — Mode 2 generation config sheet (style source discriminated union).
- **Phase 13** — Settings dashboard (logout, IG connect/reconnect, version, session wipe), accordion brand profile editor, native IG link channel.

## Known Follow-ups / Intentional Cuts
Items deliberately deferred from the Master Plan. None block production; each is logged for selective polish.

- **Brand asset upload in onboarding step 11** — wire `image_picker` into the brand-assets step UI; backend endpoint already exists.
- **"Match specific post" picker grid** in the detected-style flow (currently free-text).
- **Gesture swipe deck in InspirationStep** — replace the current tap-driven card with a swipe deck.
- **Discover refresh status polling** — needs a backend status endpoint before the spinner can be replaced with real progress.
- **Mode 2 config asset/post pickers** — replace free-text inputs with the asset list + post grid pickers.
- **Instagram disconnect endpoint** — backend addition; UI only offers Connect/Reconnect today.
- **Shared slide carousel** — extract the inline carousel duplicated between `result_step.dart` and `post_detail_sheet.dart` into `common_widgets/slide_carousel.dart`.
- **iOS `Info.plist` permission strings** — add camera/photo-library usage descriptions for image_picker once the asset upload is wired.
- **Typed brand niche/personalization for Hive caching** — currently stored as a generic `Map`.
- **`package_info_plus` for real version string** — Settings shows a hard-coded version today.
- **Android `network_security_config.xml`** — optional hardening to scope `usesCleartextTraffic` to debug domains only; current global flag is fine for staging dev.