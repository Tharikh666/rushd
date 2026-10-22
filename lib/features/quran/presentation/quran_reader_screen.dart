import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran/quran.dart' as quran;

import '../../../core/theme/rushd_colors.dart';
import '../data/quran_providers.dart';
import '../domain/quran_ayah.dart';
import '../data/quran_metadata.dart';

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
  final ScrollController _scrollController = ScrollController();

  int? _selectedAyah;
  int? _savedAyah;
  bool _loading = true;
  double _arabicFontSize = 31;
  bool _showTranslation = true;

  static const _ivory = Color(0xFFFFFDF2);
  static const _emerald = Color(0xFF007967);
  static const _deepEmerald = Color(0xFF00564B);
  static const _gold = Color(0xFFD6B85A);

  @override
  void initState() {
    super.initState();
    _selectedAyah = widget.initialAyah;
    _loadLocalState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalState() async {
    try {
      final bookmarks = await ref
          .read(quranBookmarkServiceProvider)
          .getBookmarks();
      final progress = await ref
          .read(quranProgressServiceProvider)
          .getProgress();

      if (!mounted) return;

      setState(() {
        _bookmarkedAyahs.addAll(
          bookmarks
              .where((a) => a.surahNumber == widget.surahNumber)
              .map((a) => a.ayahNumber),
        );
        _savedAyah = progress?.surahNumber == widget.surahNumber
            ? progress?.ayahNumber
            : null;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectAyah(int ayahNumber) async {
    final data = ref.read(quranDataServiceProvider);
    final ayah = data.getAyah(widget.surahNumber, ayahNumber);

    setState(() => _selectedAyah = ayahNumber);

    await ref.read(quranProgressServiceProvider).saveProgress(ayah);

    if (!mounted) return;
    setState(() => _savedAyah = ayahNumber);
  }

  Future<void> _toggleBookmark(int ayahNumber) async {
    final data = ref.read(quranDataServiceProvider);
    final ayah = data.getAyah(widget.surahNumber, ayahNumber);

    final saved = await ref
        .read(quranBookmarkServiceProvider)
        .toggleBookmark(ayah);

    if (!mounted) return;

    setState(() {
      if (saved) {
        _bookmarkedAyahs.add(ayahNumber);
      } else {
        _bookmarkedAyahs.remove(ayahNumber);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(saved ? 'Ayah bookmarked' : 'Bookmark removed'),
        duration: const Duration(milliseconds: 1100),
      ),
    );
  }

  void _openVerse(int ayahNumber) {
    context.push('/quran/verse/${widget.surahNumber}/$ayahNumber');
  }

  void _showReaderSettings() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).cardColor,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reading preferences',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Arabic text size'),
                    Row(
                      children: [
                        const Icon(Icons.text_fields_rounded),
                        Expanded(
                          child: Slider(
                            min: 24,
                            max: 44,
                            divisions: 10,
                            value: _arabicFontSize,
                            activeColor: RushdColors.primary,
                            onChanged: (value) {
                              setState(() => _arabicFontSize = value);
                              setSheetState(() {});
                            },
                          ),
                        ),
                        Text('${_arabicFontSize.round()}'),
                      ],
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Show translation'),
                      value: _showTranslation,
                      onChanged: (value) {
                        setState(() => _showTranslation = value);
                        setSheetState(() {});
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text('Translation language'),
                    const SizedBox(height: 8),
                    SegmentedButton<quran.Translation>(
                      segments: const [
                        ButtonSegment(
                          value: quran.Translation.enSaheeh,
                          label: Text('English'),
                        ),
                        ButtonSegment(
                          value: quran.Translation.mlAbdulHameed,
                          label: Text('Malayalam'),
                        ),
                      ],
                      selected: {_translation},
                      onSelectionChanged: (values) {
                        setState(() => _translation = values.first);
                        setSheetState(() {});
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(quranDataServiceProvider);
    final surah = widget.surahNumber.clamp(1, 114);
    final count = data.getVerseCount(surah);
    final start = widget.initialAyah.clamp(1, count);
    final dark = Theme.of(context).brightness == Brightness.dark;

    final englishName = QuranMetadata.englishMeanings[surah];

    return Scaffold(
      backgroundColor: dark ? RushdColors.darkBackground : _ivory,
      appBar: AppBar(
        backgroundColor: dark ? RushdColors.darkBackground : _ivory,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        centerTitle: true,
        title: Text(
          englishName!.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            letterSpacing: 2.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Reading settings',
            onPressed: _showReaderSettings,
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 42),
              itemCount: count - start + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _surahIntroduction(data, surah, count, dark);
                }

                final ayahNumber = start + index - 1;

                return _ayahBlock(
                  data: data,
                  surah: surah,
                  ayahNumber: ayahNumber,
                  dark: dark,
                );
              },
            ),
    );
  }

  Widget _surahIntroduction(dynamic data, int surah, int count, bool dark) {
    final place = data.getPlaceOfRevelation(surah);
    final name = QuranMetadata.englishMeanings[surah];

    return Container(
      margin: const EdgeInsets.only(bottom: 36),
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_emerald, _deepEmerald],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _gold.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: _deepEmerald.withOpacity(0.14),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            name!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Cormorant Garamond',
              fontSize: 29,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            data.getSurahName(surah),
            style: const TextStyle(color: Color(0xFFD7F0E7), fontSize: 16),
          ),
          const SizedBox(height: 22),
          Text(
            data.getSurahNameArabic(surah),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _surahMeaning(surah),
            style: const TextStyle(
              color: Color(0xFFD7F0E7),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _surahMeaningMalayalam(surah),
            style: const TextStyle(color: Color(0xFFD7F0E7), fontSize: 15),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              _headerPill(Icons.location_on_outlined, place),
              _headerPill(Icons.menu_book_outlined, '$count Ayahs'),
            ],
          ),
        ],
      ),
    );
  }

  String _surahMeaning(int surah) {
    // Use the English meaning where available in the Quran package.
    // The WAHDA repository provides Malayalam meanings for all Surahs.
    return QuranMetadata.malayalamMeanings[surah] ?? '';
  }

  String _surahMeaningMalayalam(int surah) {
    return QuranMetadata.malayalamNames[surah] ?? '';
  }

  Widget _headerPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withOpacity(0.04),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: const Color(0xFFD7F0E7)),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ayahBlock({
    required dynamic data,
    required int surah,
    required int ayahNumber,
    required bool dark,
  }) {
    final selected = _selectedAyah == ayahNumber;
    final bookmarked = _bookmarkedAyahs.contains(ayahNumber);
    final saved = _savedAyah == ayahNumber;
    final arabic = data.getVerse(surah, ayahNumber);
    final translation = data.getTranslation(
      surah,
      ayahNumber,
      translation: _translation,
    );

    return GestureDetector(
      onTap: () => _selectAyah(ayahNumber),
      onDoubleTap: () => _openVerse(ayahNumber),
      onLongPress: () => _toggleBookmark(ayahNumber),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 16 : 5,
          vertical: selected ? 20 : 14,
        ),
        decoration: BoxDecoration(
          color: selected
              ? (dark ? const Color(0xFF123A32) : const Color(0xFFF0F5EC))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: selected
              ? Border.all(
                  color: dark
                      ? const Color(0xFF24584C)
                      : const Color(0xFFE5EBDD),
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (selected || bookmarked || saved)
              Row(
                children: [
                  Text(
                    '${surah.toString().padLeft(3, '0')}:${ayahNumber.toString().padLeft(3, '0')}',
                    style: TextStyle(
                      color: selected ? _emerald : Colors.grey,
                      fontSize: 11,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  if (saved)
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: _emerald,
                    ),
                  if (bookmarked)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.bookmark_rounded,
                        size: 18,
                        color: _gold,
                      ),
                    ),
                ],
              ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: arabic),
                  const TextSpan(text: '  '),
                  TextSpan(
                    text: _ayahMarker(ayahNumber),
                    style: TextStyle(
                      color: selected ? _emerald : const Color(0xFF827E6E),
                      fontSize: _arabicFontSize * 0.75,
                    ),
                  ),
                ],
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: _arabicFontSize,
                height: 2.25,
                color: selected
                    ? (dark ? const Color(0xFF80D8C2) : _emerald)
                    : (dark
                          ? RushdColors.darkTextPrimary
                          : const Color(0xFF28271F)),
              ),
            ),
            if (selected && _showTranslation) ...[
              const SizedBox(height: 12),
              Divider(
                color: selected ? _emerald.withOpacity(0.2) : Colors.black12,
              ),
              const SizedBox(height: 8),
              Text(
                translation,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.8,
                  color: dark
                      ? RushdColors.darkTextSecondary
                      : const Color(0xFF60665E),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    _translation == quran.Translation.enSaheeh
                        ? 'ENGLISH TRANSLATION'
                        : 'MALAYALAM TRANSLATION',
                    style: const TextStyle(
                      color: _emerald,
                      fontSize: 9,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _openVerse(ayahNumber),
                    child: const Text('Details'),
                  ),
                ],
              ),
            ],
            if (selected)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _toggleBookmark(ayahNumber),
                  icon: Icon(
                    bookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 18,
                  ),
                  label: Text(bookmarked ? 'Bookmarked' : 'Bookmark Ayah'),
                  style: TextButton.styleFrom(foregroundColor: _emerald),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _ayahMarker(int number) {
    // Decorative marker matching the circular Ayah symbols in WAHDA.
    return '۞${_arabicNumber(number)}';
  }

  String _arabicNumber(int number) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) {
      return digits[int.parse(digit)];
    }).join();
  }
}
