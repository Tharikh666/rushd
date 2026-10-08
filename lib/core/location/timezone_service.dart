import 'package:flutter_timezone/flutter_timezone.dart';

import '../errors/app_exception.dart';

abstract interface class TimezoneService {
  Future<String> getLocalTimezone();
}

final class DeviceTimezoneService
    implements TimezoneService {
  const DeviceTimezoneService();

  @override
  Future<String> getLocalTimezone() async {
    try {
      final timezone =
      await FlutterTimezone.getLocalTimezone();

      return timezone.identifier;
    } catch (error) {
      throw UnknownAppException(
        'Unable to determine the device timezone: $error',
      );
    }
  }
}