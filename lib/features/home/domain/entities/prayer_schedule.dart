import 'prayer_time.dart';

class PrayerSchedule {
  const PrayerSchedule({
    required this.date,
    required this.timezone,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  final DateTime date;
  final String timezone;

  final PrayerTime fajr;
  final PrayerTime sunrise;
  final PrayerTime dhuhr;
  final PrayerTime asr;
  final PrayerTime maghrib;
  final PrayerTime isha;

  List<PrayerTime> get allTimes => [
    fajr,
    sunrise,
    dhuhr,
    asr,
    maghrib,
    isha,
  ];

  /// The five daily Salah times.
  ///
  /// Sunrise is deliberately excluded because it is a
  /// solar event rather than one of the five obligatory prayers.
  List<PrayerTime> get obligatoryPrayers => [
    fajr,
    dhuhr,
    asr,
    maghrib,
    isha,
  ];
}