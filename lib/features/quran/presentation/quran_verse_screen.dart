import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran/quran.dart' as quran;
import 'package:share_plus/share_plus.dart';
import 'package:rushd/features/quran/data/quran_metadata.dart';

import '../../../core/theme/rushd_colors.dart';
import '../data/quran_providers.dart';

class QuranVerseScreen extends ConsumerStatefulWidget {
  const QuranVerseScreen({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
  });

  final int surahNumber;
  final int ayahNumber;

  @override
  ConsumerState<QuranVerseScreen> createState() => _QuranVerseScreenState();
}

class _QuranVerseScreenState extends ConsumerState<QuranVerseScreen> {
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(quranDataServiceProvider);
    final surah = widget.surahNumber.clamp(1, 114);
    final count = data.getVerseCount(surah);
    final ayah = widget.ayahNumber.clamp(1, count);

    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    final arabic = data.getVerse(surah, ayah);
    final english = data.getTranslation(
      surah,
      ayah,
      translation: quran.Translation.enSaheeh,
    );
    final malayalam = data.getTranslation(
      surah,
      ayah,
      translation: quran.Translation.mlAbdulHameed,
    );
    final surahName = QuranMetadata.englishMeanings[surah];
    final juz = data.getJuzNumber(surah, ayah);
    final place = data.getPlaceOfRevelation(surah);

    final fullText = [
      '✨ Surah $surahName · Ayah $ayah ✨\n',
      arabic,
      '\n• English (Saheeh):\n$english',
      '\n• Malayalam:\n$malayalam',
      '\n--- \nShared via RUSHD App',
    ].join('\n');

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'QURAN VERSE DETAILS',
          style: TextStyle(
            fontSize: 13.5,
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_rounded, color: colors.onSurface),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
          children: [
            // Hero Header Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF007967), Color(0xFF004B35)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF007967).withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    data.getSurahNameArabic(surah),
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Surah $surahName · ${data.getSurahName(surah)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Ayah $ayah of $count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Verse & Translations Card
            Container(
              decoration: BoxDecoration(
                color: dark
                    ? colors.surfaceContainerHighest.withValues(alpha: 0.5)
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                    child: Text(
                      '$arabic  ۞',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        height: 2.1,
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: colors.outline.withValues(alpha: 0.15),
                  ),
                  _translationSection(
                    label: 'ENGLISH TRANSLATION (SAHEEH)',
                    text: english,
                    colors: colors,
                  ),
                  Divider(
                    height: 1,
                    color: colors.outline.withValues(alpha: 0.15),
                  ),
                  _translationSection(
                    label: 'MALAYALAM TRANSLATION',
                    text: malayalam,
                    colors: colors,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Metadata Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: dark
                    ? colors.surfaceContainerHighest.withValues(alpha: 0.5)
                    : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                children: [
                  _metadata(
                    'Surah',
                    '$surahName (${data.getSurahName(surah)})',
                    colors,
                  ),
                  _metadata('Ayah Number', '$ayah', colors),
                  _metadata('Juz Part', '$juz', colors),
                  _metadata('Revelation Place', place, colors),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF007967),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: fullText));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Verse text copied to clipboard'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text(
                      'Copy Full Text',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(
                      color: colors.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  onPressed: () async {
                    await HapticFeedback.lightImpact();
                    await Share.share(
                      fullText,
                      subject: 'Surah $surahName - Ayah $ayah',
                    );
                  },
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text(
                    'Share',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _translationSection({
    required String label,
    required String text,
    required ColorScheme colors,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF007967),
              fontSize: 10.5,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 15,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metadata(String label, String value, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13.5),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
