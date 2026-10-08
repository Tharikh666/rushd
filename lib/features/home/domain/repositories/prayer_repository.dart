import '../../../../core/result/app_result.dart';
import '../entities/prayer_schedule.dart';
import '../prayer_calculation_settings.dart';

abstract interface class PrayerRepository {
  Future<AppResult<PrayerSchedule>> getPrayerSchedule({
    required DateTime date,
    required double latitude,
    required double longitude,
    required String timezone,
    required PrayerCalculationSettings settings,
  });
}