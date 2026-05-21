import 'package:get_it/get_it.dart';

import 'core/network/dio_client.dart';
import 'core/services/auth_service.dart';
import 'core/services/db_service.dart';
import 'core/services/logger_service.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/storage_service.dart';
import 'repository/auth_repository/auth_repository.dart';
import 'repository/session_repository/session_repository.dart';

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
  // 3. Repositories
  // ==========================================
  getIt.registerLazySingleton<SessionRepository>(
    () => SessionRepository(getIt<SecureStorageService>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<DioClient>()),
  );

  // ==========================================
  // 4. Business Services
  // ==========================================
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(
      repo: getIt<AuthRepository>(),
      session: getIt<SessionRepository>(),
      secure: getIt<SecureStorageService>(),
      log: getIt<LoggerService>(),
    ),
  );

  // ==========================================
  // 5. Async initialization (order matters)
  // ==========================================
  await getIt<DbService>().init();
  await getIt<StorageService>().init();

  // Touch DioClient so its interceptor chain is built once at boot rather
  // than on first request — cheap and surfaces config errors immediately.
  getIt<DioClient>();
}
