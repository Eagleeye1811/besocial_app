import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../core/constants/error_messages.dart';
import '../../core/network/api_exception.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/logger_service.dart';
import '../../data/models/instagram_status_model.dart';
import '../../repository/instagram_repository/instagram_repository.dart';
import '../../views/oauth_webview/widgets/oauth_result.dart';

/// Global Instagram connection state. Lives as a `permanent` GetX dep so
/// the connection state is shared across the Brand and Settings surfaces.
///
/// The backend has no explicit "disconnect" endpoint — re-calling
/// `getAuthUrl` wipes prior creds as a side-effect, so `reconnect()` is
/// the closest analogue. A real disconnect would be a backend feature add.
class InstagramController extends GetxController {
  final InstagramRepository _repo = GetIt.I<InstagramRepository>();
  final LoggerService _log = GetIt.I<LoggerService>();

  final Rxn<InstagramStatusModel> status = Rxn<InstagramStatusModel>();
  final RxBool isLoading = false.obs;
  final RxBool isConnecting = false.obs;
  final RxnString errorMessage = RxnString();

  bool get isConnected => status.value?.connected ?? false;
  String? get connectedUsername => status.value?.igUsername;

  @override
  void onReady() {
    super.onReady();
    refreshStatus();
  }

  Future<void> refreshStatus() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      status.value = await _repo.getStatus();
    } on ApiException catch (e) {
      errorMessage.value = resolveApiExceptionMessage(e);
      _log.w('GET /instagram/status failed: ${e.code}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Kick the OAuth WebView flow. On success, refresh `/status` so the
  /// `ig_username` and `connected_at` get populated authoritatively.
  Future<void> startConnect() async {
    if (isConnecting.value) return;
    isConnecting.value = true;
    errorMessage.value = null;
    try {
      final authUrl = await _repo.getAuthUrl();
      final result = await Get.toNamed<dynamic>(
        AppRoutes.oauthWebview,
        arguments: authUrl,
      );
      if (result is InstagramConnectSuccess) {
        await refreshStatus();
        Get.snackbar(
          'Instagram connected',
          result.username != null
              ? 'Linked to @${result.username}.'
              : 'Linked successfully.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (result is OAuthError &&
          result.reason != OAuthError.clientCancelled) {
        errorMessage.value = 'Instagram sign-in failed: ${result.reason}';
      }
    } on ApiException catch (e) {
      errorMessage.value = resolveApiExceptionMessage(e);
      _log.w('GET /instagram/auth-url failed: ${e.code}');
    } finally {
      isConnecting.value = false;
    }
  }
}
