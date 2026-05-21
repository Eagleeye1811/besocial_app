# BeSocial Standalone Mobile Project Memory

## Tech Stack
- Framework: Flutter & Dart (Stable channel)
- State Management: Riverpod (Generated code via riverpod_generator)
- Networking Engine: Dio (With explicit token/interceptor handling)
- Local Cache: flutter_secure_storage (for JWT tokens)

## System Boundaries & Guardrails
- **CRITICAL:** This directory (`besocial_app`) is permanently independent. It will never merge or combine with the core codebase.
- The path `../besocial` contains the existing backend logic and website client. It is **STRICTLY READ-ONLY**. Do not attempt to run migrations, edit models, or push changes inside `../besocial`.
- Use the endpoint routing schemas, security interceptors, and data shapes in `../besocial` purely as a reference blueprint to reproduce system logic natively in Dart.
- All communications must occur over the network hitting production or staging environment URLs. Never write relative local file dependencies pointing to the blueprint folder.

## Build & Test Commands
- Check compilation errors: `flutter analyze`
- Run localization/build runners: `dart run build_runner build --delete-conflicting-outputs`
- Run target tests: `flutter test`
- Add third party dependencies: `flutter pub add <package_name>`

## Code Styles & Idioms
- Always utilize clean, decoupled feature-first directory modularization: `features/[feature_name]/data/` and `features/[feature_name]/presentation/`.
- Use type-safe, immutable data models utilizing `json_annotation` serialization rules.
- Centralize all API configurations inside `lib/core/network/api_config.dart`.