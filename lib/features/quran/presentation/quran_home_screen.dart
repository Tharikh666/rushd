import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/rushd_colors.dart';
import '../data/quran_providers.dart';
import '../domain/quran_ayah.dart';
import '../data/quran_metadata.dart';

enum _QuranTab { surahs, juz, bookmarks }

class QuranHomeScreen extends ConsumerStatefulWidget {
  const QuranHomeScreen({super.key});

  @override
  ConsumerState<QuranHomeScreen> createState() => _QuranHomeScreenState();
}

class _QuranHomeScreenState extends ConsumerState<QuranHomeScreen> {
  _QuranTab _tab = _QuranTab.surahs;
  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  bool _showGestures = false;
  late Future<List<QuranAyah>> _bookmarksFuture;
  late Future<QuranAyah?> _progressFuture;

  @override
  void initState() {
    super.initState();
    _refreshLocalData();
  }

  void _refreshLocalData() {
    _bookmarksFuture = ref.read(quranBookmarkServiceProvider).getBookmarks();
    _progressFuture = ref.read(quranProgressServiceProvider).getProgress();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openReader(int surah, [int ayah = 1]) {
    context.push('/quran/read/$surah?ayah=$ayah').then((_) {
      if (!mounted) return;
      setState(_refreshLocalData);
    });
  }

  void _openVerse(int surah, int ayah) {
    context.push('/quran/verse/$surah/$ayah').then((_) {
      if (!mounted) return;
      setState(_refreshLocalData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(quranDataServiceProvider);
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark
          ? RushdColors.darkBackground
          : const Color(0xFFFAFAF8),
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: _tabs(),
            ),
            Expanded(
              child: CustomScrollView(
                key: PageStorageKey(_tab),
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                      child: Column(
                        children: [
                          _gestureCard(),
                          const SizedBox(height: 18),
                          _resumeCard(data),
                        ],
                      ),
                    ),
                  ),
                  if (_tab == _QuranTab.surahs) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 14),
                        child: _searchBox(),
                      ),
                    ),
                    SliverToBoxAdapter(child: _quickSearchChips(data)),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final number = index + 1;
                          final name = data.getSurahName(number);
                          final english = QuranMetadata.englishMeanings[number];

                          if (_search.isNotEmpty &&
                              !name.toLowerCase().contains(
                                _search.toLowerCase(),
                              ) &&
                              !english!.toLowerCase().contains(
                                _search.toLowerCase(),
                              ) &&
                              !number.toString().contains(_search)) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _surahCard(data, number),
                          );
                        }, childCount: data.totalSurahs),
                      ),
                    ),
                  ] else if (_tab == _QuranTab.juz) ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _juzCard(data, index + 1),
                          ),
                          childCount: data.totalJuz,
                        ),
                      ),
                    ),
                  ] else ...[
                    SliverToBoxAdapter(
                      child: FutureBuilder<List<QuranAyah>>(
                        future: _bookmarksFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(40),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final bookmarks = snapshot.data ?? [];

                          if (bookmarks.isEmpty) {
                            return _emptyBookmarks();
                          }

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                            child: Column(
                              children: bookmarks.map((ayah) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _bookmarkCard(data, ayah),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return SizedBox(
      height: 62,
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const Spacer(),
          const Text(
            'Q U R A N',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('•'),
          ),
          const Text('القرآن الكريم', style: TextStyle(fontSize: 19)),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _tabs() {
    return Container(
      height: 64,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FA),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8ECF4)),
      ),
      child: Row(
        children: [
          _tabItem('Surahs', _QuranTab.surahs),
          _tabItem('Juz', _QuranTab.juz),
          _tabItem('Bookmarks', _QuranTab.bookmarks),
        ],
      ),
    );
  }

  Widget _tabItem(String label, _QuranTab value) {
    final selected = _tab == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(17),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? const Color(0xFF172033)
                  : const Color(0xFF9298A5),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _gestureCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF006341), Color(0xFF00583B)],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(18, 8, 14, 8),
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFFE5C94E),
              ),
            ),
            title: const Text(
              'R E A D I N G   C O N T R O L S',
              style: TextStyle(
                color: Color(0xFF85B8A4),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(
                'Interactive Ayah Gestures',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            trailing: Icon(
              _showGestures
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: const Color(0xFF9AC5B5),
            ),
            onTap: () => setState(() => _showGestures = !_showGestures),
          ),
          if (_showGestures)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
              child: Column(
                children: const [
                  _GestureRow(
                    icon: Icons.touch_app_rounded,
                    title: 'Single Tap',
                    description:
                        'Highlights an Ayah and saves your reading position.',
                  ),
                  Divider(color: Colors.white12, height: 22),
                  _GestureRow(
                    icon: Icons.ads_click_rounded,
                    title: 'Double Tap',
                    description:
                        'Opens verse details with English and Malayalam translations.',
                  ),
                  Divider(color: Colors.white12, height: 22),
                  _GestureRow(
                    icon: Icons.bookmark_add_rounded,
                    title: 'Long Press',
                    description:
                        'Adds or removes the Ayah from your bookmarks.',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _resumeCard(dynamic data) {
    return FutureBuilder<QuranAyah?>(
      future: _progressFuture,
      builder: (context, snapshot) {
        final progress = snapshot.data;
        final surah = progress?.surahNumber ?? 1;
        final ayah = progress?.ayahNumber ?? 1;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(27),
            onTap: () => _openReader(surah, ayah),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF078D80), Color(0xFF00BBA8)],
                ),
                borderRadius: BorderRadius.circular(27),
                border: Border.all(color: const Color(0xFF50D6C4)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00A895).withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Text(
                      '۞',
                      style: TextStyle(color: Colors.white, fontSize: 38),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'RESUME READING',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          QuranMetadata.englishMeanings[surah]!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Resume from Ayah $ayah',
                          style: const TextStyle(
                            color: Color(0xFFB9F0E6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _searchBox() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _search = value.trim()),
      decoration: InputDecoration(
        hintText: 'Search Surah...',
        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF8DBBB4)),
        suffixIcon: _search.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _search = '');
                },
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(35),
          borderSide: const BorderSide(color: Color(0xFFB9D8D2), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(35),
          borderSide: const BorderSide(color: RushdColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _quickSearchChips(dynamic data) {
    const suggestions = {
      "Ya'Sin": 36,
      'Ar-Rahman': 55,
      'Al-Mulk': 67,
      'Al-Kahf': 18,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: suggestions.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(right: 9),
            child: ActionChip(
              label: Text(entry.key),
              backgroundColor: Theme.of(context).cardColor,
              side: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.5),
              ),
              onPressed: () {
                _searchController.clear();
                setState(() => _search = QuranMetadata.englishMeanings[entry.value]!);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _surahCard(dynamic data, int number) {
    final theme = Theme.of(context);
    final name = QuranMetadata.englishMeanings[number];
    final arabic = data.getSurahNameArabic(number);
    final count = data.getVerseCount(number);
    final place = data.getPlaceOfRevelation(number).toUpperCase();

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(27),
      child: InkWell(
        borderRadius: BorderRadius.circular(27),
        onTap: () => _openReader(number),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(27),
            border: Border.all(color: theme.dividerColor.withOpacity(0.45)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.025),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9F7),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: const Color(0xFFD8ECE8)),
                ),
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: RushdColors.primary,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Surah $name',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF63778B),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      data.getSurahName(number),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '$place · $count AYAH${count == 1 ? '' : 'S'}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.5,
                        ),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                arabic,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontSize: 27, color: Color(0xFF303030)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _juzCard(dynamic data, int juz) {
    final sections = (data.getSurahsInJuz(juz) as Map).entries.toList();
    final first = sections.first;
    final surah = first.key as int;
    final startAyah = (first.value as List)[0] as int;
    final name = QuranMetadata.englishMeanings[surah];

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () => _openReader(surah, startAyah),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.45),
            ),
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      value: 0.25 + (juz / 30) * 0.65,
                      strokeWidth: 3,
                      backgroundColor: const Color(0xFFE4F2EF),
                      color: const Color(0xFF80C2B6),
                    ),
                  ),
                  Text(
                    '$juz',
                    style: const TextStyle(
                      color: RushdColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 17),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JUZ $juz',
                      style: const TextStyle(
                        color: RushdColors.primary,
                        fontSize: 12,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF8F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        name!,
                        style: const TextStyle(
                          color: RushdColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Starts at Ayah $startAyah',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    'الجزء $juz',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFCFD8D5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bookmarkCard(dynamic data, QuranAyah ayah) {
    return Dismissible(
      key: ValueKey(ayah.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Remove bookmark?'),
                content: const Text(
                  'This Ayah will be removed from your bookmarks.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Remove'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) async {
        await ref.read(quranBookmarkServiceProvider).toggleBookmark(ayah);
        if (mounted) setState(_refreshLocalData);
      },
      child: _surahCardForBookmark(data, ayah),
    );
  }

  Widget _surahCardForBookmark(dynamic data, QuranAyah ayah) {
    return ListTile(
      contentPadding: const EdgeInsets.all(14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      tileColor: Theme.of(context).cardColor,
      leading: const Icon(Icons.bookmark_rounded, color: RushdColors.primary),
      title: Text(QuranMetadata.englishMeanings[ayah.ayahNumber]!),
      subtitle: Text('Ayah ${ayah.ayahNumber}'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _openVerse(ayah.surahNumber, ayah.ayahNumber),
    );
  }

  Widget _emptyBookmarks() {
    return SizedBox(
      height: 390,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEDF7F5),
                  border: Border.all(color: const Color(0xFFD9EBE7)),
                ),
                child: const Icon(
                  Icons.bookmark_rounded,
                  size: 43,
                  color: Color(0xFF55A99C),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Your Sanctuary is Empty',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(
                'Create a personal reference collection. Long press any '
                'Ayah while reading the Quran to save it here.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.55),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GestureRow extends StatelessWidget {
  const _GestureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF8CD1B6), size: 23),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(color: Color(0xFFB6D8CB), height: 1.45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
