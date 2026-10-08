// This is a generated file - do not edit.
//
// Generated from prayer/v1/prayer.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'prayer.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'prayer.pbenum.dart';

class GetPrayerTimesRequest extends $pb.GeneratedMessage {
  factory GetPrayerTimesRequest({
    $core.double? latitude,
    $core.double? longitude,
    $core.String? timezone,
    $core.String? date,
    CalculationSettings? calculation,
  }) {
    final result = GetPrayerTimesRequest._();
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (timezone != null) result.timezone = timezone;
    if (date != null) result.date = date;
    if (calculation != null) result.calculation = calculation;
    return result;
  }

  GetPrayerTimesRequest._();

  factory GetPrayerTimesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPrayerTimesRequest()..mergeFromBuffer(data, registry);
  factory GetPrayerTimesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPrayerTimesRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPrayerTimesRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'rushd.prayer.v1'),
      createEmptyInstance: GetPrayerTimesRequest.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'latitude')
    ..aD(2, _omitFieldNames ? '' : 'longitude')
    ..aOS(3, _omitFieldNames ? '' : 'timezone')
    ..aOS(4, _omitFieldNames ? '' : 'date')
    ..aOM<CalculationSettings>(5, _omitFieldNames ? '' : 'calculation',
        subBuilder: CalculationSettings.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPrayerTimesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPrayerTimesRequest copyWith(
          void Function(GetPrayerTimesRequest) updates) =>
      super.copyWith((message) => updates(message as GetPrayerTimesRequest))
          as GetPrayerTimesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetPrayerTimesRequest() / GetPrayerTimesRequest.new instead')
  static GetPrayerTimesRequest create() => GetPrayerTimesRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetPrayerTimesRequest._();
  @$core.override
  GetPrayerTimesRequest createEmptyInstance() => GetPrayerTimesRequest._();
  @$core.pragma('dart2js:noInline')
  static GetPrayerTimesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPrayerTimesRequest>(
          GetPrayerTimesRequest.$_createMessage);
  static GetPrayerTimesRequest? _defaultInstance;

  /// Geographic latitude.
  @$pb.TagNumber(1)
  $core.double get latitude => $_getN(0);
  @$pb.TagNumber(1)
  set latitude($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLatitude() => $_has(0);
  @$pb.TagNumber(1)
  void clearLatitude() => $_clearField(1);

  /// Geographic longitude.
  @$pb.TagNumber(2)
  $core.double get longitude => $_getN(1);
  @$pb.TagNumber(2)
  set longitude($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLongitude() => $_has(1);
  @$pb.TagNumber(2)
  void clearLongitude() => $_clearField(2);

  /// IANA timezone.
  ///
  /// Example:
  /// Asia/Kolkata
  @$pb.TagNumber(3)
  $core.String get timezone => $_getSZ(2);
  @$pb.TagNumber(3)
  set timezone($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimezone() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimezone() => $_clearField(3);

  /// Gregorian date in YYYY-MM-DD format.
  @$pb.TagNumber(4)
  $core.String get date => $_getSZ(3);
  @$pb.TagNumber(4)
  set date($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearDate() => $_clearField(4);

  /// Prayer calculation configuration.
  @$pb.TagNumber(5)
  CalculationSettings get calculation => $_getN(4);
  @$pb.TagNumber(5)
  set calculation(CalculationSettings value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCalculation() => $_has(4);
  @$pb.TagNumber(5)
  void clearCalculation() => $_clearField(5);
  @$pb.TagNumber(5)
  CalculationSettings ensureCalculation() => $_ensure(4);
}

class CalculationSettings extends $pb.GeneratedMessage {
  factory CalculationSettings({
    CalculationMethod? method,
    Madhab? madhab,
    HighLatitudeRule? highLatitudeRule,
  }) {
    final result = CalculationSettings._();
    if (method != null) result.method = method;
    if (madhab != null) result.madhab = madhab;
    if (highLatitudeRule != null) result.highLatitudeRule = highLatitudeRule;
    return result;
  }

  CalculationSettings._();

  factory CalculationSettings.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalculationSettings()..mergeFromBuffer(data, registry);
  factory CalculationSettings.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CalculationSettings()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalculationSettings',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'rushd.prayer.v1'),
      createEmptyInstance: CalculationSettings.$_createMessage)
    ..aE<CalculationMethod>(1, _omitFieldNames ? '' : 'method',
        enumValues: CalculationMethod.values)
    ..aE<Madhab>(2, _omitFieldNames ? '' : 'madhab', enumValues: Madhab.values)
    ..aE<HighLatitudeRule>(3, _omitFieldNames ? '' : 'highLatitudeRule',
        enumValues: HighLatitudeRule.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalculationSettings clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalculationSettings copyWith(void Function(CalculationSettings) updates) =>
      super.copyWith((message) => updates(message as CalculationSettings))
          as CalculationSettings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use CalculationSettings() / CalculationSettings.new instead')
  static CalculationSettings create() => CalculationSettings._();
  static $pb.GeneratedMessage $_createMessage() => CalculationSettings._();
  @$core.override
  CalculationSettings createEmptyInstance() => CalculationSettings._();
  @$core.pragma('dart2js:noInline')
  static CalculationSettings getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalculationSettings>(
          CalculationSettings.$_createMessage);
  static CalculationSettings? _defaultInstance;

  @$pb.TagNumber(1)
  CalculationMethod get method => $_getN(0);
  @$pb.TagNumber(1)
  set method(CalculationMethod value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMethod() => $_has(0);
  @$pb.TagNumber(1)
  void clearMethod() => $_clearField(1);

  @$pb.TagNumber(2)
  Madhab get madhab => $_getN(1);
  @$pb.TagNumber(2)
  set madhab(Madhab value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMadhab() => $_has(1);
  @$pb.TagNumber(2)
  void clearMadhab() => $_clearField(2);

  @$pb.TagNumber(3)
  HighLatitudeRule get highLatitudeRule => $_getN(2);
  @$pb.TagNumber(3)
  set highLatitudeRule(HighLatitudeRule value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasHighLatitudeRule() => $_has(2);
  @$pb.TagNumber(3)
  void clearHighLatitudeRule() => $_clearField(3);
}

class GetPrayerTimesResponse extends $pb.GeneratedMessage {
  factory GetPrayerTimesResponse({
    $core.String? date,
    $core.String? timezone,
    PrayerTime? fajr,
    PrayerTime? sunrise,
    PrayerTime? dhuhr,
    PrayerTime? asr,
    PrayerTime? maghrib,
    PrayerTime? isha,
  }) {
    final result = GetPrayerTimesResponse._();
    if (date != null) result.date = date;
    if (timezone != null) result.timezone = timezone;
    if (fajr != null) result.fajr = fajr;
    if (sunrise != null) result.sunrise = sunrise;
    if (dhuhr != null) result.dhuhr = dhuhr;
    if (asr != null) result.asr = asr;
    if (maghrib != null) result.maghrib = maghrib;
    if (isha != null) result.isha = isha;
    return result;
  }

  GetPrayerTimesResponse._();

  factory GetPrayerTimesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPrayerTimesResponse()..mergeFromBuffer(data, registry);
  factory GetPrayerTimesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetPrayerTimesResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPrayerTimesResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'rushd.prayer.v1'),
      createEmptyInstance: GetPrayerTimesResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'date')
    ..aOS(2, _omitFieldNames ? '' : 'timezone')
    ..aOM<PrayerTime>(3, _omitFieldNames ? '' : 'fajr',
        subBuilder: PrayerTime.$_createMessage)
    ..aOM<PrayerTime>(4, _omitFieldNames ? '' : 'sunrise',
        subBuilder: PrayerTime.$_createMessage)
    ..aOM<PrayerTime>(5, _omitFieldNames ? '' : 'dhuhr',
        subBuilder: PrayerTime.$_createMessage)
    ..aOM<PrayerTime>(6, _omitFieldNames ? '' : 'asr',
        subBuilder: PrayerTime.$_createMessage)
    ..aOM<PrayerTime>(7, _omitFieldNames ? '' : 'maghrib',
        subBuilder: PrayerTime.$_createMessage)
    ..aOM<PrayerTime>(8, _omitFieldNames ? '' : 'isha',
        subBuilder: PrayerTime.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPrayerTimesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPrayerTimesResponse copyWith(
          void Function(GetPrayerTimesResponse) updates) =>
      super.copyWith((message) => updates(message as GetPrayerTimesResponse))
          as GetPrayerTimesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetPrayerTimesResponse() / GetPrayerTimesResponse.new instead')
  static GetPrayerTimesResponse create() => GetPrayerTimesResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetPrayerTimesResponse._();
  @$core.override
  GetPrayerTimesResponse createEmptyInstance() => GetPrayerTimesResponse._();
  @$core.pragma('dart2js:noInline')
  static GetPrayerTimesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPrayerTimesResponse>(
          GetPrayerTimesResponse.$_createMessage);
  static GetPrayerTimesResponse? _defaultInstance;

  /// Requested date.
  @$pb.TagNumber(1)
  $core.String get date => $_getSZ(0);
  @$pb.TagNumber(1)
  set date($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearDate() => $_clearField(1);

  /// Timezone used for calculation.
  @$pb.TagNumber(2)
  $core.String get timezone => $_getSZ(1);
  @$pb.TagNumber(2)
  set timezone($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimezone() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimezone() => $_clearField(2);

  @$pb.TagNumber(3)
  PrayerTime get fajr => $_getN(2);
  @$pb.TagNumber(3)
  set fajr(PrayerTime value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasFajr() => $_has(2);
  @$pb.TagNumber(3)
  void clearFajr() => $_clearField(3);
  @$pb.TagNumber(3)
  PrayerTime ensureFajr() => $_ensure(2);

  @$pb.TagNumber(4)
  PrayerTime get sunrise => $_getN(3);
  @$pb.TagNumber(4)
  set sunrise(PrayerTime value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSunrise() => $_has(3);
  @$pb.TagNumber(4)
  void clearSunrise() => $_clearField(4);
  @$pb.TagNumber(4)
  PrayerTime ensureSunrise() => $_ensure(3);

  @$pb.TagNumber(5)
  PrayerTime get dhuhr => $_getN(4);
  @$pb.TagNumber(5)
  set dhuhr(PrayerTime value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasDhuhr() => $_has(4);
  @$pb.TagNumber(5)
  void clearDhuhr() => $_clearField(5);
  @$pb.TagNumber(5)
  PrayerTime ensureDhuhr() => $_ensure(4);

  @$pb.TagNumber(6)
  PrayerTime get asr => $_getN(5);
  @$pb.TagNumber(6)
  set asr(PrayerTime value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasAsr() => $_has(5);
  @$pb.TagNumber(6)
  void clearAsr() => $_clearField(6);
  @$pb.TagNumber(6)
  PrayerTime ensureAsr() => $_ensure(5);

  @$pb.TagNumber(7)
  PrayerTime get maghrib => $_getN(6);
  @$pb.TagNumber(7)
  set maghrib(PrayerTime value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasMaghrib() => $_has(6);
  @$pb.TagNumber(7)
  void clearMaghrib() => $_clearField(7);
  @$pb.TagNumber(7)
  PrayerTime ensureMaghrib() => $_ensure(6);

  @$pb.TagNumber(8)
  PrayerTime get isha => $_getN(7);
  @$pb.TagNumber(8)
  set isha(PrayerTime value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasIsha() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsha() => $_clearField(8);
  @$pb.TagNumber(8)
  PrayerTime ensureIsha() => $_ensure(7);
}

class PrayerTime extends $pb.GeneratedMessage {
  factory PrayerTime({
    $core.String? name,
    $core.String? arabicName,
    $core.String? time,
    $core.String? isoDatetime,
  }) {
    final result = PrayerTime._();
    if (name != null) result.name = name;
    if (arabicName != null) result.arabicName = arabicName;
    if (time != null) result.time = time;
    if (isoDatetime != null) result.isoDatetime = isoDatetime;
    return result;
  }

  PrayerTime._();

  factory PrayerTime.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrayerTime()..mergeFromBuffer(data, registry);
  factory PrayerTime.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrayerTime()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PrayerTime',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'rushd.prayer.v1'),
      createEmptyInstance: PrayerTime.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'arabicName')
    ..aOS(3, _omitFieldNames ? '' : 'time')
    ..aOS(4, _omitFieldNames ? '' : 'isoDatetime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrayerTime clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrayerTime copyWith(void Function(PrayerTime) updates) =>
      super.copyWith((message) => updates(message as PrayerTime)) as PrayerTime;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PrayerTime() / PrayerTime.new instead')
  static PrayerTime create() => PrayerTime._();
  static $pb.GeneratedMessage $_createMessage() => PrayerTime._();
  @$core.override
  PrayerTime createEmptyInstance() => PrayerTime._();
  @$core.pragma('dart2js:noInline')
  static PrayerTime getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PrayerTime>(PrayerTime.$_createMessage);
  static PrayerTime? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get arabicName => $_getSZ(1);
  @$pb.TagNumber(2)
  set arabicName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasArabicName() => $_has(1);
  @$pb.TagNumber(2)
  void clearArabicName() => $_clearField(2);

  /// Local display time.
  /// Example: 05:02 AM
  @$pb.TagNumber(3)
  $core.String get time => $_getSZ(2);
  @$pb.TagNumber(3)
  set time($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearTime() => $_clearField(3);

  /// Complete local timestamp.
  /// Example: 2026-10-07T05:02:00+05:30
  @$pb.TagNumber(4)
  $core.String get isoDatetime => $_getSZ(3);
  @$pb.TagNumber(4)
  set isoDatetime($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsoDatetime() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsoDatetime() => $_clearField(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
