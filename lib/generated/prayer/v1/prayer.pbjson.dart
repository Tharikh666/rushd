// This is a generated file - do not edit.
//
// Generated from prayer/v1/prayer.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use calculationMethodDescriptor instead')
const CalculationMethod$json = {
  '1': 'CalculationMethod',
  '2': [
    {'1': 'CALCULATION_METHOD_UNSPECIFIED', '2': 0},
    {'1': 'MUSLIM_WORLD_LEAGUE', '2': 1},
    {'1': 'EGYPTIAN', '2': 2},
    {'1': 'KARACHI', '2': 3},
    {'1': 'UMM_AL_QURA', '2': 4},
    {'1': 'DUBAI', '2': 5},
    {'1': 'MOON_SIGHTING_COMMITTEE', '2': 6},
    {'1': 'NORTH_AMERICA', '2': 7},
    {'1': 'KUWAIT', '2': 8},
    {'1': 'QATAR', '2': 9},
    {'1': 'SINGAPORE', '2': 10},
  ],
};

/// Descriptor for `CalculationMethod`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List calculationMethodDescriptor = $convert.base64Decode(
    'ChFDYWxjdWxhdGlvbk1ldGhvZBIiCh5DQUxDVUxBVElPTl9NRVRIT0RfVU5TUEVDSUZJRUQQAB'
    'IXChNNVVNMSU1fV09STERfTEVBR1VFEAESDAoIRUdZUFRJQU4QAhILCgdLQVJBQ0hJEAMSDwoL'
    'VU1NX0FMX1FVUkEQBBIJCgVEVUJBSRAFEhsKF01PT05fU0lHSFRJTkdfQ09NTUlUVEVFEAYSEQ'
    'oNTk9SVEhfQU1FUklDQRAHEgoKBktVV0FJVBAIEgkKBVFBVEFSEAkSDQoJU0lOR0FQT1JFEAo=');

@$core.Deprecated('Use madhabDescriptor instead')
const Madhab$json = {
  '1': 'Madhab',
  '2': [
    {'1': 'MADHAB_UNSPECIFIED', '2': 0},
    {'1': 'SHAFI', '2': 1},
    {'1': 'HANAFI', '2': 2},
  ],
};

/// Descriptor for `Madhab`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List madhabDescriptor = $convert.base64Decode(
    'CgZNYWRoYWISFgoSTUFESEFCX1VOU1BFQ0lGSUVEEAASCQoFU0hBRkkQARIKCgZIQU5BRkkQAg'
    '==');

@$core.Deprecated('Use highLatitudeRuleDescriptor instead')
const HighLatitudeRule$json = {
  '1': 'HighLatitudeRule',
  '2': [
    {'1': 'HIGH_LATITUDE_RULE_UNSPECIFIED', '2': 0},
    {'1': 'MIDDLE_OF_THE_NIGHT', '2': 1},
    {'1': 'SEVENTH_OF_THE_NIGHT', '2': 2},
    {'1': 'TWILIGHT_ANGLE', '2': 3},
  ],
};

/// Descriptor for `HighLatitudeRule`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List highLatitudeRuleDescriptor = $convert.base64Decode(
    'ChBIaWdoTGF0aXR1ZGVSdWxlEiIKHkhJR0hfTEFUSVRVREVfUlVMRV9VTlNQRUNJRklFRBAAEh'
    'cKE01JRERMRV9PRl9USEVfTklHSFQQARIYChRTRVZFTlRIX09GX1RIRV9OSUdIVBACEhIKDlRX'
    'SUxJR0hUX0FOR0xFEAM=');

@$core.Deprecated('Use getPrayerTimesRequestDescriptor instead')
const GetPrayerTimesRequest$json = {
  '1': 'GetPrayerTimesRequest',
  '2': [
    {'1': 'latitude', '3': 1, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 2, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'timezone', '3': 3, '4': 1, '5': 9, '10': 'timezone'},
    {'1': 'date', '3': 4, '4': 1, '5': 9, '10': 'date'},
    {
      '1': 'calculation',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.rushd.prayer.v1.CalculationSettings',
      '10': 'calculation'
    },
  ],
};

/// Descriptor for `GetPrayerTimesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPrayerTimesRequestDescriptor = $convert.base64Decode(
    'ChVHZXRQcmF5ZXJUaW1lc1JlcXVlc3QSGgoIbGF0aXR1ZGUYASABKAFSCGxhdGl0dWRlEhwKCW'
    'xvbmdpdHVkZRgCIAEoAVIJbG9uZ2l0dWRlEhoKCHRpbWV6b25lGAMgASgJUgh0aW1lem9uZRIS'
    'CgRkYXRlGAQgASgJUgRkYXRlEkYKC2NhbGN1bGF0aW9uGAUgASgLMiQucnVzaGQucHJheWVyLn'
    'YxLkNhbGN1bGF0aW9uU2V0dGluZ3NSC2NhbGN1bGF0aW9u');

