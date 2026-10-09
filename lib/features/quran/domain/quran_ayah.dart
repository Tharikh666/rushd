/// Represents a single Ayah (verse) of the Holy Quran.
///
/// The Arabic text comes from the local Quran data service.
/// Translation data can be added later without changing the
/// identity of the Ayah.
class QuranAyah {
  const QuranAyah({
    required this.surahNumber,
    required this.ayahNumber,
    required this.arabicText,
  });

  /// Surah number, from 1 to 114.
  final int surahNumber;

  /// Ayah number within its Surah.
  final int ayahNumber;

  /// Original Arabic text of this Ayah.
  final String arabicText;

  /// A stable identifier for bookmarks and reading progress.
  String get id => '$surahNumber:$ayahNumber';
}
