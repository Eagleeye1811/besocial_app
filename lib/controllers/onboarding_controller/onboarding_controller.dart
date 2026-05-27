import 'dart:io';

import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../common_widgets/app_snackbar.dart';

import '../../core/constants/error_messages.dart';
import '../../core/network/api_exception.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/logger_service.dart';
import '../../core/services/polling_service.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/services/auth_service.dart';
import '../../data/dto/onboarding_dto.dart';
import '../../data/models/analysis_data_model.dart';
import '../../data/models/generation_job_model.dart';
import '../../data/models/niche_data_model.dart';
import '../../data/models/post_data_model.dart';
import '../../data/models/session_model.dart';
import '../../data/models/trending_post_model.dart';
import '../../repository/generation_repository/generation_repository.dart';
import '../../repository/onboarding_repository/onboarding_repository.dart';
import '../../repository/session_repository/session_repository.dart';
import '../../views/onboarding/onboarding_steps_config.dart';
import '../auth_controller/auth_controller.dart';

/// 4-state machine for the IG profile lookup on BrandDetailsStep. Mirrors
/// `fetchState` in `BrandDetailsStep.jsx`.
enum ProfileFetchState { idle, fetching, fetched, error }

/// Mirrors `analyzeStatus` in the web Zustand store. Drives AnalyzingNicheStep:
/// `idle → running → (done | error)`. The `done` state allows a back-nav re-mount
/// to forward without re-firing the 30–50s call.
enum AnalyzeStatus { idle, running, done, error }

/// Single source of truth for the onboarding wizard state. Lives as a
/// permanent GetX dep so all 12 step views see the same instance; the
/// `OnboardingBindings` register it once with `Get.put(... permanent: true)`.
///
/// Mirrors `frontend/src/features/onboarding/store.js` — the web zustand
/// store keeps the same slice of state and the same step-by-step mutations.
class OnboardingController extends GetxController {
  final OnboardingRepository _repo = GetIt.I<OnboardingRepository>();
  final GenerationRepository _generation = GetIt.I<GenerationRepository>();
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

  // ===== Generation (Phase 5 tail) =====
  final Rxn<GenerationJobModel> currentJob = Rxn<GenerationJobModel>();
  PollerCancel? _generationCancel;

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
  // Step 2 — business type (local only)
  // ===========================================
  // The session doesn't exist on the backend yet at this step — POST
  // /onboarding/profile (mints the session token) runs in step 3. So we
  // just stash `business_type` locally here and ship it in the combined
  // PATCH at step 5 (`submitNicheEdits`). This mirrors the website, whose
  // BusinessTypeStep also writes to its store and lets NicheResultsStep
  // batch `business_type + edited_niche` into one PATCH /session.
  void submitBusinessType(String type) {
    businessType.value = type;
    goNext(AppRoutes.onboardingBusinessType);
  }

  // ===========================================
  // Step 3 — brand details
  // ===========================================
  // Two-action flow mirroring `BrandDetailsStep.jsx`:
  //   1. `findProfile()` — POST /onboarding/profile to fetch the IG profile
  //      and mint the session token. UI renders the result inline; does NOT
  //      advance.
  //   2. `continueToAnalysis()` — advances to the analyzing step. Only
  //      enabled once the form is complete and a profile has been fetched.
  // The brand name/city/description are kept client-side at this step
  // (matches the website — they're not in the BrandDetails PATCH).
  final Rx<ProfileFetchState> profileFetchState =
      ProfileFetchState.idle.obs;
  final RxnString profileFetchErrorCode = RxnString();
  final RxnString profileFetchErrorMessage = RxnString();

  Future<void> findProfile() async {
    final handle = instagramHandle.value?.trim();
    if (handle == null || handle.length < 2) return;
    if (profileFetchState.value == ProfileFetchState.fetching) return;

    profileFetchState.value = ProfileFetchState.fetching;
    profileFetchErrorCode.value = null;
    profileFetchErrorMessage.value = null;
    errorMessage.value = null;

    try {
      final result = await _repo.createProfile(handle);
      profileData.value = result.profile;
      await _session.acceptSessionToken(result.sessionToken);
      profileFetchState.value = ProfileFetchState.fetched;
      _log.i('Onboarding: profile fetched, session token persisted');
    } on ApiException catch (e) {
      profileFetchErrorCode.value = e.code;
      profileFetchErrorMessage.value = resolveApiExceptionMessage(e);
      profileFetchState.value = ProfileFetchState.error;
      _log.w('Profile lookup failed: ${e.code} ${e.message}');
    }
  }

  /// Call when the IG handle field changes so a stale fetch state doesn't
  /// linger over a now-different handle.
  void resetProfileFetch() {
    if (profileFetchState.value == ProfileFetchState.idle) return;
    profileData.value = null;
    profileFetchState.value = ProfileFetchState.idle;
    profileFetchErrorCode.value = null;
    profileFetchErrorMessage.value = null;
    errorMessage.value = null;
  }

