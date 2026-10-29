
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rushd/features/qibla/presentation/screens/qibla_screen.dart';
import 'package:rushd/features/salah/presentation/screens/salah_guide_screen.dart';
import 'package:rushd/features/yaseen/presentation/screens/yaseen_screen.dart';

import '../../features/about/presentation/about_screen.dart';
import '../../features/duas/presentation/screens/dua_category_screen.dart';
import '../../features/duas/presentation/screens/dua_detail_scrren.dart';
import '../../features/duas/presentation/screens/dua_search_screen.dart';
import '../../features/duas/presentation/screens/duas_screen.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/prayer/presentation/pages/prayer_times_page.dart';
import '../../features/premium/presentation/premium_screen.dart';
import '../../features/quran/presentation/quran_home_screen.dart';
import '../../features/quran/presentation/quran_reader_screen.dart';
import '../../features/quran/presentation/quran_verse_screen.dart';
import '../../features/salah/presentation/screens/salah_prayer_detail_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/tasbeeh/screens/dhikr_counter_screen.dart';
import '../../features/tasbeeh/screens/dhikr_journeys_screen.dart';
import '../widgets/rushd_bottom_navigation.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // SPLASH SCREEN
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => RushdSplashScreen(
          onFinished: () {
            context.go('/');
          },
        ),
      ),

      // MAIN APP WITH BOTTOM NAVIGATION
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return RushdBottomNavigation(
            navigationShell: navigationShell,
          );
        },
        branches: [
          // HOME
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                pageBuilder: (context, state) => CustomTransitionPage<void>(
                  key: state.pageKey,
                  child: const RushdHomeScreen(),
                  transitionDuration: const Duration(milliseconds: 500),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      ),
                      child: child,
                    );
                  },
                ),
              ),
            ],
          ),

          // PREMIUM
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/premium',
                name: 'premium',
                builder: (context, state) => const PremiumScreen(),
              ),
            ],
          ),

          // SETTINGS
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),

          // ABOUT RUSHD
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/about',
                name: 'about',
                builder: (context, state) => const AboutScreen(),
              ),
            ],
          ),
        ],
      ),

      // PRAYER TIMES
      GoRoute(
        path: '/prayer-times',
        name: 'prayer',
        builder: (context, state) => const PrayerTimesPage(),
      ),

      // QURAN HOME
      GoRoute(
        path: '/quran',
        name: 'quran',
        builder: (context, state) => const QuranHomeScreen(),
      ),

      // QURAN READER
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

      // QURAN VERSE
      GoRoute(
        path: '/quran/verse/:surahNumber/:ayahNumber',
        name: 'quran-verse',
        builder: (context, state) {
          final surah =
              int.tryParse(state.pathParameters['surahNumber'] ?? '') ?? 1;

          final ayah =
              int.tryParse(state.pathParameters['ayahNumber'] ?? '') ?? 1;

          return QuranVerseScreen(
            surahNumber: surah.clamp(1, 114),
            ayahNumber: ayah < 1 ? 1 : ayah,
          );
        },
      ),

      // YASEEN
      GoRoute(
        path: '/yaseen',
        name: 'yaseen',
        builder: (context, state) => const YaseenScreen(),
      ),

      // QIBLA
      GoRoute(
        path: '/qibla',
        name: 'qibla',
        builder: (context, state) => const QiblaScreen(),
      ),

      // SALAH GUIDE
      GoRoute(
        path: '/salah-guide',
        name: 'salah-guide',
        builder: (context, state) => const SalahGuideScreen(),
      ),

      // SALAH PRAYER DETAIL
      GoRoute(
        path: '/salah-guide/:prayerId',
        name: 'salah-prayer-detail',
        builder: (context, state) {
          final prayerId = state.pathParameters['prayerId']!;
          return SalahPrayerDetailScreen(prayerId: prayerId);
        },
      ),

      // DUA & DIKR
      GoRoute(
        path: '/duas',
        name: 'duas',
        builder: (context, state) => const DuasScreen(),
      ),

      // DUA CATEGORY
      GoRoute(
        path: '/duas/category/:categoryId',
        name: 'dua-category',
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          return DuaCategoryScreen(categoryId: categoryId);
        },
      ),

      // DUA SEARCH
      GoRoute(
        path: '/duas/search',
        name: 'dua-search',
        builder: (context, state) => const DuaSearchScreen(),
      ),

      // DUA DETAIL
      GoRoute(
        path: '/duas/:duaId',
        name: 'dua-detail',
        builder: (context, state) {
          final duaId = state.pathParameters['duaId']!;
          return DuaDetailScreen(duaId: duaId);
        },
      ),

      // TASBEEH JOURNEYS
      GoRoute(
        path: '/tasbeeh',
        name: 'dhikr-journeys',
        builder: (context, state) => const DhikrJourneysScreen(),
      ),

      // TASBEEH COUNTER
      GoRoute(
        path: '/tasbeeh/counter/:journeyId',
        name: 'dhikr-counter',
        builder: (context, state) {
          final journeyId = state.pathParameters['journeyId']!;
          return DhikrCounterScreen(journeyId: journeyId);
        },
      ),
    ],
  );
});
