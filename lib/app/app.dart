import 'package:flutter/material.dart';
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

      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
