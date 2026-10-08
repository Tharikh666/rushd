sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException(super.message);
}

final class StorageException extends AppException {
  const StorageException(super.message);
}

final class LocationServiceDisabledException
    extends AppException {
  const LocationServiceDisabledException(super.message);
}

final class LocationPermissionDeniedException
    extends AppException {
  const LocationPermissionDeniedException(super.message);
}

final class LocationPermissionPermanentlyDeniedException
    extends AppException {
  const LocationPermissionPermanentlyDeniedException(
      super.message,
      );
}

final class LocationUnavailableException
    extends AppException {
  const LocationUnavailableException(super.message);
}

final class UnknownAppException extends AppException {
  const UnknownAppException(super.message);
}