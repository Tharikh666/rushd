import 'package:quran/quran.dart' as quran;
import '../domain/quran_ayah.dart';

/// Provides a single access point for Quran text and Surah metadata.
///
/// This service reads Quran data locally from the quran package.
/// It does not require a backend connection.
class QuranDataService {
  const QuranDataService();

  /// The Quran contains 114 Surahs.
  int get totalSurahs => 114;

  /// Returns the Surah's English/transliterated name.
  String getSurahName(int surahNumber) {
    _validateSurah(surahNumber);
    return quran.getSurahName(surahNumber);
  }

  /// Returns the Surah's Arabic name.
  String getSurahNameArabic(int surahNumber) {
    _validateSurah(surahNumber);
    return quran.getSurahNameArabic(surahNumber);
  }

  /// Returns the English name of the Surah.
  String getSurahNameEnglish(int surahNumber) {
    _validateSurah(surahNumber);
    return quran.getSurahNameEnglish(surahNumber);
  }

  /// Returns the number of Ayahs in a Surah.
  int getVerseCount(int surahNumber) {
    _validateSurah(surahNumber);
    return quran.getVerseCount(surahNumber);
  }

  /// Returns the Arabic text of an Ayah.
  String getVerse(int surahNumber, int ayahNumber) {
    _validateAyah(surahNumber, ayahNumber);
    return quran.getVerse(surahNumber, ayahNumber);
  }

  /// Returns the revelation place, such as Makkah or Madinah.
  String getPlaceOfRevelation(int surahNumber) {
    _validateSurah(surahNumber);
    return quran.getPlaceOfRevelation(surahNumber);
  }

  /// Returns the Juz number containing an Ayah.
  int getJuzNumber(int surahNumber, int ayahNumber) {
    _validateAyah(surahNumber, ayahNumber);
    return quran.getJuzNumber(surahNumber, ayahNumber);
  }

  /// Returns a complete Ayah model, including its Arabic text.
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

    final verseCount = quran.getVerseCount(surahNumber);

    if (ayahNumber < 1 || ayahNumber > verseCount) {
      throw RangeError.range(ayahNumber, 1, verseCount, 'ayahNumber');
    }
  }
}
