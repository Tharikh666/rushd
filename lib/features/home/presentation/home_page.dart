import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:rushd/features/home/presentation/widgets/prayer_home_widgets.dart';

import '../../../../core/premium/feature_access_controller.dart';
import '../../../../core/premium/rushd_feature.dart';
import '../../../../core/theme/rushd_colors.dart';

class RushdHomeScreen extends ConsumerStatefulWidget {
  const RushdHomeScreen({super.key});

  @override
  ConsumerState<RushdHomeScreen> createState() => _RushdHomeScreenState();
}

class _RushdHomeScreenState extends ConsumerState<RushdHomeScreen> {
  final PageController _heroController = PageController(
    initialPage: 1000,
  );

  Timer? _heroTimer;
  Timer? _clockTimer;

  int _heroPage = 1000;

  DateTime _now = DateTime.now();

  final List<_HeroType> _heroTypes = const [
    _HeroType.prayer,
    _HeroType.ayah,
    _HeroType.advertisement,
  ];

  @override
  void initState() {
    super.initState();

    _heroTimer = Timer.periodic(
      const Duration(seconds: 5),
          (_) {
        if (!_heroController.hasClients) return;

        _heroPage++;

        _heroController.animateToPage(
          _heroPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      },
    );

    _clockTimer = Timer.periodic(
      const Duration(minutes: 1),
          (_) {
        if (!mounted) return;

        setState(() {
          _now = DateTime.now();
        });
      },
    );
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _clockTimer?.cancel();
    _heroController.dispose();

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
                delegate: _RushdGreetingHeader(
                  now: _now,
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    20,
                    16,
                    120,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroCarousel(context),

                      const SizedBox(height: 30),

                      _buildSectionHeader(
                        context,
                        title: 'WORSHIP',
                      ),

                      const SizedBox(height: 14),

                      _buildWorshipSection(context),

                      const SizedBox(height: 30),

                      _buildSectionHeader(
                        context,
                        title: "TODAY'S PRAYERS",
                        actionText: 'View All',
                        onAction: () {
                          context.push('/prayer-times');
                        },
                      ),

                      const SizedBox(height: 14),

                      const PrayerHomeTimeline(),

                      const SizedBox(height: 30),

                      _buildSectionHeader(
                        context,
                        title: 'CONTINUE YOUR JOURNEY',
                      ),

                      const SizedBox(height: 14),

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
    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) return;

    setState(() {
      _now = DateTime.now();
    });
  }

  Widget _buildHeroCarousel(BuildContext context) {
    final featureAccess =
    ref.watch(featureAccessControllerProvider);

    final showAdvertisement =
    featureAccess.canAccess(RushdFeature.ads);

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
              final type =
              visibleHeroTypes[index % visibleHeroTypes.length];

              return AnimatedBuilder(
                animation: _heroController,
                builder: (context, child) {
                  double scale = 1.0;

                  if (_heroController.position.haveDimensions) {
                    final page =
                        _heroController.page ?? _heroPage.toDouble();

                    final difference =
                    (page - index).abs().clamp(0.0, 1.0);

                    scale = 1 - (difference * 0.04);
                  }

                  return Transform.scale(
                    scale: scale,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                      ),
                      child: child,
                    ),
                  );
                },
                child: _buildHeroCard(
                  context,
                  type,
                ),
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

        const SizedBox(height: 12),

        _buildHeroIndicator(
          context,
          visibleHeroTypes.length,
        ),
      ],
    );
  }

  Widget _buildHeroCard(
      BuildContext context,
      _HeroType type,
      ) {
    switch (type) {
      case _HeroType.prayer:
        return const PrayerHomeHeroCard();

      case _HeroType.ayah:
        return const _DailyAyahHeroCard();

      case _HeroType.advertisement:
        return const _AdvertisementHeroCard();
    }
  }

  Widget _buildHeroIndicator(
      BuildContext context,
      int count,
      ) {
    final activeIndex = _heroPage % count;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
            (index) {
          final active = index == activeIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            width: active ? 32 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: active
                  ? RushdColors.primary
                  : RushdColors.primary.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorshipSection(BuildContext context) {
    return Column(
      children: [
        // ---------------------------------------------------------
        // QURAN
        // ---------------------------------------------------------
        _WorshipFeatureTile(
          icon: Icons.menu_book_rounded,
          title: 'Quran',
          subtitle: 'Read, listen and reflect',
          accentColor: RushdColors.primary,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/quran',
            );
          },
        ),

        const SizedBox(height: 12),

        // ---------------------------------------------------------
        // YASEEN + QIBLA
        // ---------------------------------------------------------
        Row(
          children: [
            Expanded(
              child: _WorshipMediumTile(
                icon: Icons.auto_stories_rounded,
                title: 'Yaseen',
                subtitle: 'Heart of Quran',
                accentColor: const Color(0xFF6366F1),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/yaseen',
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _WorshipMediumTile(
                icon: Icons.explore_rounded,
                title: 'Qibla',
                subtitle: 'Find direction',
                accentColor: const Color(0xFFF59E0B),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/qibla',
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ---------------------------------------------------------
        // SALAH / DUAS / DHIKR
        // ---------------------------------------------------------
        Row(
          children: [
            Expanded(
              child: _WorshipCompactTile(
                icon: Icons.mosque_rounded,
                title: 'Salah',
                accentColor: RushdColors.primary,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/salah-guide',
                  );
                },
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _WorshipCompactTile(
                icon: Icons.favorite_outline_rounded,
                title: 'Duas',
                accentColor: const Color(0xFFEC4899),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/duas',
                  );
                },
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _WorshipCompactTile(
                icon: Icons.fingerprint_rounded,
                title: 'Dhikr',
                accentColor: const Color(0xFF0EA5E9),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/tasbeeh',
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJourneySection(BuildContext context) {
    return Column(
      children: [
        _JourneyCard(
          icon: Icons.menu_book_rounded,
          title: 'Quran',
          subtitle: 'Surah Al-Baqarah',
          progress: 0.64,
          progressLabel: '64%',
          accentColor: RushdColors.primary,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/quran',
            );
          },
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _SmallJourneyCard(
                icon: Icons.auto_stories_rounded,
                title: 'Yaseen',
                progress: 0.72,
                progressLabel: '72%',
                accentColor: const Color(0xFF6366F1),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/yaseen',
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _SmallJourneyCard(
                icon: Icons.fingerprint_rounded,
                title: 'Dhikr',
                progress: 0.34,
                progressLabel: '34%',
                accentColor: const Color(0xFF0EA5E9),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/tasbeeh',
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, {
        required String title,
        String? actionText,
        VoidCallback? onAction,
      }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        if (actionText != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: RushdColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// HERO TYPES
// ============================================================================

enum _HeroType {
  prayer,
  ayah,
  advertisement,
}

// ============================================================================
// NEXT PRAYER HERO
// ============================================================================

class _NextPrayerHeroCard extends StatelessWidget {
  const _NextPrayerHeroCard();

  @override
  Widget build(BuildContext context) {
    return _HeroContainer(
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -40,
            child: _HeroDecoration(
              icon: Icons.mosque_rounded,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _HeroPill(
                      icon: Icons.access_time_rounded,
                      label: 'NEXT PRAYER',
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white70,
                    ),
                  ],
                ),

                const Spacer(),

                const Text(
                  'Asr',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),

                const SizedBox(height: 2),

                const Text(
                  '04:21 PM',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    const Text(
                      'Starts in ',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const Text(
                      '01h 24m',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  children: const [
                    _PrayerMiniTime(
                      name: 'Fajr',
                      time: '05:12',
                      active: false,
                    ),
                    _PrayerMiniTime(
                      name: 'Dhuhr',
                      time: '12:32',
                      active: false,
                    ),
                    _PrayerMiniTime(
                      name: 'Asr',
                      time: '04:21',
                      active: true,
                    ),
                    _PrayerMiniTime(
                      name: 'Maghrib',
                      time: '06:18',
                      active: false,
                    ),
                    _PrayerMiniTime(
                      name: 'Isha',
                      time: '07:34',
                      active: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DAILY AYAH HERO
// ============================================================================

class _DailyAyahHeroCard extends StatelessWidget {
  const _DailyAyahHeroCard();

  @override
  Widget build(BuildContext context) {
    return _HeroContainer(
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: _HeroDecoration(
              icon: Icons.auto_awesome_rounded,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const _HeroPill(
                  icon: Icons.menu_book_rounded,
                  label: "TODAY'S AYAH",
                ),

                const Spacer(),

                const Text(
                  'وَاذْكُرُونِي أَذْكُرْكُمْ',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    height: 1.7,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '“And remember Me; I will remember you.”',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Text(
                      'Al-Baqarah • 2:152',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white.withOpacity(0.8),
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ADVERTISEMENT HERO
// ============================================================================

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
            child: _HeroDecoration(
              icon: Icons.auto_awesome_rounded,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
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
                    fontSize: 28,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Discover services and initiatives from trusted partners.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Learn More',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 15,
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

// ============================================================================
// HERO CONTAINER
// ============================================================================

class _HeroContainer extends StatelessWidget {
  final Widget child;

  const _HeroContainer({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF115E59),
            Color(0xFF0F766E),
            Color(0xFF134E4A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: RushdColors.primary.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HeroDecoration extends StatelessWidget {
  final IconData icon;

  const _HeroDecoration({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: 190,
      color: Colors.white.withOpacity(0.055),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 13,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerMiniTime extends StatelessWidget {
  final String name;
  final String time;
  final bool active;

  const _PrayerMiniTime({
    required this.name,
    required this.time,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 5),
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withOpacity(0.15)
              : Colors.white.withOpacity(0.055),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: active
                ? Colors.white.withOpacity(0.20)
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Text(
              name,
              style: TextStyle(
                color: Colors.white.withOpacity(
                  active ? 1 : 0.55,
                ),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              time,
              style: TextStyle(
                color: Colors.white.withOpacity(
                  active ? 1 : 0.65,
                ),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// WORSHIP FEATURE TILE
// ============================================================================

class _WorshipFeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _WorshipFeatureTile({
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
      radius: 28,
      padding: const EdgeInsets.all(22),
      child: SizedBox(
        height: 145,
        child: Stack(
          children: [
            Positioned(
              right: -12,
              bottom: -28,
              child: Icon(
                icon,
                size: 150,
                color: accentColor.withOpacity(0.045),
              ),
            ),

            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _IconBox(
                  icon: icon,
                  color: accentColor,
                  size: 54,
                ),

                const Spacer(),

                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color
                        ?.withOpacity(0.62),
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

// ============================================================================
// WORSHIP MEDIUM TILE
// ============================================================================

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
      radius: 24,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          _IconBox(
            icon: icon,
            color: accentColor,
            size: 46,
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: theme.textTheme.bodySmall?.color
                        ?.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 12,
            color: theme.iconTheme.color?.withOpacity(0.35),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WORSHIP COMPACT TILE
// ============================================================================

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
      radius: 22,
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 8,
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          _IconBox(
            icon: icon,
            color: accentColor,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerItem {
  final String name;
  final String time;
  final bool completed;
  final bool current;

  const _PrayerItem({
    required this.name,
    required this.time,
    this.completed = false,
    this.current = false,
  });
}

// ============================================================================
// JOURNEY CARD
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

    return _BaseTile(
      onTap: onTap,
      radius: 24,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          _IconBox(
            icon: icon,
            color: accentColor,
            size: 48,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: theme.textTheme.bodySmall?.color
                        ?.withOpacity(0.55),
                  ),
                ),

                const SizedBox(height: 10),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor:
                    accentColor.withOpacity(0.10),
                    valueColor:
                    AlwaysStoppedAnimation<Color>(
                      accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          Column(
            children: [
              Text(
                progressLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Icon(
                Icons.arrow_forward_rounded,
                size: 17,
                color:
                theme.iconTheme.color?.withOpacity(0.4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SMALL JOURNEY CARD
// ============================================================================

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

    return _BaseTile(
      onTap: onTap,
      radius: 22,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBox(
                icon: icon,
                color: accentColor,
                size: 40,
              ),
              const Spacer(),
              Text(
                progressLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor:
              accentColor.withOpacity(0.10),
              valueColor:
              AlwaysStoppedAnimation<Color>(
                accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BASE TILE
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
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final tile = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.65),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark
                  ? 0.12
                  : 0.035,
            ),
            blurRadius: 18,
            offset: const Offset(0, 7),
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

// ============================================================================
// ICON BOX
// ============================================================================

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _IconBox({
    required this.icon,
    required this.color,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(
          size * 0.34,
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: size * 0.48,
      ),
    );
  }
}

// ============================================================================
// GREETING HEADER
// ============================================================================

class _RushdGreetingHeader
    extends SliverPersistentHeaderDelegate {
  final DateTime now;

  _RushdGreetingHeader({
    required this.now,
  });

  @override
  double get minExtent => 78;

  @override
  double get maxExtent => 142;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    final theme = Theme.of(context);

    final progress =
    (shrinkOffset / (maxExtent - minExtent))
        .clamp(0.0, 1.0);

    final greeting = _greetingForHour(now.hour);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            16,
            10,
            16,
            progress > 0.7 ? 8 : 14,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor
                .withOpacity(0.82),
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor.withOpacity(0.5),
              ),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(
              milliseconds: 220,
            ),
            child: progress > 0.72
                ? _buildCollapsedHeader(
              context,
            )
                : _buildExpandedHeader(
              context,
              greeting,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedHeader(
      BuildContext context,
      String greeting,
      ) {
    final theme = Theme.of(context);

    return Row(
      key: const ValueKey('expanded'),
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: RushdColors.primary.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: RushdColors.primary,
            size: 25,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: theme.textTheme.bodySmall?.color
                      ?.withOpacity(0.55),
                ),
              ),

              const SizedBox(height: 2),

              Text(
                'Tharikh',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                _formatDate(now),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: theme.textTheme.bodySmall?.color
                      ?.withOpacity(0.50),
                ),
              ),
            ],
          ),
        ),

        _HeaderButton(
          icon: Icons.notifications_none_rounded,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/notifications',
            );
          },
        ),

        const SizedBox(width: 8),

        _HeaderButton(
          icon: Icons.settings_outlined,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/settings',
            );
          },
        ),
      ],
    );
  }

  Widget _buildCollapsedHeader(
      BuildContext context,
      ) {
    return Row(
      key: const ValueKey('collapsed'),
      children: [
        const Text(
          'RUSHD',
          style: TextStyle(
            color: RushdColors.primary,
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
          ),
        ),

        const Spacer(),

        _HeaderButton(
          icon: Icons.notifications_none_rounded,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/notifications',
            );
          },
        ),

        const SizedBox(width: 8),

        _HeaderButton(
          icon: Icons.settings_outlined,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/settings',
            );
          },
        ),
      ],
    );
  }

  String _greetingForHour(int hour) {
    if (hour < 12) {
      return 'Assalamu Alaikum';
    }

    if (hour < 17) {
      return 'Assalamu Alaikum';
    }

    return 'Assalamu Alaikum';
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

    return '${weekdays[date.weekday - 1]}, '
        '${date.day} ${months[date.month - 1]}';
  }

  @override
  bool shouldRebuild(
      covariant _RushdGreetingHeader oldDelegate,
      ) {
    return oldDelegate.now != now;
  }
}

// ============================================================================
// HEADER BUTTON
// ============================================================================

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.6),
            ),
          ),
          child: Icon(
            icon,
            size: 19,
            color: theme.iconTheme.color,
          ),
        ),
      ),
    );
  }
}