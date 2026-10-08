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

class CalculationMethod extends $pb.ProtobufEnum {
  static const CalculationMethod CALCULATION_METHOD_UNSPECIFIED =
      CalculationMethod._(
          0, _omitEnumNames ? '' : 'CALCULATION_METHOD_UNSPECIFIED');
  static const CalculationMethod MUSLIM_WORLD_LEAGUE =
      CalculationMethod._(1, _omitEnumNames ? '' : 'MUSLIM_WORLD_LEAGUE');
  static const CalculationMethod EGYPTIAN =
      CalculationMethod._(2, _omitEnumNames ? '' : 'EGYPTIAN');
  static const CalculationMethod KARACHI =
      CalculationMethod._(3, _omitEnumNames ? '' : 'KARACHI');
  static const CalculationMethod UMM_AL_QURA =
      CalculationMethod._(4, _omitEnumNames ? '' : 'UMM_AL_QURA');
  static const CalculationMethod DUBAI =
      CalculationMethod._(5, _omitEnumNames ? '' : 'DUBAI');
  static const CalculationMethod MOON_SIGHTING_COMMITTEE =
      CalculationMethod._(6, _omitEnumNames ? '' : 'MOON_SIGHTING_COMMITTEE');
  static const CalculationMethod NORTH_AMERICA =
      CalculationMethod._(7, _omitEnumNames ? '' : 'NORTH_AMERICA');
  static const CalculationMethod KUWAIT =
      CalculationMethod._(8, _omitEnumNames ? '' : 'KUWAIT');
  static const CalculationMethod QATAR =
      CalculationMethod._(9, _omitEnumNames ? '' : 'QATAR');
  static const CalculationMethod SINGAPORE =
      CalculationMethod._(10, _omitEnumNames ? '' : 'SINGAPORE');

  static const $core.List<CalculationMethod> values = <CalculationMethod>[
    CALCULATION_METHOD_UNSPECIFIED,
    MUSLIM_WORLD_LEAGUE,
    EGYPTIAN,
    KARACHI,
    UMM_AL_QURA,
    DUBAI,
    MOON_SIGHTING_COMMITTEE,
    NORTH_AMERICA,
    KUWAIT,
    QATAR,
    SINGAPORE,
  ];

  static final $core.List<CalculationMethod?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 10);
  static CalculationMethod? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CalculationMethod._(super.value, super.name);
}

class Madhab extends $pb.ProtobufEnum {
  static const Madhab MADHAB_UNSPECIFIED =
      Madhab._(0, _omitEnumNames ? '' : 'MADHAB_UNSPECIFIED');
  static const Madhab SHAFI = Madhab._(1, _omitEnumNames ? '' : 'SHAFI');
  static const Madhab HANAFI = Madhab._(2, _omitEnumNames ? '' : 'HANAFI');

  static const $core.List<Madhab> values = <Madhab>[
    MADHAB_UNSPECIFIED,
    SHAFI,
    HANAFI,
  ];

  static final $core.List<Madhab?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Madhab? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Madhab._(super.value, super.name);
}

class HighLatitudeRule extends $pb.ProtobufEnum {
  static const HighLatitudeRule HIGH_LATITUDE_RULE_UNSPECIFIED =
      HighLatitudeRule._(
          0, _omitEnumNames ? '' : 'HIGH_LATITUDE_RULE_UNSPECIFIED');
  static const HighLatitudeRule MIDDLE_OF_THE_NIGHT =
      HighLatitudeRule._(1, _omitEnumNames ? '' : 'MIDDLE_OF_THE_NIGHT');
  static const HighLatitudeRule SEVENTH_OF_THE_NIGHT =
      HighLatitudeRule._(2, _omitEnumNames ? '' : 'SEVENTH_OF_THE_NIGHT');
  static const HighLatitudeRule TWILIGHT_ANGLE =
      HighLatitudeRule._(3, _omitEnumNames ? '' : 'TWILIGHT_ANGLE');

  static const $core.List<HighLatitudeRule> values = <HighLatitudeRule>[
    HIGH_LATITUDE_RULE_UNSPECIFIED,
    MIDDLE_OF_THE_NIGHT,
    SEVENTH_OF_THE_NIGHT,
    TWILIGHT_ANGLE,
  ];

  static final $core.List<HighLatitudeRule?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static HighLatitudeRule? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const HighLatitudeRule._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
