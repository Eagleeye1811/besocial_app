import 'dart:io';

import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../core/constants/error_messages.dart';
import '../../core/network/api_exception.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/logger_service.dart';
import '../../core/services/polling_service.dart';
import '../../core/services/secure_storage_service.dart';
import '../../data/dto/onboarding_dto.dart';
import '../../data/models/analysis_data_model.dart';
import '../../data/models/niche_data_model.dart';
import '../../data/models/post_data_model.dart';
import '../../data/models/session_model.dart';
import '../../data/models/trending_post_model.dart';
import '../../repository/onboarding_repository/onboarding_repository.dart';
import '../../repository/session_repository/session_repository.dart';
import '../../views/onboarding/onboarding_steps_config.dart';
import '../auth_controller/auth_controller.dart';

/// Single source of truth for the onboarding wizard state. Lives as a
/// permanent GetX dep so all 12 step views see the same instance; the
/// `OnboardingBindings` register it once with `Get.put(... permanent: true)`.
///
/// Mirrors `frontend/src/features/onboarding/store.js` — the web zustand
/// store keeps the same slice of state and the same step-by-step mutations.
class OnboardingController extends GetxController {
  final OnboardingRepository _repo = GetIt.I<OnboardingRepository>();
  final SessionRepository _session = GetIt.I<SessionRepository>();
  final SecureStorageService _secure = GetIt.I<SecureStorageService>();
  final LoggerService _log = GetIt.I<LoggerService>();

  // ===== Form state =====
  final RxnString businessType = RxnString();
  final RxnString brandName = RxnString();
  final RxnString brandCity = RxnString();
  final RxnString brandDescription = RxnString();
  final RxnString instagramHandle = RxnString();

  // ===== Backend-derived state =====
  final Rxn<Map<String, dynamic>> profileData = Rxn<Map<String, dynamic>>();
  final Rxn<NicheDataModel> niche = Rxn<NicheDataModel>();
  final Rxn<AnalysisDataModel> analysis = Rxn<AnalysisDataModel>();
  final RxList<PostDataModel> analyzedPosts = <PostDataModel>[].obs;

  // ===== Niche edits =====
  final RxList<String> confirmedTopics = <String>[].obs;
  final RxList<String> suggestedTopics = <String>[].obs;
  final RxList<String> confirmedHashtags = <String>[].obs;
  final RxList<String> suggestedHashtags = <String>[].obs;

  // ===== Personalization =====
  final RxList<String> selectedStyles = <String>[].obs;
  final RxnString colorPaletteId = RxnString();
  final RxnString voiceToneId = RxnString();

  // ===== Inspiration / swipe =====
  final RxList<TrendingPostModel> inspirationFeed = <TrendingPostModel>[].obs;
  final RxSet<String> shortlistedPostIds = <String>{}.obs;
  final RxSet<String> skippedPostIds = <String>{}.obs;
  final RxnString pickedPostId = RxnString();

  // ===== Loading / error =====
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  // ===========================================
  // Navigation helpers
  // ===========================================
  void goNext(String fromRoute) {
    final nextRoute = OnboardingFlow.next(fromRoute);
    if (nextRoute != null) Get.toNamed<void>(nextRoute);
  }

  void replaceWithNext(String fromRoute) {
    final nextRoute = OnboardingFlow.next(fromRoute);
    if (nextRoute != null) Get.offNamed<void>(nextRoute);
  }

  // ===========================================
  // Step 2 — business type
  // ===========================================
  Future<void> submitBusinessType(String type) async {
    businessType.value = type;
    await _patch(OnboardingPatchDto(businessType: type));
    goNext(AppRoutes.onboardingBusinessType);
  }

  // ===========================================
  // Step 3 — brand details (mints session token via /profile)
  // ===========================================
  Future<void> submitBrandDetails() async {
    final handle = instagramHandle.value?.trim();
    if (handle == null || handle.isEmpty) {
      errorMessage.value = 'Add your Instagram handle to continue.';
      return;
    }
    await _run(() async {
      final result = await _repo.createProfile(handle);
      profileData.value = result.profile;
      await _session.acceptSessionToken(result.sessionToken);
      _log.i('Onboarding: profile created, session token persisted');
      replaceWithNext(AppRoutes.onboardingBrandDetails);
    });
  }

  // ===========================================
  // Step 4 — analyzing niche (triggers /analyze, polls /session)
  // ===========================================
  PollerCancel? _analyzeCancel;

  Future<void> beginAnalysis() async {
    await _run(() async {
      final result = await _repo.analyze();
      niche.value = result.niche;
      analysis.value = result.analysis;
      analyzedPosts.assignAll(result.posts);
      confirmedTopics.assignAll(result.niche.confirmedTopics);
      suggestedTopics.assignAll(result.niche.suggestedTopics);
      confirmedHashtags.assignAll(result.niche.confirmedHashtags);
      suggestedHashtags.assignAll(result.niche.suggestedHashtags);

      _analyzeCancel = PollerCancel();
      final status = await Poller.until<SessionStatusModel>(
        fetch: _repo.getSessionStatus,
        isTerminal: (s) => s.isTerminal,
        initialDelay: const Duration(seconds: 5),
        maxDelay: const Duration(seconds: 12),
        timeout: const Duration(minutes: 8),
        cancel: _analyzeCancel,
      );
      if (status.status == SessionStatus.failed) {
        throw const ApiException(
          code: 'INTERNAL_ERROR',
          message: 'Analysis failed. Please retry.',
        );
      }
      replaceWithNext(AppRoutes.onboardingAnalyzingNiche);
    });
  }