@$core.Deprecated('Use calculationSettingsDescriptor instead')
const CalculationSettings$json = {
  '1': 'CalculationSettings',
  '2': [
    {
      '1': 'method',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.rushd.prayer.v1.CalculationMethod',
      '10': 'method'
    },
    {
      '1': 'madhab',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.rushd.prayer.v1.Madhab',
      '10': 'madhab'
    },
    {
      '1': 'high_latitude_rule',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.rushd.prayer.v1.HighLatitudeRule',
      '10': 'highLatitudeRule'
    },
  ],
};

/// Descriptor for `CalculationSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calculationSettingsDescriptor = $convert.base64Decode(
    'ChNDYWxjdWxhdGlvblNldHRpbmdzEjoKBm1ldGhvZBgBIAEoDjIiLnJ1c2hkLnByYXllci52MS'
    '5DYWxjdWxhdGlvbk1ldGhvZFIGbWV0aG9kEi8KBm1hZGhhYhgCIAEoDjIXLnJ1c2hkLnByYXll'
    'ci52MS5NYWRoYWJSBm1hZGhhYhJPChJoaWdoX2xhdGl0dWRlX3J1bGUYAyABKA4yIS5ydXNoZC'
    '5wcmF5ZXIudjEuSGlnaExhdGl0dWRlUnVsZVIQaGlnaExhdGl0dWRlUnVsZQ==');

@$core.Deprecated('Use getPrayerTimesResponseDescriptor instead')
const GetPrayerTimesResponse$json = {
  '1': 'GetPrayerTimesResponse',
  '2': [
    {'1': 'date', '3': 1, '4': 1, '5': 9, '10': 'date'},
    {'1': 'timezone', '3': 2, '4': 1, '5': 9, '10': 'timezone'},
    {
      '1': 'fajr',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.rushd.prayer.v1.PrayerTime',
      '10': 'fajr'
    },
    {
      '1': 'sunrise',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.rushd.prayer.v1.PrayerTime',
      '10': 'sunrise'
    },
    {
      '1': 'dhuhr',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.rushd.prayer.v1.PrayerTime',
      '10': 'dhuhr'
    },
    {
      '1': 'asr',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.rushd.prayer.v1.PrayerTime',
      '10': 'asr'
    },
    {
      '1': 'maghrib',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.rushd.prayer.v1.PrayerTime',
      '10': 'maghrib'
    },
    {
      '1': 'isha',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.rushd.prayer.v1.PrayerTime',
      '10': 'isha'
    },
  ],
};

/// Descriptor for `GetPrayerTimesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPrayerTimesResponseDescriptor = $convert.base64Decode(
    'ChZHZXRQcmF5ZXJUaW1lc1Jlc3BvbnNlEhIKBGRhdGUYASABKAlSBGRhdGUSGgoIdGltZXpvbm'
    'UYAiABKAlSCHRpbWV6b25lEi8KBGZhanIYAyABKAsyGy5ydXNoZC5wcmF5ZXIudjEuUHJheWVy'
    'VGltZVIEZmFqchI1CgdzdW5yaXNlGAQgASgLMhsucnVzaGQucHJheWVyLnYxLlByYXllclRpbW'
    'VSB3N1bnJpc2USMQoFZGh1aHIYBSABKAsyGy5ydXNoZC5wcmF5ZXIudjEuUHJheWVyVGltZVIF'
    'ZGh1aHISLQoDYXNyGAYgASgLMhsucnVzaGQucHJheWVyLnYxLlByYXllclRpbWVSA2FzchI1Cg'
    'dtYWdocmliGAcgASgLMhsucnVzaGQucHJheWVyLnYxLlByYXllclRpbWVSB21hZ2hyaWISLwoE'
    'aXNoYRgIIAEoCzIbLnJ1c2hkLnByYXllci52MS5QcmF5ZXJUaW1lUgRpc2hh');

@$core.Deprecated('Use prayerTimeDescriptor instead')
const PrayerTime$json = {
  '1': 'PrayerTime',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'arabic_name', '3': 2, '4': 1, '5': 9, '10': 'arabicName'},
    {'1': 'time', '3': 3, '4': 1, '5': 9, '10': 'time'},
    {'1': 'iso_datetime', '3': 4, '4': 1, '5': 9, '10': 'isoDatetime'},
  ],
};

/// Descriptor for `PrayerTime`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List prayerTimeDescriptor = $convert.base64Decode(
    'CgpQcmF5ZXJUaW1lEhIKBG5hbWUYASABKAlSBG5hbWUSHwoLYXJhYmljX25hbWUYAiABKAlSCm'
    'FyYWJpY05hbWUSEgoEdGltZRgDIAEoCVIEdGltZRIhCgxpc29fZGF0ZXRpbWUYBCABKAlSC2lz'
    'b0RhdGV0aW1l');
