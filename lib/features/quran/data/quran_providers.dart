import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/quran_bookmark_service.dart';
import '../services/quran_progress_service.dart';
import 'quran_data_service.dart';

/// Shared access to local Quran text and Surah metadata.
final quranDataServiceProvider = Provider<QuranDataService>((ref) {
  return const QuranDataService();
});

/// Shared access to local Quran bookmarks.
final quranBookmarkServiceProvider = Provider<QuranBookmarkService>((ref) {
  return QuranBookmarkService();
});

/// Shared access to local Quran reading progress.
final quranProgressServiceProvider = Provider<QuranProgressService>((ref) {
  return const QuranProgressService();
});
