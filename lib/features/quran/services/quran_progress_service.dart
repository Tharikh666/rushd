import 'package:shared_preferences/shared_preferences.dart';

import '../data/quran_data_service.dart';
import '../domain/quran_ayah.dart';

/// Stores the user's last-read Quran verse on the local device.
class QuranProgressService {
  static const String _surahKey = 'quran_progress_surah';
  static const String _ayahKey = 'quran_progress_ayah';

  const QuranProgressService();

  /// Saves the last-read Ayah.
  Future<void> saveProgress(QuranAyah ayah) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setInt(_surahKey, ayah.surahNumber);
    await preferences.setInt(_ayahKey, ayah.ayahNumber);
  }

  /// Retrieves the last-read Ayah, or null if no progress is saved.
  Future<QuranAyah?> getProgress() async {
    final preferences = await SharedPreferences.getInstance();

    final surahNumber = preferences.getInt(_surahKey);
    final ayahNumber = preferences.getInt(_ayahKey);

    if (surahNumber == null || ayahNumber == null) {
      return null;
    }

    // Reconstruct the Ayah from the local Quran data.
    // We only need to persist its Surah and Ayah numbers.
    return const QuranDataService().getAyah(surahNumber, ayahNumber);
  }

  /// Clears the saved reading progress.
  Future<void> clearProgress() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_surahKey);
    await preferences.remove(_ayahKey);
  }
}
