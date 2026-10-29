import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class DeviceLocation {
  const DeviceLocation({required this.city, required this.country});

  final String city;
  final String country;

  String get label => country.isEmpty ? city : '$city, $country';
}

final deviceLocationProvider = FutureProvider.autoDispose<DeviceLocation?>((
    ref,
    ) async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position =
        await Geolocator.getLastKnownPosition() ??
            await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.low,
              ),
            );

    final placemarks = await Geocoding().placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isEmpty) return null;

    final place = placemarks.first;
    final city = place.locality?.isNotEmpty == true
        ? place.locality!
        : place.subAdministrativeArea?.isNotEmpty == true
        ? place.subAdministrativeArea!
        : '';
    if (city.isEmpty) return null;

    return DeviceLocation(city: city, country: place.country ?? '');
  } catch (_) {
    return null;
  }
});