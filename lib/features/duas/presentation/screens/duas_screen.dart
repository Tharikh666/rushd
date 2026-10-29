import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/dua_repository.dart';

class DuasScreen extends StatefulWidget {
  const DuasScreen({super.key});

  @override
  State<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends State<DuasScreen> {
  final DuaRepository _repository = DuaRepository();

  late Future<List<Map<String, dynamic>>> _duasFuture;
  late Future<List<Map<String, dynamic>>> _dailyDuasFuture;

  static const Map<String, String> _categoryNames = {
    'daily_essentials': 'Daily Essentials',
    'salah_related': 'Salah',
    'quran_related': 'Quran',
    'ramadan': 'Ramadan',
    'food_and_drink': 'Food and Drink',
    'sleep': 'Sleep',
    'travel': 'Travel',
    'wudu_and_purification': 'Wudu and Purification',
    'protection': 'Protection',
    'home_and_family': 'Home and Family',
    'janaza': 'Janazah',
    'goal_achievement': 'Goal Achievement',
  };

  static const Map<String, IconData> _categoryIcons = {
    'daily_essentials': Icons.wb_sunny_rounded,
    'salah_related': Icons.mosque_rounded,
    'quran_related': Icons.menu_book_rounded,
    'ramadan': Icons.nightlight_round,
    'food_and_drink': Icons.restaurant_rounded,
    'sleep': Icons.bedtime_rounded,
    'travel': Icons.luggage_rounded,
    'wudu_and_purification': Icons.water_drop_rounded,
    'protection': Icons.shield_rounded,
    'home_and_family': Icons.home_rounded,
    'janaza': Icons.volunteer_activism_rounded,
    'goal_achievement': Icons.track_changes_rounded,
  };

  @override
  void initState() {
    super.initState();
    _duasFuture = _repository.getAllDuas();
    _dailyDuasFuture = _repository.getDuasOfTheDay();
  }

  String _categoryName(String id) {
    if (_categoryNames.containsKey(id)) {
      return _categoryNames[id]!;
    }

    return id
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  void _openCategory(String categoryId) {
    context.push('/duas/category/$categoryId');
  }

  void _openDua(Map<String, dynamic> dua) {
    final id = dua['id']?.toString();

    if (id == null || id.isEmpty) return;

    context.push('/duas/$id');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    const amberPrimary = Color(0xFFD97706);

    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _duasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorView(
              message: 'Unable to load duas.',
              onRetry: () {
                setState(() {
                  _duasFuture = _repository.getAllDuas();
                });
              },
            );
          }

          final duas = snapshot.data ?? [];
          final categoryCounts = <String, int>{};

          for (final dua in duas) {
            final category = dua['category']?.toString();
            if (category == null || category.isEmpty) continue;
            categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
          }

          final categories = categoryCounts.keys.toList()
            ..sort((a, b) => _categoryName(a).compareTo(_categoryName(b)));

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _duasFuture = _repository.getAllDuas();
                _dailyDuasFuture = _repository.getDuasOfTheDay();
              });

              await Future.wait([_duasFuture, _dailyDuasFuture]);
            },
            color: amberPrimary,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // 1. Sleek Gradient App Bar with Centered App Bar Title & Clean Hero
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 230,
                  backgroundColor: amberPrimary,
                  centerTitle: true,
                  title: const Text(
                    'DUAS & DHIKRS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.2,
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 64, 20, 20),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -25,
                            bottom: -30,
                            child: IgnorePointer(
                              child: Opacity(
                                opacity: 0.16,
                                child: SvgPicture.asset(
                                  'assets/icons/worship_icons/dua.svg',
                                  width: 180,
                                  height: 180,
                                  fit: BoxFit.contain,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        '${duas.length} Authentic Supplications',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        '${categories.length} Categories',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'أذكار و أدعية',
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Remember Allah throughout your day & night',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
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

                // 2. Overview Stats Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: colors.outline.withValues(alpha: 0.15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: amberPrimary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.menu_book_rounded,
                                  color: amberPrimary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Authentic Adhkar & Duas',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Explore authentic supplications for everyday moments, worship, and spiritual reflection.',
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 13.5,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _StatChip(
                                icon: Icons.format_list_numbered_rounded,
                                label: '${duas.length} Duas',
                              ),
                              _StatChip(
                                icon: Icons.grid_view_rounded,
                                label: '${categories.length} Categories',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Material(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => context.push('/duas/search'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: amberPrimary.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search_rounded,
                                color: amberPrimary,
                                size: 23,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Search duas, dhikr, meanings...',
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.tune_rounded,
                                color: colors.onSurfaceVariant.withValues(
                                  alpha: 0.7,
                                ),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Category Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore by Category',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Find a supplication for the moment.',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. Categories Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.45,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final categoryId = categories[index];
                      final count = categoryCounts[categoryId] ?? 0;

                      return _CategoryCard(
                        title: _categoryName(categoryId),
                        count: count,
                        icon:
                            _categoryIcons[categoryId] ??
                            Icons.bookmark_border_rounded,
                        onTap: () => _openCategory(categoryId),
                      );
                    }, childCount: categories.length),
                  ),
                ),

                // 5. Duas of the Day Section
                SliverToBoxAdapter(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _dailyDuasFuture,
                    builder: (context, dailySnapshot) {
                      if (dailySnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final dailyDuas = dailySnapshot.data ?? [];
                      if (dailyDuas.isEmpty) {
                        return const SizedBox(height: 32);
                      }

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Duas of the Day',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Selected reminders for your daily reflections.',
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ...dailyDuas.map(
                              (dua) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _FeaturedDuaCard(
                                  dua: dua,
                                  onTap: () => _openDua(dua),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CATEGORY CARD
// -----------------------------------------------------------------------------

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final int count;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    const amberPrimary = Color(0xFFD97706);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: amberPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, size: 20, color: amberPrimary),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count ${count == 1 ? 'dua' : 'duas'}',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// FEATURED DUA CARD
// -----------------------------------------------------------------------------

class _FeaturedDuaCard extends StatelessWidget {
  const _FeaturedDuaCard({required this.dua, required this.onTap});

  final Map<String, dynamic> dua;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    const amberPrimary = Color(0xFFD97706);
    final title = dua['title']?.toString() ?? 'Untitled dua';
    final arabic = dua['arabic']?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
                if (arabic.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    arabic,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 22,
                      height: 1.8,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                const Text(
                  'Tap to read full supplication',
                  style: TextStyle(
                    color: amberPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
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

// -----------------------------------------------------------------------------
// STAT CHIP
// -----------------------------------------------------------------------------

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const amberPrimary = Color(0xFFD97706);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: amberPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ERROR VIEW
// -----------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    const amberPrimary = Color(0xFFD97706);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Duas')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
                style: FilledButton.styleFrom(backgroundColor: amberPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
