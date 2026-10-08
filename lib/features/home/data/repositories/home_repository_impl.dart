import '../../../../../core/errors/app_exception.dart';
import '../../../../core/result/app_result.dart';
import '../../domain/entities/prayer_schedule.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/prayer_calculation_settings.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../datasources/prayer_remote_data_source.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  const PrayerRepositoryImpl(this._remoteDataSource);

  final PrayerRemoteDataSource _remoteDataSource;

  @override
  Future<AppResult<PrayerSchedule>> getPrayerSchedule({
    required DateTime date,
    required double latitude,
    required double longitude,
    required String timezone,
    required PrayerCalculationSettings settings,
  }) async {
    try {
      final response = await _remoteDataSource.getPrayerTimes(
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
        date: date,
        settings: settings,
      );

      if (response.date.isEmpty || response.timezone.isEmpty) {
        throw const UnknownAppException(
          'Prayer service returned an invalid schedule.',
        );
      }

      final schedule = PrayerSchedule(
        date: DateTime.parse(response.date),
        timezone: response.timezone,
        fajr: _mapPrayerTime(response.fajr, PrayerType.fajr),
        sunrise: _mapPrayerTime(response.sunrise, PrayerType.sunrise),
        dhuhr: _mapPrayerTime(response.dhuhr, PrayerType.dhuhr),
        asr: _mapPrayerTime(response.asr, PrayerType.asr),
        maghrib: _mapPrayerTime(response.maghrib, PrayerType.maghrib),
        isha: _mapPrayerTime(response.isha, PrayerType.isha),
      );

      return AppSuccess(schedule);
    } on AppException catch (error) {
      return AppFailure(error.message);
    } catch (error) {
      return AppFailure('Unable to load prayer times: $error');
    }
  }

  PrayerTime _mapPrayerTime(dynamic protoPrayer, PrayerType type) {
    if (protoPrayer.isoDatetime.isEmpty) {
      throw const UnknownAppException(
        'Prayer service returned an invalid prayer time.',
      );
    }

    return PrayerTime(
      type: type,
      name: protoPrayer.name,
      arabicName: protoPrayer.arabicName,
      time: DateTime.parse(protoPrayer.isoDatetime),
    );
  }
}
