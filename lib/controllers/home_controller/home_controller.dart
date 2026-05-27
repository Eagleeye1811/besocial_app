import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../core/constants/error_messages.dart';
import '../../core/network/api_exception.dart';
import '../../core/services/logger_service.dart';
import '../../data/dto/dashboard_home_dto.dart';
import '../../data/dto/dashboard_recent_post_dto.dart';
import '../../data/dto/dashboard_trending_dto.dart';
import '../../repository/dashboard_repository/dashboard_repository.dart';

/// Drives `/home`. Mirrors `frontend/src/features/dashboard/pages/HomePage.jsx`
/// one-for-one: a single effect fires `getDashboardHome()`, `getRecentPosts(5)`
/// and `getTrending(5)` in parallel (`Promise.all`), surfaces the first
/// failure as one page-level error, and otherwise commits all three payloads
/// together. The trending-heart shortlist state mirrors the web store's
/// `shortlistedFromTrending` map.
class HomeController extends GetxController {
  final DashboardRepository _repo = GetIt.I<DashboardRepository>();
  final LoggerService _log = GetIt.I<LoggerService>();

  final Rxn<DashboardHomeDto> home = Rxn<DashboardHomeDto>();
  final RxList<DashboardRecentPostDto> recentPosts =
      <DashboardRecentPostDto>[].obs;
  final RxList<DashboardTrendingPostDto> trending =
      <DashboardTrendingPostDto>[].obs;

  /// Optimistic shortlist set for trending cards, keyed by `post_id`. Web
  /// equivalent: `useDashboardStore.shortlistedFromTrending`.
  final RxMap<String, bool> shortlistedFromTrending = <String, bool>{}.obs;

  /// True while the combined initial / pull-to-refresh load is in flight —
  /// the web's single `loading` flag.
  final RxBool isLoading = true.obs;

  /// First failure from the parallel load, already mapped to copy — the web's
  /// single `error` string.
  final RxnString error = RxnString();

  @override
  void onReady() {
    super.onReady();
    refreshAll();
  }

  /// Parallel fetch of the three home reads. Mirrors HomePage.jsx's effect:
  /// `Promise.all([...])` then a `find((r) => !r.success)` first-error gate.
  /// `unwrapDio` makes any failed call throw `ApiException`, so the first
  /// rejection short-circuits `Future.wait` exactly like the web's firstError.
  Future<void> refreshAll() async {
    isLoading.value = true;
    error.value = null;
    try {
      final results = await Future.wait<Object>([
        _repo.getHome(),
        _repo.getRecentPosts(),
        _repo.getTrending(),
      ]);
      home.value = results[0] as DashboardHomeDto;
      recentPosts.assignAll(results[1] as List<DashboardRecentPostDto>);
      trending.assignAll(results[2] as List<DashboardTrendingPostDto>);
    } on ApiException catch (e) {
      error.value = resolveApiExceptionMessage(e);
      _log.w('Home dashboard load failed: ${e.code}');
    } catch (e) {
      error.value = 'Could not load home dashboard.';
      _log.e('Home dashboard load failed unexpectedly', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  bool isShortlisted(String postId) => shortlistedFromTrending[postId] ?? false;

  /// Optimistic shortlist toggle from a trending card's heart. Mirrors
  /// HomePage.jsx `handleToggleTrendingShortlist`: flip locally first, derive
  /// the action from the pre-toggle value (`shortlisted` to add, `skipped` to
  /// remove), fire the swipe, and revert on failure.
  Future<void> toggleTrendingShortlist(DashboardTrendingPostDto post) async {
    final wasShortlisted = isShortlisted(post.postId);
    _setShortlisted(post.postId, !wasShortlisted);

    final action = wasShortlisted ? 'skipped' : 'shortlisted';
    try {
      await _repo.swipeDiscover(postId: post.postId, action: action);
    } on ApiException catch (e) {
      _setShortlisted(post.postId, wasShortlisted);
      _log.e('Failed to update shortlist: ${e.code}');
    }
  }

  void _setShortlisted(String postId, bool value) {
    shortlistedFromTrending[postId] = value;
    shortlistedFromTrending.refresh();
  }
}
