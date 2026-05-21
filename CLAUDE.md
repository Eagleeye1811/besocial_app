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