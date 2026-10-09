import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/rushd_colors.dart';
import '../data/quran_providers.dart';

class QuranHomeScreen extends ConsumerWidget {
  const QuranHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quran = ref.watch(quranDataServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark
        ? RushdColors.darkTextPrimary
        : RushdColors.lightTextPrimary;

    final secondaryTextColor = isDark
        ? RushdColors.darkTextSecondary
        : RushdColors.lightTextSecondary;

    final surfaceColor = isDark
        ? RushdColors.darkSurface
        : RushdColors.lightSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Al-Quran',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          // Quran introduction card.
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  RushdColors.primaryDark,
                  RushdColors.primary,
                  Color(0xFF168F80),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white70,
                  size: 30,
                ),
                const SizedBox(height: 18),
                const Text(
                  'The Noble Quran',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Read, reflect, and reconnect.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _QuranStat(value: '${quran.totalSurahs}', label: 'Surahs'),
                    const SizedBox(width: 24),
                    const _QuranStat(value: '30', label: 'Juz'),
                    const SizedBox(width: 24),
                    const _QuranStat(value: '114', label: 'Chapters'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'SURAH DIRECTORY',
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          // All 114 Surahs, read from the local Quran package.
          ...List.generate(quran.totalSurahs, (index) {
            final surahNumber = index + 1;
            final name = quran.getSurahName(surahNumber);
            final englishName = quran.getSurahNameEnglish(surahNumber);
            final arabicName = quran.getSurahNameArabic(surahNumber);
            final verseCount = quran.getVerseCount(surahNumber);
            final revelation = quran.getPlaceOfRevelation(surahNumber);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$name will be available in the reader soon.',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 15,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: RushdColors.primary.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Text(
                            '$surahNumber',
                            style: const TextStyle(
                              color: RushdColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$englishName  •  $verseCount Ayahs',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                revelation,
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          arabicName,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 23,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _QuranStat extends StatelessWidget {
  const _QuranStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
