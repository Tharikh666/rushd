import 'package:quran/quran.dart' as quran;

import '../domain/quran_ayah.dart';

class QuranDataService {
  const QuranDataService();

  int get totalSurahs => quran.totalSurahCount;
  int get totalJuz => quran.totalJuzCount;

  String getSurahName(int surahNumber) {
    _validateSurah(surahNumber);
    return quran.getSurahName(surahNumber);
  }

  String getSurahNameArabic(int surahNumber) {
    _validateSurah(surahNumber);
    return quran.getSurahNameArabic(surahNumber);
  }

  String getSurahNameEnglish(int surahNumber) {
    _validateSurah(surahNumber);
    return quran.getSurahNameEnglish(surahNumber);
  }

  int getVerseCount(int surahNumber) {
    _validateSurah(surahNumber);
    return quran.getVerseCount(surahNumber);
  }

  String getVerse(int surahNumber, int ayahNumber) {
    _validateAyah(surahNumber, ayahNumber);
    return quran.getVerse(surahNumber, ayahNumber);
  }

  String getTranslation(
    int surahNumber,
    int ayahNumber, {
    quran.Translation translation = quran.Translation.enSaheeh,
  }) {
    _validateAyah(surahNumber, ayahNumber);

    return quran.getVerseTranslation(
      surahNumber,
      ayahNumber,
      translation: translation,
    );
  }

  String getPlaceOfRevelation(int surahNumber) {
    _validateSurah(surahNumber);
    return quran.getPlaceOfRevelation(surahNumber);
  }

  int getJuzNumber(int surahNumber, int ayahNumber) {
    _validateAyah(surahNumber, ayahNumber);
    return quran.getJuzNumber(surahNumber, ayahNumber);
  }

  Map<int, List<int>> getSurahsInJuz(int juzNumber) {
    if (juzNumber < 1 || juzNumber > totalJuz) {
      throw RangeError.range(juzNumber, 1, totalJuz, 'juzNumber');
    }

    return quran.getSurahAndVersesFromJuz(juzNumber);
  }

  QuranAyah getAyah(int surahNumber, int ayahNumber) {
    return QuranAyah(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      arabicText: getVerse(surahNumber, ayahNumber),
    );
  }

  void _validateSurah(int surahNumber) {
    if (surahNumber < 1 || surahNumber > totalSurahs) {
      throw RangeError.range(surahNumber, 1, totalSurahs, 'surahNumber');
    }
  }

  void _validateAyah(int surahNumber, int ayahNumber) {
    _validateSurah(surahNumber);

    final count = quran.getVerseCount(surahNumber);

    if (ayahNumber < 1 || ayahNumber > count) {
      throw RangeError.range(ayahNumber, 1, count, 'ayahNumber');
    }
  }
}
