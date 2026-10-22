import 'package:flutter/material.dart';
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
  };

  static const Map<String, IconData> _categoryIcons = {
    'daily_essentials': Icons.wb_sunny_outlined,
    'salah_related': Icons.mosque_outlined,
    'quran_related': Icons.menu_book_outlined,
    'ramadan': Icons.nightlight_round,
    'food_and_drink': Icons.restaurant_outlined,
    'sleep': Icons.bedtime_outlined,
    'travel': Icons.luggage_outlined,
    'wudu_and_purification': Icons.water_drop_outlined,
    'protection': Icons.shield_outlined,
    'home_and_family': Icons.home_outlined,
    'janaza': Icons.volunteer_activism_outlined,
  };

  @override
  void initState() {
    super.initState();
    _duasFuture = _repository.getAllDuas();
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

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Duas'), centerTitle: false),
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

          final featuredDuas = duas
              .where((dua) => dua['featured'] == true)
              .toList();

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _duasFuture = _repository.getAllDuas();
              });
              await _duasFuture;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.auto_awesome_outlined,
                        color: colors.onPrimaryContainer,
                        size: 28,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Remember Allah throughout your day',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Explore authentic supplications for everyday moments, worship, and reflection.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onPrimaryContainer,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatChip(
                            icon: Icons.menu_book_outlined,
                            label: '${duas.length} duas and adhkar',
                            foreground: colors.onPrimaryContainer,
                          ),
                          _StatChip(
                            icon: Icons.category_outlined,
                            label: '${categories.length} categories',
                            foreground: colors.onPrimaryContainer,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                Text(
                  'Explore by category',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Find a supplication for the moment.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.45,
                  ),
                  itemBuilder: (context, index) {
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
                  },
                ),

                if (featuredDuas.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  Text(
                    'Featured duas',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Supplications selected from your collection.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...featuredDuas.map(
                    (dua) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FeaturedDuaCard(
                        dua: dua,
                        onTap: () => _openDua(dua),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

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

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22, color: colors.onPrimaryContainer),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count ${count == 1 ? 'dua' : 'duas'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedDuaCard extends StatelessWidget {
  const _FeaturedDuaCard({required this.dua, required this.onTap});

  final Map<String, dynamic> dua;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final title = dua['title']?.toString() ?? 'Untitled dua';
    final arabic = dua['arabic']?.toString() ?? '';

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
              if (arabic.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  arabic,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: theme.textTheme.headlineSmall?.copyWith(height: 1.8),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Tap to read the full dua',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 40),
            const SizedBox(height: 12),
            Text(message),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
