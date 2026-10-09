import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/rushd_colors.dart';
import '../data/quran_providers.dart';
import '../domain/quran_ayah.dart';

class QuranHomeScreen extends ConsumerWidget {
  const QuranHomeScreen({super.key});

  void _openReader(
    BuildContext context,
    int surahNumber, [
    int ayahNumber = 1,
  ]) {
    context.push('/quran/read/$surahNumber?ayah=$ayahNumber');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(quranDataServiceProvider);
    final theme = Theme.of(context);
    final today = DateTime.now().day;
    final dailySurah = ((DateTime.now().dayOfYear - 1) % 114) + 1;
    const dailyAyah = 1;

    final dailyText = data.getVerse(dailySurah, dailyAyah);
    final dailyTranslation = data.getTranslation(dailySurah, dailyAyah);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Al-Quran',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Surahs'),
              Tab(text: 'Juz'),
              Tab(text: 'Bookmarks'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                children: [
                  _dailyAyahCard(
                    context,
                    surahName: data.getSurahName(dailySurah),
                    arabic: dailyText,
                    translation: dailyTranslation,
                    onTap: () => _openReader(context, dailySurah, dailyAyah),
                  ),
                  const SizedBox(height: 12),
                  _continueReadingCard(context, ref),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _surahList(context, data),
                  _juzList(context, data),
                  _bookmarkList(context, ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dailyAyahCard(
    BuildContext context, {
    required String surahName,
    required String arabic,
    required String translation,
    required VoidCallback onTap,
  }) {
    return Material(
      color: RushdColors.primaryDark,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white70, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "TODAY'S AYAH",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      letterSpacing: 1.3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_outward, color: Colors.white70, size: 18),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                arabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                translation,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, height: 1.5),
              ),
              const SizedBox(height: 10),
              Text(
                'Surah $surahName · 1:1',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _continueReadingCard(BuildContext context, WidgetRef ref) {
    final data = ref.watch(quranDataServiceProvider);
    final progressService = ref.watch(quranProgressServiceProvider);

    return FutureBuilder<QuranAyah?>(
      future: progressService.getProgress(),
      builder: (context, snapshot) {
        final progress = snapshot.data;
        final surahNumber = progress?.surahNumber ?? 1;
        final ayahNumber = progress?.ayahNumber ?? 1;

        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0x1A0F766E),
              child: Icon(Icons.menu_book_rounded, color: RushdColors.primary),
            ),
            title: Text(
              progress == null ? 'Start reading' : 'Continue reading',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${data.getSurahName(surahNumber)} · Ayah $ayahNumber',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _openReader(context, surahNumber, ayahNumber),
          ),
        );
      },
    );
  }

  Widget _surahList(BuildContext context, dynamic data) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: data.totalSurahs,
      itemBuilder: (context, index) {
        final number = index + 1;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            onTap: () => _openReader(context, number),
            leading: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: RushdColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                '$number',
                style: const TextStyle(
                  color: RushdColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              data.getSurahName(number),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${data.getSurahNameEnglish(number)} · '
              '${data.getVerseCount(number)} Ayahs · '
              '${data.getPlaceOfRevelation(number)}',
            ),
            trailing: Text(
              data.getSurahNameArabic(number),
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontSize: 23),
            ),
          ),
        );
      },
    );
  }

  Widget _juzList(BuildContext context, dynamic data) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: data.totalJuz,
      itemBuilder: (context, index) {
        final juzNumber = index + 1;
        final entries = data.getSurahsInJuz(juzNumber).entries.toList();

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: RushdColors.primary.withOpacity(0.1),
              child: Text(
                '$juzNumber',
                style: const TextStyle(
                  color: RushdColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              'Juz $juzNumber',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text('${entries.length} Surah sections'),
            children: entries.map((entry) {
              final surahNumber = entry.key;
              final startAyah = entry.value[0];
              final endAyah = entry.value[1];

              return ListTile(
                contentPadding: const EdgeInsets.only(left: 72, right: 16),
                title: Text(data.getSurahName(surahNumber)),
                subtitle: Text('Ayahs $startAyah–$endAyah'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _openReader(context, surahNumber, startAyah),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _bookmarkList(BuildContext context, WidgetRef ref) {
    final data = ref.watch(quranDataServiceProvider);
    final service = ref.watch(quranBookmarkServiceProvider);

    return FutureBuilder<List<QuranAyah>>(
      future: service.getBookmarks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Could not load bookmarks.'));
        }

        final bookmarks = snapshot.data ?? [];

        if (bookmarks.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border_rounded, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'No bookmarks yet',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Open a Surah and tap the heart icon to save an Ayah.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            final ayah = bookmarks[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.redAccent,
                ),
                title: Text(data.getSurahName(ayah.surahNumber)),
                subtitle: Text(
                  'Ayah ${ayah.ayahNumber} · '
                  '${data.getSurahNameEnglish(ayah.surahNumber)}',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () =>
                    _openReader(context, ayah.surahNumber, ayah.ayahNumber),
              ),
            );
          },
        );
      },
    );
  }
}

extension on DateTime {
  int get dayOfYear {
    final start = DateTime(year, 1, 1);
    return difference(start).inDays + 1;
  }
}
