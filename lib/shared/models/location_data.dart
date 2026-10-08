class LocationData {
  const LocationData({
    required this.latitude,
    required this.longitude,
    this.city,
    this.countryCode,
  });

  final double latitude;
  final double longitude;
  final String? city;
  final String? countryCode;
}
