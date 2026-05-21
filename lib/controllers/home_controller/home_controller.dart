import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../core/constants/error_messages.dart';
import '../../core/network/api_exception.dart';
import '../../core/services/logger_service.dart';
import '../../data/dto/dashboard_home_dto.dart';
import '../../data/dto/dashboard_recent_post_dto.dart';
import '../../data/dto/dashboard_trending_dto.dart';
import '../../repository/dashboard_repository/dashboard_repository.dart';

/// Owns the three lists on `/home`. Each is loaded in parallel on `onReady`,
/// each has its own error/loading flag so a flaky carousel doesn't take down
/// the whole screen. Mirrors `frontend/src/features/dashboard/store.js`.
class HomeController extends GetxController {
  final DashboardRepository _repo = GetIt.I<DashboardRepository>();
  final LoggerService _log = GetIt.I<LoggerService>();

  final Rxn<DashboardHomeDto> home = Rxn<DashboardHomeDto>();
  final RxList<DashboardRecentPostDto> recentPosts =
      <DashboardRecentPostDto>[].obs;
  final RxList<DashboardTrendingPostDto> trending =
      <DashboardTrendingPostDto>[].obs;

  final RxBool isLoadingHome = false.obs;
  final RxBool isLoadingRecent = false.obs;
  final RxBool isLoadingTrending = false.obs;

  final RxnString homeError = RxnString();
  final RxnString recentError = RxnString();
  final RxnString trendingError = RxnString();

  @override
  void onReady() {
    super.onReady();
    refreshAll();
  }

  Future<void> refreshAll() async {
    await Future.wait<void>([
      _loadHome(),
      _loadRecent(),
      _loadTrending(),
    ]);
  }

  Future<void> _loadHome() async {
    isLoadingHome.value = true;
    homeError.value = null;
    try {
      home.value = await _repo.getHome();
    } on ApiException catch (e) {
      homeError.value = resolveApiExceptionMessage(e);
      _log.w('GET /dashboard/home failed: ${e.code}');
    } finally {
      isLoadingHome.value = false;
    }
  }

  Future<void> _loadRecent() async {
    isLoadingRecent.value = true;
    recentError.value = null;
    try {
      final posts = await _repo.getRecentPosts();
      recentPosts.assignAll(posts);
    } on ApiException catch (e) {
      recentError.value = resolveApiExceptionMessage(e);
      _log.w('GET /dashboard/recent-posts failed: ${e.code}');
    } finally {
      isLoadingRecent.value = false;
    }
  }

  Future<void> _loadTrending() async {
    isLoadingTrending.value = true;
    trendingError.value = null;
    try {
      final posts = await _repo.getTrending();
      trending.assignAll(posts);
    } on ApiException catch (e) {
      trendingError.value = resolveApiExceptionMessage(e);
      _log.w('GET /dashboard/trending failed: ${e.code}');
    } finally {
      isLoadingTrending.value = false;
    }
  }
}