  void cancelAnalysis() => _analyzeCancel?.cancel();

  // ===========================================
  // Step 5 — niche results
  // ===========================================
  void toggleTopic(String topic) {
    if (confirmedTopics.contains(topic)) {
      confirmedTopics.remove(topic);
      suggestedTopics.add(topic);
    } else if (suggestedTopics.contains(topic)) {
      suggestedTopics.remove(topic);
      confirmedTopics.add(topic);
    }
  }

  void toggleHashtag(String tag) {
    if (confirmedHashtags.contains(tag)) {
      confirmedHashtags.remove(tag);
      suggestedHashtags.add(tag);
    } else if (suggestedHashtags.contains(tag)) {
      suggestedHashtags.remove(tag);
      confirmedHashtags.add(tag);
    }
  }

  Future<void> submitNicheEdits() async {
    await _patch(OnboardingPatchDto(
      editedNiche: EditedNicheDto(
        confirmedTopics: confirmedTopics.toList(),
        suggestedTopics: suggestedTopics.toList(),
        confirmedHashtags: confirmedHashtags.toList(),
        suggestedHashtags: suggestedHashtags.toList(),
      ),
    ));
    goNext(AppRoutes.onboardingNicheResults);
  }

  // ===========================================
  // Steps 6–7 — style intro and post-analysis loading
  // ===========================================
  void completeStyleIntro() => goNext(AppRoutes.onboardingStyleIntro);
  void completeAnalyzingPosts() =>
      replaceWithNext(AppRoutes.onboardingAnalyzingPosts);

  // ===========================================
  // Step 8 — detected style branch
  // ===========================================
  void chooseDetectedStyleBranch({required bool matchSpecificPost}) {
    if (matchSpecificPost) {
      goNext(AppRoutes.onboardingDetectedStyle);
    } else {
      Get.toNamed<void>(AppRoutes.onboardingStyleSelection);
    }
  }

  // ===========================================
  // Step 9 — style selection
  // ===========================================
  void toggleStyle(String style) {
    if (selectedStyles.contains(style)) {
      selectedStyles.remove(style);
    } else if (selectedStyles.length < 3) {
      selectedStyles.add(style);
    }
  }

  Future<void> submitStyleSelection() async {
    await _patch(OnboardingPatchDto(selectedStyles: selectedStyles.toList()));
    Get.toNamed<void>(AppRoutes.onboardingColorsVoice);
  }

  // ===========================================
  // Step 10 — colors & voice
  // ===========================================
  Future<void> submitColorsVoice({
    required String paletteId,
    required String voiceId,
  }) async {
    colorPaletteId.value = paletteId;
    voiceToneId.value = voiceId;
    await _patch(OnboardingPatchDto(
      colorPaletteId: paletteId,
      voiceToneId: voiceId,
    ));
    goNext(AppRoutes.onboardingColorsVoice);
  }

  // ===========================================
  // Step 11 — brand assets (upload + continue)
  // ===========================================
  Future<BrandAssetUploadResult?> uploadAsset({
    required String kind,
    int? slot,
    required File file,
  }) async {
    try {
      return await _repo.uploadAsset(kind: kind, slot: slot, file: file);
    } on ApiException catch (e) {
      errorMessage.value = resolveApiExceptionMessage(e);
      return null;
    }
  }

  void completeBrandAssets() => goNext(AppRoutes.onboardingBrandAssets);

  // ===========================================
  // Step 12 — fetching posts (loads /feed, then advances)
  // ===========================================
  Future<void> loadInspirationFeed() async {
    await _run(() async {
      final posts = await _repo.getFeed();
      inspirationFeed.assignAll(posts);
      replaceWithNext(AppRoutes.onboardingFetchingPosts);
    });
  }

  // ===========================================
  // Step 13 — inspiration (swipe + Google handoff)
  // ===========================================
  Future<void> swipePost({
    required String postId,
    required bool shortlisted,
  }) async {
    final action = shortlisted ? 'shortlisted' : 'skipped';
    try {
      await _repo.swipe(postId: postId, action: action);
      if (shortlisted) {
        shortlistedPostIds.add(postId);
        // First shortlist seeds the picked_post_id and triggers Google.
        if (pickedPostId.value == null) {
          pickedPostId.value = postId;
          await _patch(OnboardingPatchDto(pickedPostId: postId));
          await _triggerGoogleHandoff();
        }
      } else {
        skippedPostIds.add(postId);
      }
    } on ApiException catch (e) {
      errorMessage.value = resolveApiExceptionMessage(e);
    }
  }

  Future<void> _triggerGoogleHandoff() async {
    final inviteToken = await _secure.readInviteToken();
    final auth = Get.find<AuthController>();
    await auth.signInWithGoogle(inviteToken: inviteToken);
    // After successful OAuth, AuthController routes to /home (Phase 5 will
    // replace the destination with the JWT-gated `generating` step).
  }

  // ===========================================
  // Internals
  // ===========================================
  Future<void> _patch(OnboardingPatchDto patch) async {
    try {
      await _repo.patchSession(patch);
    } on ApiException catch (e) {
      _log.w('PATCH /onboarding/session failed (${e.code}): ${e.message}');
      errorMessage.value = resolveApiExceptionMessage(e);
      rethrow;
    }
  }

  Future<void> _run(Future<void> Function() body) async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await body();
    } on ApiException catch (e) {
      errorMessage.value = resolveApiExceptionMessage(e);
      _log.w('Onboarding step failed: ${e.code} ${e.message}');
    } finally {
      isLoading.value = false;
    }
  }
}
