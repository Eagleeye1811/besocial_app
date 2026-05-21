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
      title: 'Growgram',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
    );
  }
}
