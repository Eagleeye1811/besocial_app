import 'package:get_it/get_it.dart';

/// Application-wide service locator.
///
/// Call `setupDependencyInjection()` from `main()` **before** `runApp()`.
/// Registration order matters: core services (DB, storage, network) must be
/// registered and initialized before business services and repositories that
/// depend on them.
///
/// Resolve dependencies elsewhere with the shorthand `GetIt.I<T>()`.
Future<void> setupDependencyInjection() async {
  final getIt = GetIt.instance;

  // ==========================================
  // 1. Core Services
  // (DBService, StorageService, NetworkService, …)
  // ==========================================
  // getIt.registerLazySingleton<DBService>(() => DBService());
  // getIt.registerLazySingleton<StorageService>(() => StorageService());
  // getIt.registerLazySingleton<NetworkService>(() => NetworkService());

  // ==========================================
  // 2. Business Services
  // (AuthService, AnalyticsService, NotificationService, CacheService, …)
  // ==========================================
  // getIt.registerLazySingleton<AuthService>(() => AuthService());
  // getIt.registerLazySingleton<AnalyticsService>(() => AnalyticsService());

  // ==========================================
  // 3. Repositories
  // (UserRepository, ContentRepository, …)
  // ==========================================
  // getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl());

  // ==========================================
  // 4. Async Initialization
  // Order matters — DB before anything that reads from it.
  // ==========================================
  // await getIt<DBService>().init();
  // await getIt<StorageService>().init();
  // await getIt<NetworkService>().init();
  // getIt<AnalyticsService>().init();

  // Touch `getIt` so the unused-local lint is quiet until registrations land.
  assert(getIt.allReady is Future);
}
