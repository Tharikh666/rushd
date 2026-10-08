abstract final class RushdGrpcConfig {
  static const host = String.fromEnvironment(
    'RUSHD_GRPC_HOST',
    defaultValue: '10.176.17.54',
  );

  static const port = int.fromEnvironment(
    'RUSHD_GRPC_PORT',
    defaultValue: 50051,
  );

  static const useTls = bool.fromEnvironment(
    'RUSHD_GRPC_TLS',
    defaultValue: false,
  );
}
