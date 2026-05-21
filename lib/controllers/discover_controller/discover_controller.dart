import 'dart:async';

import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../core/constants/error_messages.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/cursor_pager.dart';
import '../../core/services/logger_service.dart';
import '../../data/models/discover_post_model.dart';
import '../../repository/discover_repository/discover_repository.dart';

/// Drives `/discover`. Owns a [CursorPager] for the paginated grid plus
/// two side-cars: the format filter and the auto-refresh countdown state.
class DiscoverController extends GetxController {
  final DiscoverRepository _repo = GetIt.I<DiscoverRepository>();
  final LoggerService _log = GetIt.I<LoggerService>();

  late final CursorPager<DiscoverPostModel> pager;

  final Rx<DiscoverFormat> selectedFormat = DiscoverFormat.all.obs;

  // Refresh-cadence state, sourced from the latest feed response.
  final Rxn<DateTime> nextRefreshAt = Rxn<DateTime>();
  final Rxn<Duration> timeUntilRefresh = Rxn<Duration>();
  final RxBool isManualRefreshing = false.obs;
  final RxnString refreshError = RxnString();

  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    pager = CursorPager<DiscoverPostModel>(_fetchPage);
  }

  @override
  void onReady() {
    super.onReady();
    pager.loadFirst();
    _startCountdownTimer();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  Future<CursorPage<DiscoverPostModel>> _fetchPage(String? cursor) async {
    final response = await _repo.getFeed(
      format: selectedFormat.value,
      cursor: cursor,
    );
    nextRefreshAt.value = response.nextRefreshAt;
    _recomputeCountdown();
    return response.toCursorPage();
  }

  // ===========================================
  // Format filter
  // ===========================================
  Future<void> setFormat(DiscoverFormat format) async {
    if (selectedFormat.value == format) return;
    selectedFormat.value = format;
    await pager.loadFirst();
  }

  // ===========================================
  // Swipe
  // ===========================================
  Future<void> shortlist(DiscoverPostModel post) async {
    await _swipeAndRemove(post, 'shortlisted');
  }

  Future<void> skip(DiscoverPostModel post) async {
    await _swipeAndRemove(post, 'skipped');
  }

  Future<void> _swipeAndRemove(
      DiscoverPostModel post, String action) async {
    // Optimistic: drop from the visible feed first, restore on failure.
    final originalIndex = pager.items.indexWhere((p) => p.postId == post.postId);
    if (originalIndex < 0) return;
    pager.items.removeAt(originalIndex);
    try {
      await _repo.swipe(postId: post.postId, action: action);
    } on ApiException catch (e) {
      pager.items.insert(originalIndex, post);
      Get.snackbar(
        action == 'shortlisted' ? 'Heart failed' : 'Skip failed',
        resolveApiExceptionMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      _log.w('Swipe failed: ${e.code}');
    }
  }

  // ===========================================
  // Manual refresh
  // ===========================================
  Future<void> triggerManualRefresh() async {
    if (isManualRefreshing.value) return;
    isManualRefreshing.value = true;
    refreshError.value = null;
    try {
      await _repo.refresh();
      // Backend has no status endpoint — fall back to a short delay before
      // re-fetching the feed. Worst-case the grid shows the prior list for
      // a few seconds longer.
      await Future<void>.delayed(const Duration(seconds: 8));
      await pager.loadFirst();
    } on ApiException catch (e) {
      if (e.code == 'REFRESH_IN_PROGRESS') {
        refreshError.value =
            "We're already pulling fresh posts — give it a few seconds.";
      } else {
        refreshError.value = resolveApiExceptionMessage(e);
      }
      _log.w('Discover refresh failed: ${e.code}');
    } finally {
      isManualRefreshing.value = false;
    }
  }

  // ===========================================
  // Countdown
  // ===========================================
  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => _recomputeCountdown());
  }

  void _recomputeCountdown() {
    final target = nextRefreshAt.value;
    if (target == null) {
      timeUntilRefresh.value = null;
      return;
    }
    final remaining = target.difference(DateTime.now());
    timeUntilRefresh.value = remaining.isNegative ? Duration.zero : remaining;
  }
}
