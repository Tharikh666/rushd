import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';

import 'grpc_config.dart';

final grpcChannelProvider = Provider<ClientChannel>(
      (ref) {
    final channel = ClientChannel(
      RushdGrpcConfig.host,
      port: RushdGrpcConfig.port,
      options: ChannelOptions(
        credentials: RushdGrpcConfig.useTls
            ? const ChannelCredentials.secure()
            : const ChannelCredentials.insecure(),
        connectionTimeout: const Duration(seconds: 10),
        idleTimeout: const Duration(minutes: 5),
      ),
    );

    ref.onDispose(channel.shutdown);

    return channel;
  },
);