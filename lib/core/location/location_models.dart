import 'package:flutter/foundation.dart';

@immutable
class LocationCoordinates {
  const LocationCoordinates({
    required this.latitude,
    required this.longitude,
    this.accuracy,
  });

  final double latitude;
  final double longitude;
  final double? accuracy;

  @override
  String toString() {
    return 'LocationCoordinates('
        'latitude: $latitude, '
        'longitude: $longitude, '
        'accuracy: $accuracy'
        ')';
  }
}