// This is a generated file - do not edit.
//
// Generated from prayer/v1/prayer.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'prayer.pb.dart' as $0;

export 'prayer.pb.dart';

/// PrayerService provides Islamic prayer time calculations.
@$pb.GrpcServiceName('rushd.prayer.v1.PrayerService')
class PrayerServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  PrayerServiceClient(super.channel, {super.options, super.interceptors});

  /// Calculates prayer times for a specific location and date.
  $grpc.ResponseFuture<$0.GetPrayerTimesResponse> getPrayerTimes(
    $0.GetPrayerTimesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getPrayerTimes, request, options: options);
  }

  // method descriptors

  static final _$getPrayerTimes =
      $grpc.ClientMethod<$0.GetPrayerTimesRequest, $0.GetPrayerTimesResponse>(
          '/rushd.prayer.v1.PrayerService/GetPrayerTimes',
          ($0.GetPrayerTimesRequest value) => value.writeToBuffer(),
          $0.GetPrayerTimesResponse.fromBuffer);
}

@$pb.GrpcServiceName('rushd.prayer.v1.PrayerService')
abstract class PrayerServiceBase extends $grpc.Service {
  $core.String get $name => 'rushd.prayer.v1.PrayerService';

  PrayerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetPrayerTimesRequest,
            $0.GetPrayerTimesResponse>(
        'GetPrayerTimes',
        getPrayerTimes_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetPrayerTimesRequest.fromBuffer(value),
        ($0.GetPrayerTimesResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetPrayerTimesResponse> getPrayerTimes_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetPrayerTimesRequest> $request) async {
    return getPrayerTimes($call, await $request);
  }

  $async.Future<$0.GetPrayerTimesResponse> getPrayerTimes(
      $grpc.ServiceCall call, $0.GetPrayerTimesRequest request);
}
