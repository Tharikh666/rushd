import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rushd/features/prayer/presentation/pages/prayer_times_page.dart';

import '../../features/home/presentation/home_page.dart';
import '../../features/quran/presentation/quran_home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const RushdHomeScreen(),
      ),
      GoRoute(
        path: '/prayer-times',
        name: 'prayer',
        builder: (context, state) => const PrayerTimesPage(),
      ),
      GoRoute(
        path: '/quran',
        name: 'quran',
        builder: (context, state) => const QuranHomeScreen(),
      ),
    ],
  );
});
