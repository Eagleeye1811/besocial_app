import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../services/auth_service.dart';
import 'app_routes.dart';

/// GetX route guard mirroring the website's `RequireAuth` (see
/// `frontend/src/components/RequireAuth.jsx`). Any route configured with
/// `middlewares: [AuthMiddleware()]` will redirect to [AppRoutes.welcome]
/// when no user is signed in.
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = GetIt.I<AuthService>();
    if (auth.isAuthenticated) return null;
    return const RouteSettings(name: AppRoutes.welcome);
  }
}
