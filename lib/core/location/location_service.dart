import 'package:geolocator/geolocator.dart' hide LocationServiceDisabledException;

import '../errors/app_exception.dart';
import 'location_models.dart';

abstract interface class LocationService {
  Future<LocationCoordinates> getCurrentLocation();

  Future<bool> isLocationServiceEnabled();

  Future<LocationPermission> getPermissionStatus();

  Future<LocationPermission> requestPermission();

  Future<bool> openAppSettings();

  Future<bool> openLocationSettings();
}

final class GeolocatorLocationService
    implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<LocationCoordinates> getCurrentLocation() async {
    try {
      final serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw const LocationServiceDisabledException(
          'Location services are disabled. '
              'Please enable location services to continue.',
        );
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw const LocationPermissionDeniedException(
          'Location permission was denied.',
        );
      }

      if (permission ==
          LocationPermission.deniedForever) {
        throw const LocationPermissionPermanentlyDeniedException(
          'Location permission is permanently denied. '
              'Please enable it from the app settings.',
        );
      }

      final position =
      await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return LocationCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );
    } on AppException {
      rethrow;
    } catch (error) {
      throw UnknownAppException(
        'Unable to determine your current location: $error',
      );
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<LocationPermission> getPermissionStatus() {
    return Geolocator.checkPermission();
  }

  @override
  Future<LocationPermission> requestPermission() {
    return Geolocator.requestPermission();
  }

  @override
  Future<bool> openAppSettings() {
    return Geolocator.openAppSettings();
  }

  @override
  Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }
}