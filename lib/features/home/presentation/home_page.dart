import 'dart:async';
import 'dart:ui';
import 'package:quran/quran.dart' as quran;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:go_router/go_router.dart';
import 'package:rushd/features/home/presentation/providers/home_providers.dart';
import 'package:rushd/features/home/presentation/widgets/prayer_home_widgets.dart';

import '../../../../core/premium/feature_access_controller.dart';
import '../../../../core/premium/rushd_feature.dart';
import '../../../../core/theme/rushd_colors.dart';

import '../../quran/data/quran_metadata.dart';
import '../../quran/data/quran_data_service.dart';
import '../../quran/data/quran_providers.dart';
import '../../quran/domain/quran_ayah.dart';
import '../../quran/services/quran_progress_service.dart';
import '../domain/entities/prayer_time.dart';

import 'package:rushd/features/yaseen/domain/services/yaseen_progress_service.dart';
import 'package:rushd/features/tasbeeh/screens/dhikr_journeys_screen.dart'
    show dhikrJourneysProvider;

class RushdHomeScreen extends ConsumerStatefulWidget {
  const RushdHomeScreen({super.key});

  @override
  ConsumerState<RushdHomeScreen> createState() => _RushdHomeScreenState();
}

class _RushdHomeScreenState extends ConsumerState<RushdHomeScreen> {
  final PageController _heroController = PageController(initialPage: 1000);
  final PageController _prayerCarouselController = PageController(
    initialPage: 1000,
    viewportFraction: 0.82,
  );

  final QuranProgressService _quranProgressService =
  const QuranProgressService();

  final YaseenProgressService _yaseenProgressService =
  YaseenProgressService();

  Timer? _heroTimer;
  Timer? _prayerCarouselTimer;
  Timer? _clockTimer;

  int _heroPage = 1000;
  int _prayerCarouselPage = 1000;

  DateTime _now = DateTime.now();

  final List<_HeroType> _heroTypes = const [
    _HeroType.prayer,
    _HeroType.ayah,
    _HeroType.advertisement,
  ];

  late Future<List<QuranAyah>> _bookmarksFuture;
  late Future<QuranAyah?> _progressFuture;

  void _refreshLocalData() {
    _bookmarksFuture = ref.read(quranBookmarkServiceProvider).getBookmarks();
    _progressFuture = ref.read(quranProgressServiceProvider).getProgress();
  }

  void _openReader(int surah, [int ayah = 1]) {
    context.push('/quran/read/$surah?ayah=$ayah').then((_) {
      if (!mounted) return;
      setState(_refreshLocalData);
    });
  }

  @override
  void initState() {
    super.initState();

    _heroTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_heroController.hasClients) return;

      _heroPage++;

