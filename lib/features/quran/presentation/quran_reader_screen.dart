import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran/quran.dart' as quran;

import '../data/quran_metadata.dart';
import '../data/quran_providers.dart';

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
  double _arabicFontSize = 32;

  // Defaults to false as requested
  bool _showTranslation = false;

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
        content: Text(
          saved ? 'Ayah saved to bookmarks sanctuary' : 'Bookmark removed',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  void _openVerse(int ayahNumber) {
    context.push('/quran/verse/${widget.surahNumber}/$ayahNumber');
  }

  void _navigateToSurah(int nextSurahNumber) {
    // Fixed route path matching your GoRouter setup (/quran/read/:surah)
    context.pushReplacement('/quran/read/$nextSurahNumber');
  }

  void _showReaderSettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context);
            final colors = theme.colorScheme;
            final dark = theme.brightness == Brightness.dark;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  8,
                  24,
                  MediaQuery.of(context).viewInsets.bottom + 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _emerald.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: _emerald,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reading Preferences',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Customize display & text settings',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Arabic Font Size Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ARABIC FONT SIZE',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: colors.onSurfaceVariant.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _emerald.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_arabicFontSize.round()} px',
                            style: const TextStyle(
                              color: _emerald,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: dark
                            ? colors.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        )
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors.outline.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.text_decrease_rounded,
                              size: 18,
                              color: _emerald,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              min: 24,
                              max: 46,
                              divisions: 11,
                              value: _arabicFontSize,
                              activeColor: _emerald,
                              onChanged: (value) {
                                setState(() => _arabicFontSize = value);
                                setSheetState(() {});
                              },
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.text_increase_rounded,
                              size: 18,
                              color: _emerald,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Translation Display Toggle
                    Text(
                      'TRANSLATION SETTINGS',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: dark
                            ? colors.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        )
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors.outline.withValues(alpha: 0.15),
                        ),
                      ),
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        title: Text(
                          'Show Translation',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          'Display translated text under selected verses',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        value: _showTranslation,
                        activeColor: _emerald,
                        onChanged: (value) {
                          setState(() => _showTranslation = value);
                          setSheetState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Conditional Language Selector (Enabled only when _showTranslation is true)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _showTranslation ? 1.0 : 0.45,
                      child: IgnorePointer(
                        ignoring: !_showTranslation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TRANSLATION LANGUAGE',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: colors.onSurfaceVariant.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: SegmentedButton<quran.Translation>(
                                style: ButtonStyle(
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                                segments: const [
                                  ButtonSegment(
                                    value: quran.Translation.enSaheeh,
                                    label: Text('English (Saheeh)'),
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
                            ),
                          ],
                        ),
                      ),
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
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    final englishName = QuranMetadata.englishMeanings[surah];

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_rounded, color: colors.onSurface),
        ),
        centerTitle: true,
        title: Text(
          (englishName ?? '').toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            letterSpacing: 2.2,
            fontWeight: FontWeight.w900,
            color: colors.onSurface,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Reading settings',
            onPressed: _showReaderSettings,
            icon: Icon(Icons.tune_rounded, color: colors.onSurface),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 48),
        itemCount: count - start + 3,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _surahIntroduction(data, surah, count, dark);
          }

          if (index == count - start + 2) {
            return _buildNextSurahButton(data, surah);
          }

          final ayahNumber = start + index - 1;

          return _ayahBlock(
            data: data,
            surah: surah,
            ayahNumber: ayahNumber,
            colors: colors,
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
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_emerald, _deepEmerald],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _gold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: _deepEmerald.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            name ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.getSurahName(surah),
            style: const TextStyle(color: Color(0xFFD7F0E7), fontSize: 15.5),
          ),
          const SizedBox(height: 20),
          Text(
            data.getSurahNameArabic(surah),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _surahMeaning(surah),
            style: const TextStyle(
              color: Color(0xFFD7F0E7),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _surahMeaningMalayalam(surah),
            style: const TextStyle(color: Color(0xFFD7F0E7), fontSize: 14.5),
          ),
          const SizedBox(height: 22),
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
    return QuranMetadata.malayalamMeanings[surah] ?? '';
  }

  String _surahMeaningMalayalam(int surah) {
    return QuranMetadata.malayalamNames[surah] ?? '';
  }

  Widget _headerPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withValues(alpha: 0.08),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFD7F0E7)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
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
    required ColorScheme colors,
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
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 16 : 8,
          vertical: selected ? 18 : 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? (dark ? const Color(0xFF103A31) : const Color(0xFFEAF5F2))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: selected
              ? Border.all(
            color: dark
                ? const Color(0xFF226E5D)
                : const Color(0xFFB0DFD5),
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
                      color: selected ? _emerald : colors.onSurfaceVariant,
                      fontSize: 11,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  if (saved)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: _emerald,
                      ),
                    ),
                  if (bookmarked)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.bookmark_rounded,
                        size: 16,
                        color: _gold,
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: arabic),
                  const TextSpan(text: '  '),
                  TextSpan(
                    text: _ayahMarker(ayahNumber),
                    style: TextStyle(
                      color: selected ? _emerald : colors.onSurfaceVariant,
                      fontSize: _arabicFontSize * 0.75,
                    ),
                  ),
                ],
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: _arabicFontSize,
                height: 2.2,
                color: selected
                    ? (dark ? const Color(0xFF80D8C2) : _emerald)
                    : colors.onSurface,
              ),
            ),
            if (selected && _showTranslation) ...[
              const SizedBox(height: 14),
              Divider(
                color: selected
                    ? _emerald.withValues(alpha: 0.25)
                    : colors.outline.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 8),
              Text(
                translation,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.7,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    _translation == quran.Translation.enSaheeh
                        ? 'ENGLISH TRANSLATION (SAHEEH)'
                        : 'MALAYALAM TRANSLATION',
                    style: const TextStyle(
                      color: _emerald,
                      fontSize: 9.5,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _openVerse(ayahNumber),
                    icon: const Icon(Icons.open_in_new_rounded, size: 14),
                    label: const Text('Details'),
                    style: TextButton.styleFrom(foregroundColor: _emerald),
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
                    size: 16,
                  ),
                  label: Text(bookmarked ? 'Remove Bookmark' : 'Save Bookmark'),
                  style: TextButton.styleFrom(foregroundColor: _emerald),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKhatamulQuranDuaButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      child: OutlinedButton.icon(
        onPressed: () => context.push('/duas/quran_4'),
        icon: const Icon(Icons.auto_stories_rounded),
        label: const Text('Read Khatamul Quran Dua'),
        style: OutlinedButton.styleFrom(
          foregroundColor: _emerald,
          side: BorderSide(
            color: _emerald.withValues(alpha: 0.45),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildNextSurahButton(dynamic data, int currentSurah) {
    if (currentSurah >= 114) {
      return Container(
        margin: const EdgeInsets.only(top: 24, bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _emerald.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _emerald.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.workspace_premium_rounded, color: _gold, size: 36),
            const SizedBox(height: 8),
            const Text(
              'End of the Holy Quran',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 14),
            _buildKhatamulQuranDuaButton(),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _emerald,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => _navigateToSurah(1),
              icon: const Icon(Icons.replay_rounded, size: 18),
              label: const Text('Return to Surah Al-Fatihah'),
            ),
          ],
        ),
      );
    }

    final nextSurah = currentSurah + 1;
    final nextSurahNameEnglish = QuranMetadata.englishMeanings[nextSurah] ?? '';
    final nextSurahNameArabic = data.getSurahNameArabic(nextSurah);

    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 12),
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: _emerald,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          shadowColor: _emerald.withValues(alpha: 0.35),
        ),
        onPressed: () => _navigateToSurah(nextSurah),
        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
        label: Text(
          'Next Surah: ${nextSurahNameEnglish.toUpperCase()} ($nextSurahNameArabic)',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  String _ayahMarker(int number) {
    return '۞${_arabicNumber(number)}';
  }

  String _arabicNumber(int number) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) {
      return digits[int.parse(digit)];
    }).join();
  }
}