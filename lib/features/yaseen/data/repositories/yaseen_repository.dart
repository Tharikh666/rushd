import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/yaseen_ayah.dart';

class YaseenRepository {
  static const String _assetPath = 'assets/datasets/yaseen.json';

  List<YaseenAyah>? _cachedAyahs;

  Future<List<YaseenAyah>> getAyahs() async {
    if (_cachedAyahs != null) {
      return _cachedAyahs!;
    }

    final jsonString = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(jsonString);

    if (decoded is! List) {
      throw const FormatException('Yaseen dataset must be a JSON array.');
    }

    final ayahs = decoded.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Each Yaseen Ayah must be a JSON object.');
      }

      return YaseenAyah.fromJson(item);
    }).toList();

    if (ayahs.length != 83) {
      throw FormatException('Expected 83 Ayahs, found ${ayahs.length}.');
    }

    for (var i = 0; i < ayahs.length; i++) {
      if (ayahs[i].ayahNumber != i + 1) {
        throw FormatException(
          'Expected Ayah ${i + 1}, '
          'found Ayah ${ayahs[i].ayahNumber}.',
        );
      }
    }

    _cachedAyahs = List.unmodifiable(ayahs);
    return _cachedAyahs!;
  }

  Future<YaseenAyah?> getAyah(int ayahNumber) async {
    if (ayahNumber < 1 || ayahNumber > 83) {
      return null;
    }

    final ayahs = await getAyahs();
    return ayahs[ayahNumber - 1];
  }
}
