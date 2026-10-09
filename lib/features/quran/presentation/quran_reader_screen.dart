import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran/quran.dart' as quran;

import '../../../core/theme/rushd_colors.dart';
import '../data/quran_providers.dart';
import '../domain/quran_ayah.dart';

class QuranReaderScreen extends ConsumerStatefulWidget {
  const QuranReaderScreen({
    super.key,
    required this.surahNumber,
    this.initialAyah = 1,
  });

  final int surahNumber;
  final int initialAyah;

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  quran.Translation _translation = quran.Translation.enSaheeh;
  final Set<int> _bookmarkedAyahs = {};
  int? _savedAyah;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalState();
  }

  Future<void> _loadLocalState() async {
    final bookmarkService = ref.read(quranBookmarkServiceProvider);
    final progressService = ref.read(quranProgressServiceProvider);

    final bookmarks = await bookmarkService.getBookmarks();
    final progress = await progressService.getProgress();

    if (!mounted) return;

    setState(() {
      _bookmarkedAyahs.addAll(
        bookmarks
            .where((a) => a.surahNumber == widget.surahNumber)
            .map((a) => a.ayahNumber),
      );
      _savedAyah = progress?.ayahNumber;
      _loading = false;
    });
  }

  Future<void> _toggleBookmark(int ayahNumber) async {
    final data = ref.read(quranDataServiceProvider);
    final service = ref.read(quranBookmarkServiceProvider);

    final ayah = data.getAyah(widget.surahNumber, ayahNumber);
    final isSaved = await service.toggleBookmark(ayah);

    if (!mounted) return;

    setState(() {
      if (isSaved) {
        _bookmarkedAyahs.add(ayahNumber);
      } else {
        _bookmarkedAyahs.remove(ayahNumber);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isSaved ? 'Ayah bookmarked' : 'Bookmark removed'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _savePosition(int ayahNumber) async {
    final data = ref.read(quranDataServiceProvider);
    final ayah = data.getAyah(widget.surahNumber, ayahNumber);

    await ref.read(quranProgressServiceProvider).saveProgress(ayah);

    if (!mounted) return;

    setState(() => _savedAyah = ayahNumber);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reading position saved'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(quranDataServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surahNumber = widget.surahNumber;
    final verseCount = data.getVerseCount(surahNumber);
    final startAyah = widget.initialAyah.clamp(1, verseCount).toInt();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.getSurahName(surahNumber)),
            Text(
              '${data.getPlaceOfRevelation(surahNumber)} • $verseCount Ayahs',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        actions: [
          PopupMenuButton<quran.Translation>(
            tooltip: 'Choose translation',
            icon: const Icon(Icons.translate_rounded),
            initialValue: _translation,
            onSelected: (value) => setState(() => _translation = value),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: quran.Translation.enSaheeh,
                child: Text('English'),
              ),
              PopupMenuItem(
                value: quran.Translation.mlAbdulHameed,
                child: Text('Malayalam'),
              ),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: verseCount - startAyah + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildSurahHeader(context, data, surahNumber);
                }

                final ayahNumber = startAyah + index - 1;
                final ayah = QuranAyah(
                  surahNumber: surahNumber,
                  ayahNumber: ayahNumber,
                  arabicText: data.getVerse(surahNumber, ayahNumber),
                );

                final translation = data.getTranslation(
                  surahNumber,
                  ayahNumber,
                  translation: _translation,
                );

                final bookmarked = _bookmarkedAyahs.contains(ayahNumber);
                final isSavedPosition = _savedAyah == ayahNumber;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => _savePosition(ayahNumber),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: RushdColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Text(
                                  '$ayahNumber',
                                  style: const TextStyle(
                                    color: RushdColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                tooltip: 'Save reading position',
                                onPressed: () => _savePosition(ayahNumber),
                                icon: Icon(
                                  isSavedPosition
                                      ? Icons.bookmark_added_rounded
                                      : Icons.bookmark_add_outlined,
                                  color: isSavedPosition
                                      ? RushdColors.primary
                                      : null,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Bookmark Ayah',
                                onPressed: () => _toggleBookmark(ayahNumber),
                                icon: Icon(
                                  bookmarked
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: bookmarked ? Colors.redAccent : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            ayah.arabicText,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 29,
                              height: 2,
                              color: isDark
                                  ? RushdColors.darkTextPrimary
                                  : RushdColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Divider(color: Theme.of(context).dividerColor),
                          const SizedBox(height: 10),
                          Text(
                            translation,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.7,
                              color: isDark
                                  ? RushdColors.darkTextSecondary
                                  : RushdColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Juz ${data.getJuzNumber(surahNumber, ayahNumber)}',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSurahHeader(
    BuildContext context,
    dynamic data,
    int surahNumber,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [RushdColors.primaryDark, RushdColors.primary],
        ),
      ),
      child: Column(
        children: [
          Text(
            data.getSurahNameArabic(surahNumber),
            textDirection: TextDirection.rtl,
            style: const TextStyle(color: Colors.white, fontSize: 31),
          ),
          const SizedBox(height: 10),
          Text(
            data.getSurahNameEnglish(surahNumber),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          if (surahNumber != 1 && surahNumber != 9)
            const Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              textDirection: TextDirection.rtl,
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          const SizedBox(height: 8),
          const Text(
            'Tap an Ayah to save your reading position.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
