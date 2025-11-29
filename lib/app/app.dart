import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/locale/app_locale.dart';
import '../core/themes/app_theme.dart';
import 'error/error_handler_builder.dart';
import 'routes/app_routes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Counsel Link',
      theme: AppTheme.themeData,
      debugShowCheckedModeBanner: kDebugMode,
      routerConfig: AppRoutes.instance.router,
      locale: AppLocale.defaultLocale,
      supportedLocales: AppLocale.supportedLocales,
      localizationsDelegates: AppLocale.localizationsDelegates,
      builder: (context, child) => ErrorHandlerBuilder(child: child),
    );
  }
}
