import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran/quran.dart' as quran;
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
      '$surahName · Ayah $ayah',
      arabic,
      '',
      'English',
      english,
      '',
      'Malayalam',
      malayalam,
    ].join('\n');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F1),
        title: const Text(
          'QURAN VERSE',
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF006451), Color(0xFF004B40)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    data.getSurahNameArabic(surah),
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(color: Colors.white, fontSize: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$surahName · ${data.getSurahName(surah)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
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
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Ayah $ayah',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFEF7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E9DE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 30, 22, 28),
                    child: Text(
                      '$arabic  ۞',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        height: 2.0,
                        color: Color(0xFF18211D),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _translationSection(
                    label: 'ENGLISH TRANSLATION',
                    text: english,
                  ),
                  const Divider(height: 1),
                  _translationSection(
                    label: 'MALAYALAM TRANSLATION',
                    text: malayalam,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E9DE)),
              ),
              child: Column(
                children: [
                  _metadata(
                    'Surah',
                    '$surahName / ${data.getSurahName(surah)}',
                  ),
                  _metadata('Ayah', '$ayah'),
                  _metadata('Juz', '$juz'),
                  _metadata('Revelation', place),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: RushdColors.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: fullText));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Verse text copied')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 17),
                    label: const Text('Copy Full Text'),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 14,
                    ),
                  ),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: fullText));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Verse copied. You can now paste it to share.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share_outlined, size: 17),
                  label: const Text('Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _translationSection({required String label, required String text}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF71958B),
              fontSize: 10,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF38433E),
              fontSize: 15,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metadata(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF829087)),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFF293B33),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
