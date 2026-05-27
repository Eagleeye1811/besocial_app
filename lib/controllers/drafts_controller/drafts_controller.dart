import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../common_widgets/app_snackbar.dart';
import '../../core/constants/error_messages.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/cursor_pager.dart';
import '../../core/services/logger_service.dart';
import '../../data/models/draft_model.dart';
import '../../data/models/generation_job_model.dart';
// GenerationSlideModel is declared in generation_job_model.dart.
import '../../repository/drafts_repository/drafts_repository.dart';
import '../../repository/generation_repository/generation_repository.dart';
import '../../repository/instagram_repository/instagram_repository.dart';

/// Drives `/drafts`. Owns the cursor-paginated list plus on-demand
/// fetching of the full generation job when the user opens a detail sheet.
class DraftsController extends GetxController {
  final DraftsRepository _drafts = GetIt.I<DraftsRepository>();
  final GenerationRepository _generation = GetIt.I<GenerationRepository>();
  final InstagramRepository _instagram = GetIt.I<InstagramRepository>();
  final LoggerService _log = GetIt.I<LoggerService>();

  /// Bare client for fetching slide image bytes — deliberately NOT the app
  /// [DioClient], whose envelope interceptor would try to JSON-decode the
  /// binary response and whose auth headers aren't needed for image URLs.
  final Dio _imageHttp = Dio();

  late final CursorPager<DraftModel> pager;

  /// Whether the user's Instagram account is connected. Defaults to `false`
  /// until the status call resolves; any failure leaves it `false` so the UI
  /// falls back to the "Download images" action rather than offering a post
  /// that would just fail. Mirrors the web's `instagramConnected` gate.
  final RxBool isInstagramConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    pager = CursorPager<DraftModel>(_fetchPage);
  }

  @override
  void onReady() {
    super.onReady();
    pager.loadFirst();
    _refreshInstagramStatus();
  }

  /// Fetch the IG connection status once on load. Tolerates errors by
  /// treating the account as not connected.
  Future<void> _refreshInstagramStatus() async {
    try {
      final status = await _instagram.getStatus();
      isInstagramConnected.value = status.connected;
    } on ApiException catch (e) {
      isInstagramConnected.value = false;
      _log.w('GET /instagram/status failed: ${e.code}');
    }
  }

  Future<CursorPage<DraftModel>> _fetchPage(String? cursor) async {
    final response = await _drafts.getDrafts(cursor: cursor);
    return response.toCursorPage();
  }

  /// Load the underlying generation job for the detail sheet (slides +
  /// captions are not on the draft list payload). Returns null on failure
  /// so the sheet can render a graceful error state.
  Future<GenerationJobModel?> loadJob(String jobId) async {
    try {
      return await _generation.getJob(jobId);
    } on ApiException catch (e) {
      _log.w('GET /generation/$jobId failed: ${e.code}');
      return null;
    }
  }

  /// Publish a draft to Instagram. The draft stays in the list afterwards —
  /// the backend marks it as posted server-side but doesn't remove it from
  /// the drafts feed (per the audit; correct behavior here matches the
  /// website client). On success, refresh so any server-side flag flips.
  Future<InstagramPostResult?> postToInstagram(String jobId) async {
    try {
      final result = await _instagram.postToInstagram(jobId);
      await pager.loadFirst();
      return result;
    } on ApiException catch (e) {
      AppSnackbar.error(
        e.code == 'INSTAGRAM_NOT_CONNECTED'
            ? 'Connect Instagram first'
            : 'Post failed',
        resolveApiExceptionMessage(e),
      );
      _log.w('POST /instagram/post/$jobId failed: ${e.code}');
      return null;
    }
  }

  /// Download fallback used when Instagram isn't connected — saves each
  /// generated slide image straight into the device gallery.
  ///
  /// Flow: ensure photo-library access, then fetch each slide's bytes over a
  /// bare Dio (no auth/envelope interceptors — these are direct image URLs)
  /// and hand them to `gal`. Centralises its own success/failure snackbars so
  /// callers only need to drive the busy state.
  ///
  /// The caller may pass [slides] directly (the detail sheet already has the
  /// loaded job) to avoid a second network round-trip; otherwise the job is
  /// fetched here.
  Future<void> downloadSlides(
    String jobId, {
    List<GenerationSlideModel>? slides,
  }) async {
    var resolved = slides;
    if (resolved == null || resolved.isEmpty) {
      final job = await loadJob(jobId);
      resolved = job?.slides;
    }
    if (resolved == null || resolved.isEmpty) {
      _log.w('Download failed — no slides for job $jobId');
      AppSnackbar.info(
        'Nothing to download',
        'These slides aren\'t ready yet.',
      );
      return;
    }

    // Ensure we can write to the gallery before pulling any bytes.
    try {
      if (!await Gal.hasAccess()) {
        if (!await Gal.requestAccess()) {
          AppSnackbar.info(
            'Photo access needed',
            'Allow photo access to save images to your gallery.',
          );
          return;
        }
      }
    } on MissingPluginException {
      // The gallery plugin isn't linked into the running binary — happens
      // after a hot reload that followed adding the dependency. A full app
      // restart registers it.
      _log.w('gal plugin not registered; needs a full app restart');
      AppSnackbar.info(
        'Restart the app',
        'Fully close and reopen the app to enable saving to your gallery.',
      );
      return;
    } on GalException catch (e) {
      _log.w('Gallery access check failed: ${e.type.message}');
    }

    var saved = 0;
    for (var i = 0; i < resolved.length; i++) {
      final url = resolved[i].imageUrl;
      if (url.isEmpty) continue;
      try {
        final response = await _imageHttp.get<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
        );
        final data = response.data;
        if (data == null || data.isEmpty) continue;
        await Gal.putImageBytes(
          Uint8List.fromList(data),
          album: 'Growgram',
          name: 'growgram_${jobId}_${i + 1}',
        );
        saved++;
      } catch (e) {
        _log.w('Saving slide ${i + 1} of $jobId failed: $e');
      }
    }

    if (saved == 0) {
      AppSnackbar.error(
        'Download failed',
        "We couldn't save the images. Try again.",
      );
    } else {
      AppSnackbar.success(
        'Saved to gallery',
        saved == 1
            ? '1 image saved to your gallery.'
            : '$saved images saved to your gallery.',
      );
    }
  }
}
