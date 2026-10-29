import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/dua_repository.dart';

class DuaCategoryScreen extends StatefulWidget {
  const DuaCategoryScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  State<DuaCategoryScreen> createState() => _DuaCategoryScreenState();
}

class _DuaCategoryScreenState extends State<DuaCategoryScreen> {
  final DuaRepository _repository = DuaRepository();

  late Future<List<Map<String, dynamic>>> _duasFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    _loadDuas();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadDuas() {
    _duasFuture = _repository.getDuasByCategory(widget.categoryId);
  }

  Future<void> _refreshDuas() async {
    setState(() {
      _loadDuas();
    });
    await _duasFuture;
  }

  String get _categoryTitle {
    return widget.categoryId
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    const amberPrimary = Color(0xFFD97706);
    final categoryIcon =
        _categoryIcons[widget.categoryId] ?? Icons.menu_book_rounded;

    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _duasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorView(colors, amberPrimary);
          }

          final allDuas = snapshot.data ?? [];
          final filteredDuas = allDuas.where((dua) {
            final title = (dua['title']?.toString() ?? '').toLowerCase();
            final translation = (dua['translation']?.toString() ?? '')
                .toLowerCase();
            return title.contains(_searchQuery) ||
                translation.contains(_searchQuery);
          }).toList();

          return RefreshIndicator(
            onRefresh: _refreshDuas,
            color: amberPrimary,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // 1. Sleek Amber Gradient Header with Centered App Bar Title & Dynamic Watermark Icon
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 210,
                  backgroundColor: amberPrimary,
                  centerTitle: true,
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: Text(
                    _categoryTitle.toUpperCase(),
                    style: const TextStyle(
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
                            right: -10,
                            bottom: -15,
                            child: Icon(
                              categoryIcon,
                              size: 140,
                              color: Colors.white12,
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    '${allDuas.length} Supplications',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Explore curated Adhkar for this collection',
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

                // 2. Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.outline.withValues(alpha: 0.15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(fontSize: 14, color: colors.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Search duas in $_categoryTitle...',
                          hintStyle: TextStyle(
                            color: colors.onSurfaceVariant.withValues(
                              alpha: 0.7,
                            ),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: amberPrimary,
                            size: 20,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    size: 18,
                                  ),
                                  onPressed: () => _searchController.clear(),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Duas List / Empty State
                if (filteredDuas.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(colors),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final dua = filteredDuas[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _DuaCard(
                            index: index + 1,
                            dua: dua,
                            amberPrimary: amberPrimary,
                          ),
                        );
                      }, childCount: filteredDuas.length),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(ColorScheme colors, Color amberPrimary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load supplications.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => setState(_loadDuas),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
              style: FilledButton.styleFrom(backgroundColor: amberPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _searchQuery.isNotEmpty
                  ? Icons.search_off_rounded
                  : Icons.menu_book_rounded,
              size: 54,
              color: colors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 14),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No duas match "$_searchQuery"'
                  : 'No duas found in this category.',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// DUA ITEM CARD
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// DUA ITEM CARD
// -----------------------------------------------------------------------------

class _DuaCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> dua;
  final Color amberPrimary;

  const _DuaCard({
    required this.index,
    required this.dua,
    required this.amberPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final id = dua['id']?.toString() ?? '';
    final title = dua['title']?.toString() ?? 'Untitled Dua';
    final arabic = dua['arabic']?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
          onTap: id.isEmpty
              ? null
              : () {
                  // Dismiss the keyboard before navigating
                  FocusManager.instance.primaryFocus?.unfocus();
                  context.push('/duas/$id');
                },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: amberPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: amberPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                      if (arabic.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          arabic,
                          textDirection: TextDirection.rtl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
