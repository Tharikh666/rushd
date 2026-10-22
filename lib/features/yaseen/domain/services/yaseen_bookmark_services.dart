import 'package:shared_preferences/shared_preferences.dart';

class YaseenBookmarkService {
  static const String _storageKey = 'yaseen_bookmarks';

  Future<List<int>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final storedBookmarks = prefs.getStringList(_storageKey) ?? [];

    return storedBookmarks
        .map(int.tryParse)
        .whereType<int>()
        .where((ayahNumber) => ayahNumber >= 1 && ayahNumber <= 83)
        .toSet()
        .toList()
      ..sort();
  }

  Future<bool> isBookmarked(int ayahNumber) async {
    final bookmarks = await getBookmarks();
    return bookmarks.contains(ayahNumber);
  }

  Future<void> addBookmark(int ayahNumber) async {
    _validateAyahNumber(ayahNumber);

    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList(_storageKey) ?? [];
    final value = ayahNumber.toString();

    if (!bookmarks.contains(value)) {
      bookmarks.add(value);
      await prefs.setStringList(_storageKey, bookmarks);
    }
  }

  Future<void> removeBookmark(int ayahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList(_storageKey) ?? [];

    bookmarks.remove(ayahNumber.toString());
    await prefs.setStringList(_storageKey, bookmarks);
  }

  Future<void> toggleBookmark(int ayahNumber) async {
    if (await isBookmarked(ayahNumber)) {
      await removeBookmark(ayahNumber);
    } else {
      await addBookmark(ayahNumber);
    }
  }

  void _validateAyahNumber(int ayahNumber) {
    if (ayahNumber < 1 || ayahNumber > 83) {
      throw RangeError.range(ayahNumber, 1, 83, 'ayahNumber');
    }
  }
}
