import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

class DuaRepository {
  static const String _datasetPath = 'assets/datasets/dua_dikr.json';

  Future<List<Map<String, dynamic>>> getAllDuas() async {
    final jsonString = await rootBundle.loadString(_datasetPath);
    final decoded = jsonDecode(jsonString) as List<dynamic>;

    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getDuasByCategory(
    String categoryId,
  ) async {
    final duas = await getAllDuas();

    return duas.where((dua) => dua['category'] == categoryId).toList();
  }

  Future<List<Map<String, dynamic>>> getDuasOfTheDay({DateTime? date}) async {
    final duas = await getAllDuas();

    if (duas.isEmpty) {
      return [];
    }

    // Use the local calendar date as the daily random seed.
    final today = date ?? DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;

    // Copy the list so the repository's original order is preserved.
    final dailyDuas = List<Map<String, dynamic>>.from(duas);

    dailyDuas.shuffle(Random(seed));

    return dailyDuas.take(3).toList();
  }

  Future<List<Map<String, dynamic>>> searchDuas(String query) async {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return [];
    }

    final duas = await getAllDuas();

    return duas.where((dua) {
      final searchableFields = [
        dua['title'],
        dua['category'],
        dua['arabic'],
        dua['english_transliteration'],
        dua['malayalam_transliteration'],
        dua['english_translation'],
        dua['malayalam_translation'],
        dua['source'],
        ...(dua['tags'] as List<dynamic>? ?? []),
      ];

      return searchableFields.any(
        (value) => value.toString().toLowerCase().contains(normalizedQuery),
      );
    }).toList();
  }

  Future<List<String>> getCategories() async {
    final duas = await getAllDuas();

    final categories = duas
        .map((dua) => dua['category']?.toString() ?? '')
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();

    return categories;
  }
}
