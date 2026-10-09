import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/quran_ayah.dart';

/// Stores and manages Quran bookmarks on the local device.
class QuranBookmarkService {
  static const String _storageKey = 'quran_bookmarks';

  /// Returns all saved bookmarks.
  Future<List<QuranAyah>> getBookmarks() async {
    final preferences = await SharedPreferences.getInstance();
    final savedBookmarks = preferences.getStringList(_storageKey) ?? [];

    return savedBookmarks.map((item) {
      final data = jsonDecode(item) as Map<String, dynamic>;

      return QuranAyah(
        surahNumber: data['surahNumber'] as int,
        ayahNumber: data['ayahNumber'] as int,
        arabicText: data['arabicText'] as String,
      );
    }).toList();
  }

  /// Checks whether an Ayah is bookmarked.
  Future<bool> isBookmarked(int surahNumber, int ayahNumber) async {
    final bookmarks = await getBookmarks();

    return bookmarks.any(
      (ayah) =>
          ayah.surahNumber == surahNumber && ayah.ayahNumber == ayahNumber,
    );
  }

  /// Adds a bookmark, or removes it if it already exists.
  ///
  /// Returns true if the Ayah is bookmarked after this operation,
  /// or false if the bookmark was removed.
  Future<bool> toggleBookmark(QuranAyah ayah) async {
    final preferences = await SharedPreferences.getInstance();
    final savedBookmarks = preferences.getStringList(_storageKey) ?? [];

    final alreadyBookmarked = savedBookmarks.any((item) {
      final data = jsonDecode(item) as Map<String, dynamic>;

      return data['surahNumber'] == ayah.surahNumber &&
          data['ayahNumber'] == ayah.ayahNumber;
    });

    if (alreadyBookmarked) {
      savedBookmarks.removeWhere((item) {
        final data = jsonDecode(item) as Map<String, dynamic>;

        return data['surahNumber'] == ayah.surahNumber &&
            data['ayahNumber'] == ayah.ayahNumber;
      });

      await preferences.setStringList(_storageKey, savedBookmarks);
      return false;
    }

    savedBookmarks.add(
      jsonEncode({
        'surahNumber': ayah.surahNumber,
        'ayahNumber': ayah.ayahNumber,
        'arabicText': ayah.arabicText,
      }),
    );

    await preferences.setStringList(_storageKey, savedBookmarks);
    return true;
  }

  /// Removes all saved bookmarks.
  Future<void> clearBookmarks() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }
}
