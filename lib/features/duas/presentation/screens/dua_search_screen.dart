import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/dua_repository.dart';

class DuaSearchScreen extends StatefulWidget {
  const DuaSearchScreen({super.key});

  @override
  State<DuaSearchScreen> createState() => _DuaSearchScreenState();
}

class _DuaSearchScreenState extends State<DuaSearchScreen> {
  final DuaRepository _repository = DuaRepository();
  final TextEditingController _controller = TextEditingController();

  late Future<List<Map<String, dynamic>>> _duasFuture;

  String _query = '';
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _duasFuture = _repository.getAllDuas();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterResults(List<Map<String, dynamic>> duas) {
    final query = _query.trim().toLowerCase();

    return duas.where((dua) {
      final category = (dua['category'] ?? '').toString();

      if (_selectedCategory != 'all' &&
          category.toLowerCase() != _selectedCategory) {
        return false;
      }

      if (query.isEmpty) return true;

      final searchableFields = [
        dua['title'],
        dua['arabic'],
        dua['english_transliteration'],
        dua['malayalam_transliteration'],
        dua['english_translation'],
        dua['malayalam_translation'],
        dua['category'],
        dua['type'],
        dua['source'],
      ];

      return searchableFields.any(
        (value) =>
            value != null && value.toString().toLowerCase().contains(query),
      );
    }).toList();
  }

  String _formatCategory(String value) {
    return value
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  void _openDua(Map<String, dynamic> dua) {
    final id = dua['id']?.toString();

    if (id == null || id.isEmpty) return;

    FocusManager.instance.primaryFocus?.unfocus();

    context.push('/duas/$id');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    const amberPrimary = Color(0xFFD97706);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Recitations'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: TextField(
              controller: _controller,
              onChanged: (value) {
                setState(() => _query = value);
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search name, Arabic, meaning...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                    : null,
                filled: true,
                fillColor: colors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: amberPrimary),
                ),
              ),
            ),
          ),

          // Category filters
          SizedBox(
            height: 46,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _duasFuture,
              builder: (context, snapshot) {
                final duas = snapshot.data ?? [];

                final categories =
                    duas
                        .map((dua) => dua['category']?.toString() ?? '')
                        .where((category) => category.isNotEmpty)
                        .toSet()
                        .toList()
                      ..sort();

                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _CategoryFilterChip(
                      label: 'All',
                      selected: _selectedCategory == 'all',
                      amberPrimary: amberPrimary,
                      onTap: () {
                        setState(() => _selectedCategory = 'all');
                      },
                    ),
                    ...categories.map(
                      (category) => _CategoryFilterChip(
                        label: _formatCategory(category),
                        selected: _selectedCategory == category.toLowerCase(),
                        amberPrimary: amberPrimary,
                        onTap: () {
                          setState(() {
                            _selectedCategory = category.toLowerCase();
                          });
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _duasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _SearchMessage(
                    icon: Icons.cloud_off_rounded,
                    title: 'Unable to load recitations',
                    subtitle: 'Please try again.',
                    action: TextButton(
                      onPressed: () {
                        setState(() {
                          _duasFuture = _repository.getAllDuas();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  );
                }

                final allDuas = snapshot.data ?? [];
                final results = _filterResults(allDuas);

                if (results.isEmpty) {
                  return _SearchMessage(
                    icon: Icons.search_off_rounded,
                    title: _query.isEmpty
                        ? 'No recitations available'
                        : 'No matching recitations',
                    subtitle: _query.isEmpty
                        ? 'Try another category.'
                        : 'Try another word or search by meaning.',
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                      child: Row(
                        children: [
                          Text(
                            _query.isEmpty && _selectedCategory == 'all'
                                ? 'Explore recitations'
                                : '${results.length} results',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          if (_query.isNotEmpty || _selectedCategory != 'all')
                            TextButton(
                              onPressed: () {
                                _controller.clear();
                                setState(() {
                                  _query = '';
                                  _selectedCategory = 'all';
                                });
                              },
                              child: const Text('Reset'),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: results.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final dua = results[index];
                          final title = dua['title']?.toString() ?? 'Untitled';
                          final category = dua['category']?.toString() ?? '';
                          final arabic = dua['arabic']?.toString().trim() ?? '';
                          final translation =
                              dua['english_translation']?.toString().trim() ??
                              dua['malayalam_translation']?.toString().trim() ??
                              '';

                          return Material(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(18),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => _openDua(dua),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: colors.outline.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: amberPrimary.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: const Icon(
                                        Icons.menu_book_rounded,
                                        color: amberPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: colors.onSurface,
                                                ),
                                          ),
                                          if (category.isNotEmpty) ...[
                                            const SizedBox(height: 5),
                                            Text(
                                              _formatCategory(category),
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: amberPrimary,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ],
                                          if (arabic.isNotEmpty) ...[
                                            const SizedBox(height: 10),
                                            Text(
                                              arabic,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textDirection: TextDirection.rtl,
                                              textAlign: TextAlign.right,
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                    fontSize: 19,
                                                    height: 1.7,
                                                    color: colors.onSurface,
                                                  ),
                                            ),
                                          ],
                                          if (translation.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              translation,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    height: 1.5,
                                                    color:
                                                        colors.onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: colors.onSurfaceVariant.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
    required this.label,
    required this.selected,
    required this.amberPrimary,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color amberPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: amberPrimary.withValues(alpha: 0.18),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: selected ? amberPrimary : null,
        ),
        side: BorderSide(
          color: selected
              ? amberPrimary.withValues(alpha: 0.4)
              : Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _SearchMessage extends StatelessWidget {
  const _SearchMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 46,
              color: theme.iconTheme.color?.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            if (action != null) action!,
          ],
        ),
      ),
    );
  }
}
