# BeSocial Standalone Mobile Project Memory

## Tech Stack & Architecture Architecture
- **Framework:** Flutter & Dart (Stable channel)
- **Architecture Style:** Layer-First Clean Architecture (Presentation, Business Logic, Data Access, Data Sources)
- **State Management & Routing:** GetX (`Obx()`, `GetView<T>`, `Bindings`, `GetPage`)
- **Dependency Injection:** GetIt (`GetIt.instance` / `GetIt.I` Service Locator)
- **Local Persistence:** Hive NoSQL (`HiveObject`, TypeAdapters, Enforced Immutability via copyWith)
- **Networking Engine:** Dio Client with interceptor token authentication handlers

## System Boundaries & Guardrails
- **CRITICAL:** This directory (`besocial_app`) is permanently independent. It will never merge or combine with the core codebase.
- The path `../besocial` contains the existing backend logic. It is **STRICTLY READ-ONLY**. Do not edit models or push changes inside `../besocial`.
- Use the endpoint routing schemas, schemas, and data shapes in `../besocial` purely as a reference blueprint to reproduce system logic natively in Dart.

## Complete Directory Map & Structural Rules
All new code files must strictly reside in their designated architectural layers under `lib/`:
- `common_widgets/` - Highly reusable UI components. Must remain stateless with **NO** business logic.
- `controllers/` - State management & business logic. Strictly **NO** UI code or `BuildContext` operations.
- `core/` - Stateless app-wide utilities, split explicitly into:
  - `constants/` - Color palettes (`app_colors.dart`), assets (`app_assets.dart`), and box keys (`app_keys.dart`).
  - `extensions/` - Native Dart extensions (`string_extension.dart`, `context_extension.dart`).
  - `helpers/` - Pure stateless utility operations (`validation_helper.dart`).
  - `routes/` - Navigation blueprints (`app_routes.dart`) and Route Guards via `GetMiddleware`.
  - `services/` - Stateless singletons providing global functionality (`db_service.dart`, `storage_service.dart`).
  - `theme/` - Dynamic visual configurations (`app_theme.dart`).
- `data/` - Data definitions split into `models/` (Hive data models) and `dto/` (Data Transfer Objects for API requests/responses).
- `l10n/` - App localization schemas (`.arb` format).
- `repository/` - Data access abstractions serving as the interface between data sources and business logic.
- `views/` - UI screens containing presentational layouts only. Minimal logic.

## Code Style & Idioms
- **GetX Pattern:** Always use private reactive variables with public immutable getters in controllers (e.g., `final RxBool _isLoading = false.obs; bool get isLoading => _isLoading.value;`).
- **Granular Rendering:** Prefer `Obx()` for precise, granular reactive UI updates instead of broad `GetBuilder` scopes.
- **Lazy Loaders:** Utilize `Get.lazyPut()` in your bindings instead of immediate instance pinning unless otherwise required.
- **Hive Constraints:** Every persistent model must inherit from `HiveObject`, implement a unique `typeId`, provide standard sequential `@HiveField(x)` tags, and implement `copyWith()`, `toJson()`, and `fromJson()`.
- **DI Isolation:** Register all singletons and repositories inside `lib/get_it.dart`. Do not call `GetIt` inside the widget `build` layer; inject services straight to your controllers.
- **Safe Arguments:** Never pass complex runtime objects via navigation parameters. Pass unique item `IDs` as primitive keys and fetch data through the repository layer.

## Build, Test, & Code-Gen Commands
- Code Generation: `dart run build_runner build --delete-conflicting-outputs`
- Watch Generation: `dart run build_runner watch --delete-conflicting-outputs`
- Analysis: `flutter analyze`
- Format: `flutter format lib/`
- Testing suites: `flutter test`