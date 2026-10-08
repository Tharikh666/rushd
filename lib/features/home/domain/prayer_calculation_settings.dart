enum PrayerCalculationMethod {
  muslimWorldLeague,
  egyptian,
  karachi,
  ummAlQura,
  dubai,
  moonSightingCommittee,
  northAmerica,
  kuwait,
  qatar,
  singapore,
}

enum PrayerMadhab {
  shafi,
  hanafi,
}

enum PrayerHighLatitudeRule {
  middleOfTheNight,
  seventhOfTheNight,
  twilightAngle,
}

class PrayerCalculationSettings {
  const PrayerCalculationSettings({
    required this.method,
    required this.madhab,
    required this.highLatitudeRule,
  });

  final PrayerCalculationMethod method;
  final PrayerMadhab madhab;
  final PrayerHighLatitudeRule highLatitudeRule;

  /// Initial RUSHD calculation defaults.
  ///
  /// These are centralized here so the rest of the application
  /// never needs to know which calculation method is being used.
  static const defaultSettings = PrayerCalculationSettings(
    method: PrayerCalculationMethod.karachi,
    madhab: PrayerMadhab.shafi,
    highLatitudeRule:
    PrayerHighLatitudeRule.middleOfTheNight,
  );
}