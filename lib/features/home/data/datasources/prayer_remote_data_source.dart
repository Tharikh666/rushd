import 'package:grpc/grpc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../generated/prayer/v1/prayer.pbgrpc.dart';
import '../../domain/prayer_calculation_settings.dart';

class PrayerRemoteDataSource {
  const PrayerRemoteDataSource(this._client);

  final PrayerServiceClient _client;

  Future<GetPrayerTimesResponse> getPrayerTimes({
    required double latitude,
    required double longitude,
    required String timezone,
    required DateTime date,
    required PrayerCalculationSettings settings,
  }) async {
    try {
      final request = GetPrayerTimesRequest()
        ..latitude = latitude
        ..longitude = longitude
        ..timezone = timezone
        ..date = _formatDate(date)
        ..calculation = _buildCalculationSettings(settings);

      return await _client.getPrayerTimes(request);
    } on GrpcError catch (error) {
      throw NetworkException(_mapGrpcError(error));
    } on AppException {
      rethrow;
    } catch (error) {
      throw UnknownAppException('Unable to load prayer times: $error');
    }
  }

  CalculationSettings _buildCalculationSettings(
    PrayerCalculationSettings settings,
  ) {
    return CalculationSettings()
      ..method = _mapMethod(settings.method)
      ..madhab = _mapMadhab(settings.madhab)
      ..highLatitudeRule = _mapHighLatitudeRule(settings.highLatitudeRule);
  }

  CalculationMethod _mapMethod(PrayerCalculationMethod method) {
    switch (method) {
      case PrayerCalculationMethod.muslimWorldLeague:
        return CalculationMethod.MUSLIM_WORLD_LEAGUE;

      case PrayerCalculationMethod.egyptian:
        return CalculationMethod.EGYPTIAN;

      case PrayerCalculationMethod.karachi:
        return CalculationMethod.KARACHI;

      case PrayerCalculationMethod.ummAlQura:
        return CalculationMethod.UMM_AL_QURA;

      case PrayerCalculationMethod.dubai:
        return CalculationMethod.DUBAI;

      case PrayerCalculationMethod.moonSightingCommittee:
        return CalculationMethod.MOON_SIGHTING_COMMITTEE;

      case PrayerCalculationMethod.northAmerica:
        return CalculationMethod.NORTH_AMERICA;

      case PrayerCalculationMethod.kuwait:
        return CalculationMethod.KUWAIT;

      case PrayerCalculationMethod.qatar:
        return CalculationMethod.QATAR;

      case PrayerCalculationMethod.singapore:
        return CalculationMethod.SINGAPORE;
    }
  }

  Madhab _mapMadhab(PrayerMadhab madhab) {
    switch (madhab) {
      case PrayerMadhab.shafi:
        return Madhab.SHAFI;

      case PrayerMadhab.hanafi:
        return Madhab.HANAFI;
    }
  }

  HighLatitudeRule _mapHighLatitudeRule(PrayerHighLatitudeRule rule) {
    switch (rule) {
      case PrayerHighLatitudeRule.middleOfTheNight:
        return HighLatitudeRule.MIDDLE_OF_THE_NIGHT;

      case PrayerHighLatitudeRule.seventhOfTheNight:
        return HighLatitudeRule.SEVENTH_OF_THE_NIGHT;

      case PrayerHighLatitudeRule.twilightAngle:
        return HighLatitudeRule.TWILIGHT_ANGLE;
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');

    final month = date.month.toString().padLeft(2, '0');

    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _mapGrpcError(GrpcError error) {
    switch (error.code) {
      case StatusCode.unavailable:
        return 'Prayer service is currently unavailable.';

      case StatusCode.deadlineExceeded:
        return 'Prayer service request timed out.';

      case StatusCode.invalidArgument:
        return error.message ??
            'The prayer request contains invalid information.';

      case StatusCode.unauthenticated:
        return 'Authentication is required to access prayer times.';

      default:
        return error.message ??
            'Unable to communicate with the prayer service.';
    }
  }
}
