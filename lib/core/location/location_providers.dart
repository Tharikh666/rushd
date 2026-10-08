import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'location_models.dart';
import 'location_service.dart';
import 'timezone_service.dart';

final locationServiceProvider =
Provider<LocationService>(
      (ref) {
    return const GeolocatorLocationService();
  },
);

final timezoneServiceProvider =
Provider<TimezoneService>(
      (ref) {
    return const DeviceTimezoneService();
  },
);

final currentLocationProvider =
FutureProvider<LocationCoordinates>(
      (ref) async {
    final service =
    ref.watch(locationServiceProvider);

    return service.getCurrentLocation();
  },
);

final localTimezoneProvider =
FutureProvider<String>(
      (ref) async {
    final service =
    ref.watch(timezoneServiceProvider);

    return service.getLocalTimezone();
  },
);