  void continueToAnalysis() {
    if (profileFetchState.value != ProfileFetchState.fetched) return;
    // Reset the analyze guard so a fresh analyze actually fires when
    // AnalyzingNicheStep mounts (matches the web's `setData('analyzeStatus',
    // 'idle')` in BrandDetailsStep before navigating).
    analyzeStatus.value = AnalyzeStatus.idle;
    replaceWithNext(AppRoutes.onboardingBrandDetails);
  }

  // ===========================================
  // Step 4 — analyzing niche
  // ===========================================
  // Direct port of the web's AnalyzingNicheStep effect — POST /analyze is
  // synchronous server-side (no polling); we set status to `running`
  // before the await for re-entry dedup, then store niche/analysis/posts
  // and forward. The `done` branch lets a back-nav re-mount forward
  // without re-firing the 30–50s call. The `error` branch blocks until
  // BrandDetailsStep's continueToAnalysis resets to `idle`.
  final Rx<AnalyzeStatus> analyzeStatus = AnalyzeStatus.idle.obs;

  Future<void> beginAnalysis() async {
    if (analyzeStatus.value == AnalyzeStatus.done &&
        niche.value != null &&
        analysis.value != null) {
      replaceWithNext(AppRoutes.onboardingAnalyzingNiche);
      return;
    }
    if (analyzeStatus.value != AnalyzeStatus.idle) return;

    analyzeStatus.value = AnalyzeStatus.running;
    errorMessage.value = null;

    try {
      final result = await _repo.analyze();
      niche.value = result.niche;
      analysis.value = result.analysis;
      analyzedPosts.assignAll(result.posts);
      confirmedTopics.assignAll(result.niche.confirmedTopics);
      suggestedTopics.assignAll(result.niche.suggestedTopics);
      confirmedHashtags.assignAll(result.niche.confirmedHashtags);
      suggestedHashtags.assignAll(result.niche.suggestedHashtags);
      analyzeStatus.value = AnalyzeStatus.done;
      replaceWithNext(AppRoutes.onboardingAnalyzingNiche);
    } on ApiException catch (e) {
      analyzeStatus.value = AnalyzeStatus.error;
      errorMessage.value = resolveApiExceptionMessage(e);
      _log.w('Analysis failed: ${e.code} ${e.message}');
    }
  }

