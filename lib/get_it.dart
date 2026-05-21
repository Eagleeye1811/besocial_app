import 'package:get_it/get_it.dart';

import 'core/network/dio_client.dart';
import 'core/services/db_service.dart';
import 'core/services/logger_service.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/storage_service.dart';

/// Application-wide service locator.
///
/// Call `setupDependencyInjection()` from `main()` **before** `runApp()`.
/// Registration order matters: core services (DB, storage, network) must be
/// registered and initialized before business services and repositories that
/// depend on them. Inside the app, resolve with the shorthand `GetIt.I<T>()`.
Future<void> setupDependencyInjection() async {
  final getIt = GetIt.instance;

  // ==========================================
  // 1. Core Services
  // ==========================================
  getIt.registerLazySingleton<LoggerService>(LoggerService.new);
  getIt.registerLazySingleton<SecureStorageService>(SecureStorageService.new);
  getIt.registerLazySingleton<DbService>(
    () => DbService(getIt<LoggerService>()),
  );
  getIt.registerLazySingleton<StorageService>(
    () => StorageService(getIt<DbService>()),
  );

  // ==========================================
  // 2. Network
  // ==========================================
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(
      secureStorage: getIt<SecureStorageService>(),
      logger: getIt<LoggerService>(),
    ),
  );

  // ==========================================
  // 3. Business Services (Phase 3+)
  // ==========================================
  // getIt.registerLazySingleton<AuthService>(...)

  // ==========================================
  // 4. Repositories (Phase 3+)
  // ==========================================
  // getIt.registerLazySingleton<AuthRepository>(...)

  // ==========================================
  // 5. Async Initialization (order matters)
  // ==========================================
  await getIt<DbService>().init();
  await getIt<StorageService>().init();

  // Touch DioClient so its interceptor chain is built once at boot rather
  // than on first request — cheap and surfaces config errors immediately.
  getIt<DioClient>();
}
