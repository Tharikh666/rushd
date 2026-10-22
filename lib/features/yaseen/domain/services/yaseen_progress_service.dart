import 'package:shared_preferences/shared_preferences.dart';

class YaseenProgressService {
  static const String _storageKey = 'yaseen_progress';

  Future<int> getLastReadAyah() async {
    final prefs = await SharedPreferences.getInstance();
    final ayahNumber = prefs.getInt(_storageKey) ?? 1;

    if (ayahNumber < 1 || ayahNumber > 83) {
      return 1;
    }

    return ayahNumber;
  }

  Future<void> saveProgress(int ayahNumber) async {
    _validateAyahNumber(ayahNumber);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageKey, ayahNumber);
  }

  Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  void _validateAyahNumber(int ayahNumber) {
    if (ayahNumber < 1 || ayahNumber > 83) {
      throw RangeError.range(ayahNumber, 1, 83, 'ayahNumber');
    }
  }
}
