import 'dart:async';

import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../core/constants/error_messages.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/cursor_pager.dart';
import '../../core/services/logger_service.dart';
import '../../data/models/discover_post_model.dart';
import '../../repository/discover_repository/discover_repository.dart';

/// Discover surface view modes — mirrors the web `ModeToggle` (Grid | Swipe).
enum DiscoverViewMode { grid, swipe }

/// Drives `/discover`. Owns a [CursorPager] for the paginated grid plus
/// two side-cars: the format filter and the auto-refresh countdown state.
class DiscoverController extends GetxController {
  final DiscoverRepository _repo = GetIt.I<DiscoverRepository>();
  final LoggerService _log = GetIt.I<LoggerService>();

  late final CursorPager<DiscoverPostModel> pager;

  final Rx<DiscoverFormat> selectedFormat = DiscoverFormat.all.obs;

  /// Grid vs. swipe presentation. Defaults to grid (the existing surface).
  final Rx<DiscoverViewMode> viewMode = DiscoverViewMode.grid.obs;

  /// Count of posts shortlisted this session — drives the swipe-view counter.
  final RxInt sessionShortlistCount = 0.obs;

  /// History of posts skipped in swipe mode, newest last. Powers "Undo last
  /// skip" which re-inserts the post at the front of the pager (mirrors web,
  /// which restores locally without a server round-trip).
  final RxList<DiscoverPostModel> skippedHistory = <DiscoverPostModel>[].obs;

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
  // View mode
  // ===========================================
  void setViewMode(DiscoverViewMode mode) {
    if (viewMode.value == mode) return;
    viewMode.value = mode;
  }

  // ===========================================
  // Swipe
  // ===========================================
  Future<void> shortlist(DiscoverPostModel post) async {
    final ok = await _swipeAndRemove(post, 'shortlisted');
    if (ok) sessionShortlistCount.value++;
  }

  Future<void> skip(DiscoverPostModel post) async {
    final ok = await _swipeAndRemove(post, 'skipped');
    if (ok) {
      skippedHistory.add(post);
    }
  }

  /// Re-inserts the most recently skipped post at the front of the pager so
  /// it becomes the current swipe card again. Mirrors the web behaviour of a
  /// purely local restore — no opposite-action server call.
  void undoLastSkip() {
    if (skippedHistory.isEmpty) return;
    final post = skippedHistory.removeLast();
    if (pager.items.any((p) => p.postId == post.postId)) return;
    pager.items.insert(0, post);
  }

  /// Optimistically drops [post] from the visible feed; restores on failure.
  /// Returns `true` when the swipe was accepted by the backend.
  Future<bool> _swipeAndRemove(DiscoverPostModel post, String action) async {
    final originalIndex = pager.items.indexWhere((p) => p.postId == post.postId);
    if (originalIndex < 0) return false;
    pager.items.removeAt(originalIndex);
    try {
      await _repo.swipe(postId: post.postId, action: action);
      return true;
    } on ApiException catch (e) {
      pager.items.insert(originalIndex, post);
      Get.snackbar(
        action == 'shortlisted' ? 'Heart failed' : 'Skip failed',
        resolveApiExceptionMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      _log.w('Swipe failed: ${e.code}');
      return false;
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
