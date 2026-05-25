import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/theme_constants.dart';
import '../widgets/oauth_result.dart';

/// In-app WebView that drives the Google OAuth flow.
///
/// Per Phase 0 (Option 3), the backend's web-only callback redirect
/// (`{FRONTEND_URL}/auth/callback#token=…`) is intercepted by the WebView's
/// navigation delegate. We never actually load the frontend — the moment a
/// `/auth/callback` URL is requested we parse the fragment/query and
/// `Get.back(result: …)` with a typed [OAuthResult].
///
/// Pushed via:
///   `Get.toNamed(AppRoutes.oauthWebview, arguments: authorizeUrl)`
/// and awaited as `await Get.toNamed(...)`.
class OAuthWebViewView extends StatefulWidget {
  const OAuthWebViewView({super.key});

  @override
  State<OAuthWebViewView> createState() => _OAuthWebViewViewState();
}

/// Chrome-on-Android User-Agent string. Google's OAuth endpoint blocks the
/// default Flutter WebView UA (which contains the `; wv)` marker); presenting
/// a standard Chrome UA bypasses the `disallowed_useragent` rejection.
const String _chromeUserAgent =
    'Mozilla/5.0 (Linux; Android 13; Pixel 7) '
    'AppleWebKit/537.36 (KHTML, like Gecko) '
    'Chrome/121.0.0.0 Mobile Safari/537.36';

class _OAuthWebViewViewState extends State<OAuthWebViewView> {
  late final WebViewController _controller;
  bool _resultDispatched = false;
  int _loadingPercent = 0;

  @override
  void initState() {
    super.initState();
    final authorizeUrl = Get.arguments as String;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.surface)
      // Google's OAuth "secure browser policy" rejects requests whose
      // User-Agent contains the Android WebView marker `; wv)` with
      // `403: disallowed_useragent`. Setting a real Chrome UA bypasses
      // the heuristic so the consent screen renders normally.
      ..setUserAgent(_chromeUserAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() => _loadingPercent = p),
          onNavigationRequest: (request) {
            if (_isCallbackUrl(request.url)) {
              _dispatchResultFromUrl(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(authorizeUrl));
  }

  /// We don't know the frontend's host (depends on env), so match on path
  /// shape. Backend redirects to `…/auth/callback` for Google and to
  /// `…/onboarding/instagram-connect` for Instagram (Phase 12 will reuse
  /// this view).
  bool _isCallbackUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.path.endsWith('/auth/callback') ||
        uri.path.endsWith('/onboarding/instagram-connect');
  }

  void _dispatchResultFromUrl(String url) {
    if (_resultDispatched) return;
    _resultDispatched = true;

    final uri = Uri.parse(url);
    final error = uri.queryParameters['error'];

    // Instagram callback rides on query params (?success=true&username=…),
    // not a URL fragment, so it gets its own branch before the Google
    // fragment-parsing logic.
    if (uri.path.endsWith('/onboarding/instagram-connect')) {
      if (error != null) {
        Get.back<OAuthResult>(result: OAuthError(error));
        return;
      }
      final ok = uri.queryParameters['success'] == 'true';
      if (!ok) {
        Get.back<OAuthResult>(
          result: const OAuthError(OAuthError.clientMissingToken),
        );
        return;
      }
      Get.back<OAuthResult>(
        result: InstagramConnectSuccess(
          username: uri.queryParameters['username'],
        ),
      );
      return;
    }

    // Google callback: `#token=…&new_user=…` fragment OR `?error=…` query.
    final fragmentParams = uri.fragment.isEmpty
        ? const <String, String>{}
        : Uri.splitQueryString(uri.fragment);
    final token = fragmentParams['token'];
    final newUserFlag = fragmentParams['new_user'];

    if (error != null) {
      Get.back<OAuthResult>(result: OAuthError(error));
      return;
    }
    if (token == null || token.isEmpty) {
      Get.back<OAuthResult>(
        result: const OAuthError(OAuthError.clientMissingToken),
      );
      return;
    }
    Get.back<OAuthResult>(
      result: OAuthSuccess(token: token, isNewUser: newUserFlag == '1'),
    );
  }

  Future<bool> _handleSystemBack() async {
    if (_resultDispatched) return true;
    _resultDispatched = true;
    Get.back<OAuthResult>(result: const OAuthError(OAuthError.clientCancelled));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleSystemBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign in'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _handleSystemBack,
          ),
        ),
        body: Column(
          children: [
            if (_loadingPercent < 100)
              LinearProgressIndicator(
                value: _loadingPercent / 100,
                minHeight: 2,
                backgroundColor: AppColors.line2,
                color: AppColors.accent,
              ),
            Expanded(child: WebViewWidget(controller: _controller)),
          ],
        ),
      ),
    );
  }
}
