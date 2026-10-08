import 'package:flutter/foundation.dart';

enum PrayerType {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha,
}

@immutable
class PrayerTime {
  const PrayerTime({
    required this.type,
    required this.name,
    required this.arabicName,
    required this.time,
  });

  final PrayerType type;
  final String name;
  final String arabicName;
  final DateTime time;
}