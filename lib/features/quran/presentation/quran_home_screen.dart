import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/rushd_colors.dart';
import '../data/quran_providers.dart';
import '../domain/quran_ayah.dart';
import '../data/quran_metadata.dart';

class QuranHomeScreen extends ConsumerStatefulWidget {
  const QuranHomeScreen({super.key});

  @override
  ConsumerState<QuranHomeScreen> createState() => _QuranHomeScreenState();
}

class _QuranHomeScreenState extends ConsumerState<QuranHomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  );
  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  bool _showGestures = false;
  late Future<List<QuranAyah>> _bookmarksFuture;
  late Future<QuranAyah?> _progressFuture;

  @override
  void initState() {
    super.initState();
    _tabController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
    _refreshLocalData();
  }

  void _refreshLocalData() {
    _bookmarksFuture = ref.read(quranBookmarkServiceProvider).getBookmarks();
    _progressFuture = ref.read(quranProgressServiceProvider).getProgress();
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  String _arabicNumber(int number) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) {
      return digits[int.parse(digit)];
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(quranDataServiceProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: _tabs(colors, dark),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSurahsTab(data, colors, dark),
                  _buildJuzTab(data, colors, dark),
                  _buildBookmarksTab(data, colors, dark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back_rounded, color: colors.onSurface),
          ),
          const Spacer(),
          Text(
            'Q U R A N',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.2,
              color: colors.onSurface,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('•', style: TextStyle(color: Color(0xFF007967))),
          ),
          Text(
            'القرآن الكريم',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _tabs(ColorScheme colors, bool dark) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: dark
            ? colors.surfaceContainerHighest.withValues(alpha: 0.5)
            : const Color(0xFFEEF4F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline.withValues(alpha: 0.15)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: dark ? colors.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFF007967),
        unselectedLabelColor: colors.onSurfaceVariant,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 13.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
        ),
        tabs: const [
          Tab(text: 'Surahs'),
          Tab(text: 'Juz'),
          Tab(text: 'Bookmarks'),
        ],
      ),
    );
  }

  Widget _buildSurahsTab(dynamic data, ColorScheme colors, bool dark) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              children: [
                _gestureCard(colors, dark),
                const SizedBox(height: 14),
                _resumeCard(data, colors, dark),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: _searchBox(colors, dark),
          ),
        ),
        SliverToBoxAdapter(child: _quickSearchChips(data, colors, dark)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final number = index + 1;
              final name = data.getSurahName(number);
              final english = QuranMetadata.englishMeanings[number];

              if (_search.isNotEmpty &&
                  !name.toLowerCase().contains(_search.toLowerCase()) &&
                  !english!.toLowerCase().contains(_search.toLowerCase()) &&
                  !number.toString().contains(_search)) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _surahCard(data, number, colors, dark),
              );
            }, childCount: data.totalSurahs),
          ),
        ),
      ],
    );
  }

  Widget _buildJuzTab(dynamic data, ColorScheme colors, bool dark) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              children: [
                _gestureCard(colors, dark),
                const SizedBox(height: 14),
                _resumeCard(data, colors, dark),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _juzCard(data, index + 1, colors, dark),
              ),
              childCount: data.totalJuz,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookmarksTab(dynamic data, ColorScheme colors, bool dark) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              children: [
                _gestureCard(colors, dark),
                const SizedBox(height: 14),
                _resumeCard(data, colors, dark),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: FutureBuilder<List<QuranAyah>>(
            future: _bookmarksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final bookmarks = snapshot.data ?? [];

              if (bookmarks.isEmpty) {
                return _emptyBookmarks(colors);
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
                child: Column(
                  children: bookmarks.map((ayah) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _bookmarkCard(data, ayah, colors, dark),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _gestureCard(ColorScheme colors, bool dark) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF006341), Color(0xFF004B35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004B35).withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(18, 6, 14, 6),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFFE5C94E),
                size: 20,
              ),
            ),
            title: const Text(
              'READING GESTURES GUIDE',
              style: TextStyle(
                color: Color(0xFFA3D2C2),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            subtitle: const Padding(
              padding: EdgeInsets.only(top: 3),
              child: Text(
                'Interactive Ayah Controls',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            trailing: Icon(
              _showGestures
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFFA3D2C2),
            ),
            onTap: () => setState(() => _showGestures = !_showGestures),
          ),
          if (_showGestures)
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                children: [
                  _GestureRow(
                    icon: Icons.touch_app_rounded,
                    title: 'Single Tap',
                    description:
                        'Highlights an Ayah and saves your reading position.',
                  ),
                  Divider(color: Colors.white12, height: 20),
                  _GestureRow(
                    icon: Icons.ads_click_rounded,
                    title: 'Double Tap',
                    description:
                        'Opens verse detail screen with English & Malayalam translations.',
                  ),
                  Divider(color: Colors.white12, height: 20),
                  _GestureRow(
                    icon: Icons.bookmark_add_rounded,
                    title: 'Long Press',
                    description:
                        'Adds or removes the Ayah from your saved bookmarks sanctuary.',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _resumeCard(dynamic data, ColorScheme colors, bool dark) {
    return FutureBuilder<QuranAyah?>(
      future: _progressFuture,
      builder: (context, snapshot) {
        final progress = snapshot.data;
        final surah = progress?.surahNumber ?? 1;
        final ayah = progress?.ayahNumber ?? 1;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => _openReader(surah, ayah),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF007967), Color(0xFF00564B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF50D6C4).withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF007967).withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/worship_icons/quran.svg',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFC7A96B),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'RESUME READING',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Surah ${QuranMetadata.englishMeanings[surah]}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Continue from Ayah $ayah',
                          style: const TextStyle(
                            color: Color(0xFFB9F0E6),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _searchBox(ColorScheme colors, bool dark) {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _search = value.trim()),
      decoration: InputDecoration(
        hintText: 'Search Surah by name or number...',
        hintStyle: TextStyle(
          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
          fontSize: 13.5,
        ),
        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF007967)),
        suffixIcon: _search.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _search = '');
                },
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
        filled: true,
        fillColor: themeCardColor(colors, dark),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFF007967), width: 1.5),
        ),
      ),
    );
  }

  Color themeCardColor(ColorScheme colors, bool dark) {
    return dark
        ? colors.surfaceContainerHighest.withValues(alpha: 0.6)
        : Colors.white;
  }

  Widget _quickSearchChips(dynamic data, ColorScheme colors, bool dark) {
    const suggestions = {
      "Ya'Sin": 36,
      'Ar-Rahman': 55,
      'Al-Mulk': 67,
      'Al-Kahf': 18,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: suggestions.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(entry.key),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
              backgroundColor: themeCardColor(colors, dark),
              elevation: 0,
              pressElevation: 0,
              side: BorderSide(color: colors.outline.withValues(alpha: 0.2)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onPressed: () {
                _searchController.clear();
                setState(
                  () => _search = QuranMetadata.englishMeanings[entry.value]!,
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _surahCard(dynamic data, int number, ColorScheme colors, bool dark) {
    final name = QuranMetadata.englishMeanings[number];
    final arabic = data.getSurahNameArabic(number);
    final count = data.getVerseCount(number);
    final place = data.getPlaceOfRevelation(number).toUpperCase();

    return Material(
      color: themeCardColor(colors, dark),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _openReader(number),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.outline.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF007967).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF007967).withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Color(0xFF007967),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Surah $name',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.getSurahName(number),
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$place · $count AYAH${count == 1 ? '' : 'S'}',
                      style: const TextStyle(
                        color: Color(0xFF007967),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                arabic,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _juzCard(dynamic data, int juz, ColorScheme colors, bool dark) {
    final sections = (data.getSurahsInJuz(juz) as Map).entries.toList();
    final first = sections.first;
    final surah = first.key as int;
    final startAyah = (first.value as List)[0] as int;
    final name = QuranMetadata.englishMeanings[surah];

    return Material(
      color: themeCardColor(colors, dark),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _openReader(surah, startAyah),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.outline.withValues(alpha: 0.15)),
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
                      value: juz / 30,
                      strokeWidth: 3.5,
                      backgroundColor: const Color(
                        0xFF007967,
                      ).withValues(alpha: 0.1),
                      color: const Color(0xFF007967),
                    ),
                  ),
                  Text(
                    '$juz',
                    style: const TextStyle(
                      color: Color(0xFF007967),
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'JUZ SECTION',
                      style: TextStyle(
                        color: Color(0xFF007967),
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Starts with Surah $name',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Begins at Ayah $startAyah',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Arabic Stamp / Seal Column
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF007967).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF007967).withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'الجزء',
                      style: TextStyle(
                        color: Color(0xFF007967),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _arabicNumber(juz),
                      style: const TextStyle(
                        color: Color(0xFF007967),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
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

  Widget _bookmarkCard(
    dynamic data,
    QuranAyah ayah,
    ColorScheme colors,
    bool dark,
  ) {
    return Dismissible(
      key: ValueKey(ayah.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(22),
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
      child: Material(
        color: themeCardColor(colors, dark),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _openVerse(ayah.surahNumber, ayah.ayahNumber),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colors.outline.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF007967).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.bookmark_rounded,
                    color: Color(0xFF007967),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Surah ${QuranMetadata.englishMeanings[ayah.surahNumber]}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Ayah ${ayah.ayahNumber}',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyBookmarks(ColorScheme colors) {
    return SizedBox(
      height: 380,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF007967).withValues(alpha: 0.08),
                  border: Border.all(
                    color: const Color(0xFF007967).withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  Icons.bookmark_rounded,
                  size: 40,
                  color: Color(0xFF007967),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your Sanctuary is Empty',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Create your personal reference collection. Long press any '
                'Ayah while reading the Quran to save it here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.5,
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
        Icon(icon, color: const Color(0xFF50D6C4), size: 22),
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
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFFB6D8CB),
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