      _heroController.animateToPage(
        _heroPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    });

    // Auto-sliding infinite timer for prayer cards carousel every 4 seconds
    _prayerCarouselTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_prayerCarouselController.hasClients) return;

      _prayerCarouselPage++;

      _prayerCarouselController.animateToPage(
        _prayerCarouselPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });

    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;

      setState(() {
        _now = DateTime.now();
      });
    });

    _refreshLocalData();
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _prayerCarouselTimer?.cancel();
    _clockTimer?.cancel();
    _heroController.dispose();
    _prayerCarouselController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: RushdColors.primary,
          onRefresh: _refreshHome,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _RushdGreetingHeader(now: _now),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroCarousel(context),

                      const SizedBox(height: 36),

                      _buildSectionHeader(
                        context,
                        title: 'DAILY WORSHIP',
                        subtitle: 'Quick access to your spiritual routine',
                      ),

                      const SizedBox(height: 16),

                      _buildWorshipSection(context),

                      const SizedBox(height: 36),

                      _buildSectionHeader(
                        context,
                        title: "TODAY'S PRAYERS",
                        subtitle: 'Auto-sliding infinite prayer timings',
                        actionText: 'View All',
                        onAction: () {
                          context.push('/prayer-times');
                        },
                      ),

                      const SizedBox(height: 16),

                      /// INFINITE AUTO-SLIDING PRAYER CAROUSEL
                      _buildPrayerCarouselCard(context),

                      const SizedBox(height: 36),

                      _buildSectionHeader(
                        context,
                        title: 'CONTINUE YOUR JOURNEY',
                        subtitle: 'Pick up right where you left off',
                      ),

                      const SizedBox(height: 16),

                      _buildJourneySection(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshHome() async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      _now = DateTime.now();
    });
  }

  Widget _buildPrayerCarouselCard(BuildContext context) {
    final prayerState = ref.watch(prayerStateProvider);

    return prayerState.when(
      loading: () => const SizedBox(
        height: 190,
        child: Center(
          child: CircularProgressIndicator(color: RushdColors.primary),
        ),
      ),
      error: (error, _) => const SizedBox(
        height: 100,
        child: Center(child: Text('Failed to load prayer times')),
      ),
      data: (state) {
        final current = state.currentPrayer;
        final next = state.nextPrayer;

        // Exclude sunrise card as requested
        final prayersList = state.today.allTimes
            .where((p) => p.name.toLowerCase() != 'sunrise')
            .toList();

        if (prayersList.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _prayerCarouselController,
            onPageChanged: (page) {
              if (!mounted) return;
              setState(() {
                _prayerCarouselPage = page;
              });
            },
            itemBuilder: (context, index) {
              final prayer = prayersList[index % prayersList.length];
              final active = current?.type == prayer.type;
              final comingUp = next?.type == prayer.type;
              final assetData = _getPrayerAssetData(prayer.name);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _RedesignedPrayerCarouselTile(
                  prayer: prayer,
                  isCurrent: active,
                  isNext: comingUp,
                  gradientColors: assetData['gradient'] as List<Color>,
                  watermarkPath: assetData['watermark'] as String,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getPrayerAssetData(String name) {
    switch (name.toLowerCase()) {
      case 'fajr':
        return {
          'gradient': [const Color(0xFF2D4A87), const Color(0xFF6B8DD6)],
          'watermark': 'assets/icons/prayer_times/fajr.svg',
        };
      case 'dhuhr':
        return {
          'gradient': [const Color(0xFFFFF7D6), const Color(0xFFFFFFFF)],
          'watermark': 'assets/icons/prayer_times/dhuhr.svg',
        };
      case 'asr':
        return {
          'gradient': [const Color(0xFFFFE7CC), const Color(0xFFFFFFFF)],
          'watermark': 'assets/icons/prayer_times/asr.svg',
        };
      case 'maghrib':
        return {
          'gradient': [const Color(0xFFFF9F68), const Color(0xFFFFD6A5)],
          'watermark': 'assets/icons/prayer_times/maghrib.svg',
        };
      case 'isha':
      default:
        return {
          'gradient': [const Color(0xFF0F172A), const Color(0xFF1E3A8A)],
          'watermark': 'assets/icons/prayer_times/isha.svg',
        };
    }
  }

  Widget _buildHeroCarousel(BuildContext context) {
    final featureAccess = ref.watch(featureAccessControllerProvider);
    final showAdvertisement = featureAccess.canAccess(RushdFeature.ads);

    final visibleHeroTypes = _heroTypes.where((type) {
      if (type == _HeroType.advertisement) {
        return showAdvertisement;
      }
      return true;
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 292,
          child: PageView.builder(
            controller: _heroController,
            itemBuilder: (context, index) {
              final type = visibleHeroTypes[index % visibleHeroTypes.length];

              return AnimatedBuilder(
                animation: _heroController,
                builder: (context, child) {
                  double scale = 1.0;

                  if (_heroController.position.haveDimensions) {
                    final page = _heroController.page ?? _heroPage.toDouble();
                    final difference = (page - index).abs().clamp(0.0, 1.0);
                    scale = 1 - (difference * 0.04);
                  }

                  return Transform.scale(
                    scale: scale,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: child,
                    ),
                  );
                },
                child: _buildHeroCard(context, type),
              );
            },
            onPageChanged: (page) {
              if (!mounted) return;
              setState(() {
                _heroPage = page;
              });
            },
          ),
        ),

        const SizedBox(height: 14),

        _buildHeroIndicator(context, visibleHeroTypes.length),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, _HeroType type) {
    switch (type) {
      case _HeroType.prayer:
        return const PrayerHomeHeroCard();
      case _HeroType.ayah:
        return const _DailyAyahHeroCard();
      case _HeroType.advertisement:
        return const _AdvertisementHeroCard();
    }
  }

  Widget _buildHeroIndicator(BuildContext context, int count) {
    final activeIndex = _heroPage % count;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = index == activeIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 28 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active
                ? RushdColors.primary
                : RushdColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  // ============================================================================
  // REDESIGNED WORSHIP SECTION (Bento Grid Style)
  // ============================================================================
  Widget _buildWorshipSection(BuildContext context) {
    return Column(
      children: [
        // Primary Feature Tile (Quran)
        _WorshipFeatureTile(
          icon: Icons.menu_book_rounded,
          title: 'Holy Quran',
          subtitle: 'Read, audio recitation & deep reflection',
          accentColor: RushdColors.primary,
          badgeText: 'Most Loved',
          onTap: () {
            context.push('/quran');
          },
        ),

        const SizedBox(height: 14),

        // Medium Dual Tiles (Yaseen & Qibla)
        Row(
          children: [
            Expanded(
              child: _WorshipMediumTile(
                icon: Icons.auto_stories_rounded,
                title: 'Surah Yaseen',
                subtitle: 'Heart of Quran',
                accentColor: const Color(0xFF6366F1),
                onTap: () {
                  context.push('/yaseen');
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _WorshipMediumTile(
                icon: Icons.explore_rounded,
                title: 'Qibla Finder',
                subtitle: 'Precise direction',
                accentColor: const Color(0xFFF59E0B),
                onTap: () {
                  context.push('/qibla');
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Compact Trio Tiles (Salah, Duas, Dhikr)
        Row(
          children: [
            Expanded(
              child: _WorshipCompactTile(
                icon: Icons.mosque_rounded,
                title: 'Salah Guide',
                accentColor: RushdColors.primary,
                onTap: () {
                  context.push('/salah-guide');
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _WorshipCompactTile(
                icon: Icons.favorite_outline_rounded,
                title: 'Duas & Dhikrs',
                accentColor: const Color(0xFFEC4899),
                onTap: () {
                  context.push('/duas');
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _WorshipCompactTile(
                icon: Icons.fingerprint_rounded,
                title: 'Tasbeeh',
                accentColor: const Color(0xFF0EA5E9),
                onTap: () {
                  context.push('/tasbeeh');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================================
  // REDESIGNED JOURNEY SECTION
  // ============================================================================
  Widget _buildJourneySection(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait<dynamic>([
        _quranProgressService.getProgress(),
        _yaseenProgressService.getLastReadAyah(),
      ]),
      builder: (context, snapshot) {
        final QuranAyah? quranProgress =
        snapshot.hasData ? snapshot.data![0] as QuranAyah? : null;

        final int? yaseenAyah =
        snapshot.hasData ? snapshot.data![1] as int? : null;

        final dhikrState = ref.watch(dhikrJourneysProvider);

        final journeys = dhikrState.valueOrNull ?? [];

        final activeJourney = journeys.cast<dynamic>().firstWhere(
              (journey) => journey != null && !journey.isCompleted,
          orElse: () => null,
        );

        final hasQuranProgress = quranProgress != null;
        final hasYaseenProgress = yaseenAyah != null;
        final hasDhikrProgress = activeJourney != null;

        if (snapshot.connectionState == ConnectionState.waiting &&
            journeys.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(
                color: RushdColors.primary,
              ),
            ),
          );
        }

        if (!hasQuranProgress &&
            !hasYaseenProgress &&
            !hasDhikrProgress) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            if (hasQuranProgress) ...[
              _JourneyCard(
                icon: Icons.menu_book_rounded,
                title: 'Quran Reading Progress',
                subtitle:
                'Surah ${quranProgress.surahNumber} • Ayah ${quranProgress.ayahNumber}',
                progress: _calculateQuranProgress(
                  quranProgress.surahNumber,
                  quranProgress.ayahNumber,
                ),
                progressLabel:
                '${(_calculateQuranProgress(
                  quranProgress.surahNumber,
                  quranProgress.ayahNumber,
                ) * 100).round()}%',
                accentColor: RushdColors.primary,
                onTap: () {
                  _openReader(quranProgress.surahNumber, quranProgress.ayahNumber);
                },
              ),
              const SizedBox(height: 14),
            ],
            Row(
              children: [
                if (hasYaseenProgress)
                  Expanded(
                    child: _SmallJourneyCard(
                      icon: Icons.auto_stories_rounded,
                      title: 'Surah Yaseen',
                      progress: ((yaseenAyah ?? 1) / 83).clamp(0.0, 1.0),
                      progressLabel:
                      '${(((yaseenAyah ?? 1) / 83) * 100).round()}%',
                      accentColor: const Color(0xFF6366F1),
                      onTap: () {
                        context.push('/yaseen');
                      },
                    ),
                  ),
                if (hasYaseenProgress && hasDhikrProgress)
                  const SizedBox(width: 14),
                if (hasDhikrProgress)
                  Expanded(
                    child: _SmallJourneyCard(
                      icon: Icons.fingerprint_rounded,
                      title: activeJourney.name,
                      progress: activeJourney.progress,
                      progressLabel:
                      '${activeJourney.currentCount}/'
                          '${activeJourney.targetCount}',
                      accentColor: const Color(0xFFCF376A),
                      onTap: () {
                        context.push(
                          '/tasbeeh/counter/${activeJourney.id}',
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  double _calculateQuranProgress(int surah, int ayah) {
    var completedAyahs = 0;

    for (var index = 1; index < surah; index++) {
      completedAyahs += quran.getVerseCount(index);
    }

    completedAyahs += ayah;

    // The Quran contains 6,236 verses.
    return (completedAyahs / 6236).clamp(0.0, 1.0);
  }

  Widget _buildSectionHeader(
      BuildContext context, {
        required String title,
        required String subtitle,
        String? actionText,
        VoidCallback? onAction,
      }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.55),
              ),
            ),
          ],
        ),
        const Spacer(),
        if (actionText != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                actionText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: RushdColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// REDESIGNED PRAYER CAROUSEL TILE
// ============================================================================

class _RedesignedPrayerCarouselTile extends StatelessWidget {
  const _RedesignedPrayerCarouselTile({
    required this.prayer,
    required this.isCurrent,
    required this.isNext,
    required this.gradientColors,
    required this.watermarkPath,
  });

  final PrayerTime prayer;
  final bool isCurrent;
  final bool isNext;
  final List<Color> gradientColors;
  final String watermarkPath;

  @override
  Widget build(BuildContext context) {
    final isDarkCard =
        prayer.name.toLowerCase() == 'fajr' ||
            prayer.name.toLowerCase() == 'isha';

    final textColor = isDarkCard ? Colors.white : const Color(0xFF0F172A);
    final secondaryColor = isDarkCard
        ? Colors.white.withOpacity(0.65)
        : const Color(0xFF0F172A).withOpacity(0.5);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? const Color(0xFF0F766E).withOpacity(0.22)
                : const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isCurrent
                ? (isDarkCard
                ? Colors.white.withOpacity(0.4)
                : const Color(0xFF0F766E).withOpacity(0.4))
                : Colors.white.withOpacity(0.15),
            width: isCurrent ? 2.5 : 1.5,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Opacity(
                opacity: isDarkCard ? 0.15 : 0.09,
                child: SvgPicture.asset(
                  watermarkPath,
                  width: 110,
                  height: 110,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        prayer.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    if (prayer.arabicName.isNotEmpty)
                      Text(
                        prayer.arabicName,
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Amiri',
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkCard
                        ? Colors.white.withOpacity(0.08)
                        : Colors.white.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDarkCard
                          ? Colors.white.withOpacity(0.08)
                          : Colors.white.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Azan Time: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _formatTime(prayer.time),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrent)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkCard
                            ? Colors.white.withOpacity(0.15)
                            : const Color(0xFF0F766E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lens_rounded,
                            size: 7,
                            color: isDarkCard
                                ? Colors.white
                                : const Color(0xFF0F766E),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Current Prayer',
                            style: TextStyle(
                              color: isDarkCard
                                  ? Colors.white
                                  : const Color(0xFF0F766E),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (isNext)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 10,
                            color: Color(0xFFEA580C),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Coming Up Next',
                            style: TextStyle(
                              color: Color(0xFFEA580C),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final isPm = hour >= 12;
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} ${isPm ? 'PM' : 'AM'}';
  }
}

// ============================================================================
// HERO TYPES & CARDS (Intact per instructions)
// ============================================================================

enum _HeroType { prayer, ayah, advertisement }

class _DailyAyahHeroCard extends StatelessWidget {
  const _DailyAyahHeroCard();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;

    final surah = (dayOfYear % 114) + 1;
    final totalVerses = quran.getVerseCount(surah);
    final ayah = (dayOfYear % totalVerses) + 1;

    final surahName = QuranMetadata.englishMeanings[surah];
    final arabicName = quran.getSurahNameArabic(surah);
    final malayalamMeaning = QuranMetadata.malayalamMeanings[surah];
    final malayalamName = QuranMetadata.malayalamNames[surah] ?? '';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/quran/verse/$surah/$ayah');
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0C7043),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                top: -90,
                left: -70,
                child: Opacity(
                  opacity: 0.15,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1CB76E),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(26.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B8361).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'FEATURED AYAH',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Today's Quran Verse",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$arabicName • $malayalamName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '($surahName/$malayalamMeaning)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ayah $ayah',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tap to explore',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 17,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdvertisementHeroCard extends StatelessWidget {
  const _AdvertisementHeroCard();

  @override
  Widget build(BuildContext context) {
    return _HeroContainer(
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -40,
            child: _HeroDecoration(icon: Icons.auto_awesome_rounded),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HeroPill(
                  icon: Icons.campaign_outlined,
                  label: 'ADVERTISEMENT',
                ),
                const Spacer(),
                const Text(
                  'Support something\nmeaningful.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Discover services and initiatives from trusted partners.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Learn More',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroContainer extends StatelessWidget {
  final Widget child;
  const _HeroContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF115E59), Color(0xFF0F766E), Color(0xFF134E4A)],
        ),
        boxShadow: [
          BoxShadow(
            color: RushdColors.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HeroDecoration extends StatelessWidget {
  final IconData icon;
  const _HeroDecoration({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: 180, color: Colors.white.withOpacity(0.05));
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 12),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.9,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// REDESIGNED WORSHIP TILES (Sleek Professional Design)
// ============================================================================

class _WorshipFeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final String? badgeText;
  final VoidCallback onTap;

  const _WorshipFeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _BaseTile(
      onTap: onTap,
      radius: 24,
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 130,
        child: Stack(
          children: [
            Positioned(
              right: -16,
              bottom: -24,
              child: Icon(
                icon,
                size: 140,
                color: accentColor.withOpacity(0.06),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _IconBox(icon: icon, color: accentColor, size: 48),
                    const Spacer(),
                    if (badgeText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badgeText!,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WorshipMediumTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _WorshipMediumTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _BaseTile(
      onTap: onTap,
      radius: 22,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _IconBox(icon: icon, color: accentColor, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 11,
            color: theme.iconTheme.color?.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}

class _WorshipCompactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accentColor;
  final VoidCallback onTap;

  const _WorshipCompactTile({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _BaseTile(
      onTap: onTap,
      radius: 20,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _IconBox(icon: icon, color: accentColor, size: 38),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// REDESIGNED POLISHED JOURNEY CARDS (Bento Glass Style)
// ============================================================================

class _JourneyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double progress;
  final String progressLabel;
  final Color accentColor;
  final VoidCallback onTap;

  const _JourneyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.progressLabel,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: accentColor.withOpacity(0.25),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.cardColor,
                  accentColor.withOpacity(0.04),
                ],
              ),
            ),
            child: Row(
              children: [
                _IconBox(icon: icon, color: accentColor, size: 50),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              progressLabel,
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 7,
                          backgroundColor: accentColor.withOpacity(0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallJourneyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double progress;
  final String progressLabel;
  final Color accentColor;
  final VoidCallback onTap;

  const _SmallJourneyCard({
    required this.icon,
    required this.title,
    required this.progress,
    required this.progressLabel,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: accentColor.withOpacity(0.22),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.cardColor,
                  accentColor.withOpacity(0.04),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _IconBox(icon: icon, color: accentColor, size: 42),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        progressLabel,
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: accentColor.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// BASE CONTAINER & ICON BOX HELPERS
// ============================================================================

class _BaseTile extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;

  const _BaseTile({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final tile = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.1 : 0.025,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) {
      return tile;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: tile,
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _IconBox({required this.icon, required this.color, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, color: color, size: size * 0.48),
    );
  }
}

// ============================================================================
// REDESIGNED FROSTED GLASS HEADER
// ============================================================================

class _RushdGreetingHeader extends SliverPersistentHeaderDelegate {
  final DateTime now;

  _RushdGreetingHeader({required this.now});

  @override
  double get minExtent => 74;

  @override
  double get maxExtent => 136;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    final theme = Theme.of(context);
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 8, 20, progress > 0.7 ? 10 : 12),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withOpacity(0.85),
            border: Border(
              bottom: BorderSide(color: theme.dividerColor.withOpacity(0.3)),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: progress > 0.72
                ? _buildCollapsedHeader(context)
                : _buildExpandedHeader(context),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      key: const ValueKey('expanded'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: RushdColors.primary.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: RushdColors.primary.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: RushdColors.primary,
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assalamu Alaikum',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: RushdColors.primary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'Tharikh',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                _formatDate(now),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
        _HeaderButton(
          icon: Icons.notifications_none_rounded,
          onTap: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
        const SizedBox(width: 10),
        _HeaderButton(
          icon: Icons.settings_outlined,
          onTap: () {
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ],
    );
  }

  Widget _buildCollapsedHeader(BuildContext context) {
    return Row(
      key: const ValueKey('collapsed'),
      children: [
        const Text(
          'RUSHD',
          style: TextStyle(
            color: RushdColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        const Spacer(),
        _HeaderButton(
          icon: Icons.notifications_none_rounded,
          onTap: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
        const SizedBox(width: 10),
        _HeaderButton(
          icon: Icons.settings_outlined,
          onTap: () {
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
    ];

    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  @override
  bool shouldRebuild(covariant _RushdGreetingHeader oldDelegate) {
    return oldDelegate.now != now;
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
          ),
          child: Icon(icon, size: 18, color: theme.iconTheme.color),
        ),
      ),
    );
  }
}