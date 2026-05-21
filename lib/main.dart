import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'get_it.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencyInjection();
  runApp(const BeSocialApp());
}

class BeSocialApp extends StatelessWidget {
  const BeSocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BeSocial',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      // While AppRoutes.routes is empty (Phase 1), render a placeholder so the
      // engine has a Material context to attach to. Removed in Phase 3 when
      // the splash + welcome views land.
      home: const _BootPlaceholder(),
    );
  }
}

class _BootPlaceholder extends StatelessWidget {
  const _BootPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'BeSocial — Phase 1 bootstrap complete.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
