import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_page.dart';
import '../../features/prayer/presentation/pages/prayer_times_page.dart';
import '../../features/quran/presentation/quran_home_screen.dart';
import '../../features/quran/presentation/quran_reader_screen.dart';

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
      GoRoute(
        path: '/quran/read/:surahNumber',
        name: 'quran-reader',
        builder: (context, state) {
          final surahNumber =
              int.tryParse(state.pathParameters['surahNumber'] ?? '') ?? 1;
          final ayahNumber =
              int.tryParse(state.uri.queryParameters['ayah'] ?? '') ?? 1;

          return QuranReaderScreen(
            surahNumber: surahNumber.clamp(1, 114),
            initialAyah: ayahNumber < 1 ? 1 : ayahNumber,
          );
        },
      ),
    ],
  );
});
