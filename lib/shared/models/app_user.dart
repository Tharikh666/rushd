class AppUser {
  const AppUser({
    required this.id,
    this.displayName,
    this.timezone,
  });

  final String id;
  final String? displayName;
  final String? timezone;
}
