import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/rushd_theme.dart';
import '../core/theme/theme_controller.dart';
import 'router/app_router.dart';

class RushdApp extends ConsumerWidget {
  const RushdApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: 'RUSHD',
      debugShowCheckedModeBanner: false,

      theme: RushdTheme.light,
      darkTheme: RushdTheme.dark,
      themeMode: themeMode,

      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        final isDark = brightness == Brightness.dark;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness:
            isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor:
            isDark ? const Color(0xFF121212) : Colors.white,
            systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },

      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