  /// No-op kept for the view's dispose hook — the synchronous /analyze call
  /// has no cancel handle, so there's nothing to stop client-side. Bailing
  /// from this screen mid-flight just lets the request complete in the
  /// background; the `done` guard will fast-forward on next mount.
  void cancelAnalysis() {}

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
    // Combined PATCH: `business_type` deferred from step 2 (where the
    // session didn't exist yet) + the niche edits made on this screen.
    // Same payload shape as the website's NicheResultsStep.
    await _patch(OnboardingPatchDto(
      businessType: businessType.value,
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
  // `styleChoice` holds the two-way branch the user picked on
  // DetectedStyleStep: 'pick' (use one of their existing posts as visual
  // reference) or 'custom' (go to StyleSelectionStep). Mirrors the web's
  // `styleChoice` store slice — the user toggles a card, then Continues.
  final RxnString styleChoice = RxnString();

  /// Tap on one of the user's posts in DetectedStyleStep's "Match a specific
  /// post" branch. PATCHes `picked_post_id` immediately so a later back-nav
  /// preserves the selection server-side. Reverts the local pick on failure
  /// so the UI never shows a selection the server doesn't know about.
  Future<void> pickReferencePost(String postId) async {
    final previous = pickedPostId.value;
    pickedPostId.value = postId;
    styleChoice.value = 'pick';
    try {
      await _repo.patchSession(
        OnboardingPatchDto(pickedPostId: postId),
      );
    } on ApiException catch (e) {
      pickedPostId.value = previous;
      errorMessage.value = resolveApiExceptionMessage(e);
      _log.w('Pick reference post failed: ${e.code} ${e.message}');
    }
  }

  /// Continue button on DetectedStyleStep. Pick branch skips StyleSelection
  /// (the post replaces the aesthetic grid) but STILL collects colors+voice
  /// — personalization is required regardless of how visual was chosen.
  /// Custom branch routes through StyleSelection.
  void continueFromDetectedStyle() {
    final choice = styleChoice.value;
    if (choice == 'pick' && pickedPostId.value != null) {
      Get.toNamed<void>(AppRoutes.onboardingColorsVoice);
    } else if (choice == 'custom') {
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
  // Pipeline poll (used by FetchingPostsStep) — wraps /session
  // ===========================================
  /// One-shot read of the onboarding pipeline status. Mirrors the web's
  /// `getSession()` call inside `FetchingPostsStep.jsx`. The widget polls
  /// this every 10s until it observes `ready` or `failed`.
  Future<SessionStatusModel> getSessionStatus() => _repo.getSessionStatus();

  // ===========================================
  // Step 13 — inspiration (swipe + Google handoff)
  // ===========================================
  Future<void> swipePost({
    required String postId,
    required bool shortlisted,
  }) async {
    final action = shortlisted ? 'shortlisted' : 'skipped';
    try {
      _log.i('swipePost: $action $postId');
      await _repo.swipe(postId: postId, action: action);
      if (shortlisted) {
        shortlistedPostIds.add(postId);

        // Always update picked_post_id to the latest save and PATCH it
        // server-side — the most recent save wins as the reference post.
        // This matches the web's `handleSave`, which mirrors the swipe to
        // the backend and then immediately fires the auth gate on EVERY
        // successful save, not just the first.
        final isNewPick = pickedPostId.value != postId;
        pickedPostId.value = postId;
        if (isNewPick) {
          await _patch(OnboardingPatchDto(pickedPostId: postId));
        }

        // Auth gate — same logic as the web's
        //   if (auth.isAuthenticated()) goNext('generating');
        //   else setShowSignupModal(true);
        // Mobile replaces the modal with the in-app OAuth WebView and
        // calls offAllNamed(generating) on the authenticated branch.
        final authSvc = GetIt.I<AuthService>();
        if (authSvc.isAuthenticated) {
          _log.i('swipePost: authenticated — routing to onboardingGenerating');
          AppSnackbar.success(
            'Signed in',
            "We've got your session — heading to generation.",
          );
          Get.offAllNamed(AppRoutes.onboardingGenerating);
        } else {
          _log.i('swipePost: not authenticated — opening Google OAuth');
          await _triggerGoogleHandoff();
        }
      } else {
        skippedPostIds.add(postId);
      }
    } on ApiException catch (e) {
      _log.w('swipePost failed: ${e.code} ${e.message}');
      errorMessage.value = resolveApiExceptionMessage(e);
      // Surface the failure prominently — the inline error pill at the
      // bottom of the inspiration grid is easy to miss.
      AppSnackbar.error(
        "Couldn't save",
        resolveApiExceptionMessage(e),
      );
    }
  }

  Future<void> _triggerGoogleHandoff() async {
    final inviteToken = await _secure.readInviteToken();
    final auth = Get.find<AuthController>();
    await auth.signInWithGoogle(
      inviteToken: inviteToken,
      destinationRoute: AppRoutes.onboardingGenerating,
    );
  }

  // ===========================================
  // Step 14 — generating (JWT-gated, polls /generation/{job_id})
  // ===========================================
  Future<void> triggerGeneration() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = null;
    _generationCancel = PollerCancel();
    try {
      final jobId = await _generation.createJob();
      currentJob.value = GenerationJobModel(
        jobId: jobId,
        status: GenerationJobStatus.pending,
        slides: const [],
      );
      // Live-update the observable as the poller advances so the UI status
      // text reflects each phase change.
      final terminal = await Poller.until<GenerationJobModel>(
        fetch: () async {
          final next = await _generation.getJob(jobId);
          currentJob.value = next;
          return next;
        },
        isTerminal: (j) => j.isTerminal,
        initialDelay: const Duration(seconds: 3),
        maxDelay: const Duration(seconds: 8),
        backoffFactor: 1.4,
        timeout: const Duration(minutes: 8),
        cancel: _generationCancel,
      );
      if (terminal.status == GenerationJobStatus.completed) {
        Get.offNamed<void>(AppRoutes.onboardingResult);
      } else {
        errorMessage.value =
            terminal.errorMessage ?? 'Generation failed. Try again.';
      }
    } on ApiException catch (e) {
      errorMessage.value = resolveApiExceptionMessage(e);
      _log.w('Generation failed: ${e.code} ${e.message}');
    } finally {
      isLoading.value = false;
    }
  }

  void cancelGeneration() => _generationCancel?.cancel();

  /// Bail out of the generating step on failure — onboarding still counts
  /// as complete because `has_completed_onboarding` is derived server-side
  /// from the IG profile, which was set during step 3.
  void skipGenerationToComplete() {
    cancelGeneration();
    Get.offAllNamed(AppRoutes.onboardingComplete);
  }

  /// From the result screen, advance to the celebration screen.
  void completeOnboardingFromResult() {
    Get.offNamed<void>(AppRoutes.onboardingComplete);
  }

  /// "Generate another" on ResultStep. Mirrors the web's
  /// `handleRegenerate`: clear the current job, push the user back to
  /// /generating, and let that screen's `triggerGeneration` kick a fresh
  /// `POST /generation`.
  Future<void> regenerateFromResult() async {
    currentJob.value = null;
    errorMessage.value = null;
    Get.offNamed<void>(AppRoutes.onboardingGenerating);
  }

  /// "Skip for now — go to dashboard" on ResultStep. Mirrors the web's
  /// `navigate('/home')` skip link.
  void skipResultToDashboard() {
    cancelGeneration();
    Get.offAllNamed(AppRoutes.home);
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
