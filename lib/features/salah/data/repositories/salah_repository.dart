import 'dart:convert';

import 'package:flutter/services.dart';

class SalahRepository {
  static const String _dailyPrayersPath = 'assets/datasets/index_salah.json';

  static const String _specialPrayersPath =
      'assets/datasets/index_special_salah.json';

  static const String _guidesPath = 'assets/datasets/salah_guides.json';

  static const String _recitationsPath =
      'assets/datasets/salah_recitations.json';

  static const String _positionsPath = 'assets/datasets/salah_positions.json';

  Future<List<Map<String, dynamic>>> _loadList(String path) async {
    final jsonString = await rootBundle.loadString(path);
    final decoded = jsonDecode(jsonString) as List<dynamic>;

    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<Map<String, dynamic>> _loadMap(String path) async {
    final jsonString = await rootBundle.loadString(path);
    return Map<String, dynamic>.from(jsonDecode(jsonString) as Map);
  }

  Future<List<Map<String, dynamic>>> getDailyPrayers() {
    return _loadList(_dailyPrayersPath);
  }

  Future<List<Map<String, dynamic>>> getSpecialPrayers() {
    return _loadList(_specialPrayersPath);
  }

  Future<List<Map<String, dynamic>>> getPrayerGuides() {
    return _loadList(_guidesPath);
  }

  Future<List<Map<String, dynamic>>> getRecitations() {
    return _loadList(_recitationsPath);
  }

  Future<Map<String, dynamic>> getPositions() {
    return _loadMap(_positionsPath);
  }

  Future<Map<String, dynamic>> getPrayerGuide(String prayerId) async {
    final guides = await getPrayerGuides();

    return guides.firstWhere(
      (guide) => guide['prayer_id'] == prayerId,
      orElse: () => throw StateError('Prayer guide not found: $prayerId'),
    );
  }

  Future<Map<String, dynamic>> getRecitation(String recitationId) async {
    final recitations = await getRecitations();

    return recitations.firstWhere(
      (recitation) => recitation['id'] == recitationId,
      orElse: () => throw StateError('Recitation not found: $recitationId'),
    );
  }

  Future<Map<String, dynamic>> getPrayerBundle(String prayerId) async {
    final results = await Future.wait<dynamic>([
      getPrayerGuide(prayerId),
      getRecitations(),
      getPositions(),
    ]);

    return {
      'prayer': results[0],
      'recitations': results[1],
      'positions': results[2],
    };
  }
}
