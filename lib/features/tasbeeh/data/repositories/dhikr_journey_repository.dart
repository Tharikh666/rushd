import 'dart:convert';

import '../../../../core/storage/local_storage.dart';
import '../../domain/models/dhikr_journey.dart';

class DhikrJourneyRepository {
  DhikrJourneyRepository(this._storage);

  final LocalStorage _storage;

  static const String _storageKey = 'rushd_dhikr_journeys';

  Future<List<DhikrJourney>> getJourneys() async {
    final storedValue = await _storage.readString(_storageKey);

    if (storedValue == null || storedValue.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(storedValue) as List<dynamic>;

      final journeys = decoded.map((item) {
        return DhikrJourney.fromJson(Map<String, dynamic>.from(item as Map));
      }).toList();

      journeys.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return journeys;
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<DhikrJourney?> getJourney(String id) async {
    final journeys = await getJourneys();

    for (final journey in journeys) {
      if (journey.id == id) {
        return journey;
      }
    }

    return null;
  }

  Future<void> createJourney(DhikrJourney journey) async {
    final journeys = await getJourneys();

    if (journeys.any((item) => item.id == journey.id)) {
      throw StateError('A journey with this ID already exists.');
    }

    journeys.add(journey);
    await _saveJourneys(journeys);
  }

  Future<void> updateJourney(DhikrJourney updatedJourney) async {
    final journeys = await getJourneys();
    final index = journeys.indexWhere(
      (journey) => journey.id == updatedJourney.id,
    );

    if (index == -1) {
      throw StateError('Dhikr journey not found.');
    }

    journeys[index] = updatedJourney;
    await _saveJourneys(journeys);
  }

  Future<void> deleteJourney(String id) async {
    final journeys = await getJourneys();

    journeys.removeWhere((journey) => journey.id == id);

    await _saveJourneys(journeys);
  }

  Future<void> _saveJourneys(List<DhikrJourney> journeys) async {
    final encoded = jsonEncode(
      journeys.map((journey) => journey.toJson()).toList(),
    );

    await _storage.writeString(_storageKey, encoded);
  }
}
