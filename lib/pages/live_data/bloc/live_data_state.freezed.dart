// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'live_data_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$LiveDataStateTearOff {
  const _$LiveDataStateTearOff();

  _LiveDataState call(
      {bool isRunning = false,
      required DateTime tripStart,
      int tripSeconds = 0,
      required TripRecord tripRecord,
      Position? lastPosition,
      bool isLocalMode = false,
      double acceleration = 0,
      double maxAcceleration = 0,
      bool isConnecting = true,
      bool isDisconnecting = false,
      List<String> supportedPids = const [],
      required PidsChecker pidsChecker,
      String vin = '',
      FuelSystemStatus fuelSystemStatus = FuelSystemStatus.motorOff,
      String userAccelerometer = '',
      double temperature = 0.0,
      bool isTemperatureAvaliable = false,
      List<String> errors = const []}) {
    return _LiveDataState(
      isRunning: isRunning,
      tripStart: tripStart,
      tripSeconds: tripSeconds,
      tripRecord: tripRecord,
      lastPosition: lastPosition,
      isLocalMode: isLocalMode,
      acceleration: acceleration,
      maxAcceleration: maxAcceleration,
      isConnecting: isConnecting,
      isDisconnecting: isDisconnecting,
      supportedPids: supportedPids,
      pidsChecker: pidsChecker,
      vin: vin,
      fuelSystemStatus: fuelSystemStatus,
      userAccelerometer: userAccelerometer,
      temperature: temperature,
      isTemperatureAvaliable: isTemperatureAvaliable,
      errors: errors,
    );
  }
}

/// @nodoc
const $LiveDataState = _$LiveDataStateTearOff();

/// @nodoc
mixin _$LiveDataState {
// Live data
  bool get isRunning => throw _privateConstructorUsedError;
  DateTime get tripStart => throw _privateConstructorUsedError;
  int get tripSeconds => throw _privateConstructorUsedError;
  TripRecord get tripRecord => throw _privateConstructorUsedError;
  Position? get lastPosition => throw _privateConstructorUsedError;
  bool get isLocalMode => throw _privateConstructorUsedError;
  double get acceleration => throw _privateConstructorUsedError;
  double get maxAcceleration => throw _privateConstructorUsedError; // Bluetooth
  bool get isConnecting => throw _privateConstructorUsedError;
  bool get isDisconnecting => throw _privateConstructorUsedError; // Pids
  List<String> get supportedPids => throw _privateConstructorUsedError;
  PidsChecker get pidsChecker => throw _privateConstructorUsedError;
  String get vin => throw _privateConstructorUsedError;
  FuelSystemStatus get fuelSystemStatus =>
      throw _privateConstructorUsedError; // Sensors
  String get userAccelerometer => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  bool get isTemperatureAvaliable =>
      throw _privateConstructorUsedError; // Errors
  List<String> get errors => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LiveDataStateCopyWith<LiveDataState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiveDataStateCopyWith<$Res> {
  factory $LiveDataStateCopyWith(
          LiveDataState value, $Res Function(LiveDataState) then) =
      _$LiveDataStateCopyWithImpl<$Res>;
  $Res call(
      {bool isRunning,
      DateTime tripStart,
      int tripSeconds,
      TripRecord tripRecord,
      Position? lastPosition,
      bool isLocalMode,
      double acceleration,
      double maxAcceleration,
      bool isConnecting,
      bool isDisconnecting,
      List<String> supportedPids,
      PidsChecker pidsChecker,
      String vin,
      FuelSystemStatus fuelSystemStatus,
      String userAccelerometer,
      double temperature,
      bool isTemperatureAvaliable,
      List<String> errors});

  $TripRecordCopyWith<$Res> get tripRecord;
  $PidsCheckerCopyWith<$Res> get pidsChecker;
}

/// @nodoc
class _$LiveDataStateCopyWithImpl<$Res>
    implements $LiveDataStateCopyWith<$Res> {
  _$LiveDataStateCopyWithImpl(this._value, this._then);

  final LiveDataState _value;
  // ignore: unused_field
  final $Res Function(LiveDataState) _then;

  @override
  $Res call({
    Object? isRunning = freezed,
    Object? tripStart = freezed,
    Object? tripSeconds = freezed,
    Object? tripRecord = freezed,
    Object? lastPosition = freezed,
    Object? isLocalMode = freezed,
    Object? acceleration = freezed,
    Object? maxAcceleration = freezed,
    Object? isConnecting = freezed,
    Object? isDisconnecting = freezed,
    Object? supportedPids = freezed,
    Object? pidsChecker = freezed,
    Object? vin = freezed,
    Object? fuelSystemStatus = freezed,
    Object? userAccelerometer = freezed,
    Object? temperature = freezed,
    Object? isTemperatureAvaliable = freezed,
    Object? errors = freezed,
  }) {
    return _then(_value.copyWith(
      isRunning: isRunning == freezed
          ? _value.isRunning
          : isRunning // ignore: cast_nullable_to_non_nullable
              as bool,
      tripStart: tripStart == freezed
          ? _value.tripStart
          : tripStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tripSeconds: tripSeconds == freezed
          ? _value.tripSeconds
          : tripSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      tripRecord: tripRecord == freezed
          ? _value.tripRecord
          : tripRecord // ignore: cast_nullable_to_non_nullable
              as TripRecord,
      lastPosition: lastPosition == freezed
          ? _value.lastPosition
          : lastPosition // ignore: cast_nullable_to_non_nullable
              as Position?,
      isLocalMode: isLocalMode == freezed
          ? _value.isLocalMode
          : isLocalMode // ignore: cast_nullable_to_non_nullable
              as bool,
      acceleration: acceleration == freezed
          ? _value.acceleration
          : acceleration // ignore: cast_nullable_to_non_nullable
              as double,
      maxAcceleration: maxAcceleration == freezed
          ? _value.maxAcceleration
          : maxAcceleration // ignore: cast_nullable_to_non_nullable
              as double,
      isConnecting: isConnecting == freezed
          ? _value.isConnecting
          : isConnecting // ignore: cast_nullable_to_non_nullable
              as bool,
      isDisconnecting: isDisconnecting == freezed
          ? _value.isDisconnecting
          : isDisconnecting // ignore: cast_nullable_to_non_nullable
              as bool,
      supportedPids: supportedPids == freezed
          ? _value.supportedPids
          : supportedPids // ignore: cast_nullable_to_non_nullable
              as List<String>,
      pidsChecker: pidsChecker == freezed
          ? _value.pidsChecker
          : pidsChecker // ignore: cast_nullable_to_non_nullable
              as PidsChecker,
      vin: vin == freezed
          ? _value.vin
          : vin // ignore: cast_nullable_to_non_nullable
              as String,
      fuelSystemStatus: fuelSystemStatus == freezed
          ? _value.fuelSystemStatus
          : fuelSystemStatus // ignore: cast_nullable_to_non_nullable
              as FuelSystemStatus,
      userAccelerometer: userAccelerometer == freezed
          ? _value.userAccelerometer
          : userAccelerometer // ignore: cast_nullable_to_non_nullable
              as String,
      temperature: temperature == freezed
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      isTemperatureAvaliable: isTemperatureAvaliable == freezed
          ? _value.isTemperatureAvaliable
          : isTemperatureAvaliable // ignore: cast_nullable_to_non_nullable
              as bool,
      errors: errors == freezed
          ? _value.errors
          : errors // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }

  @override
  $TripRecordCopyWith<$Res> get tripRecord {
    return $TripRecordCopyWith<$Res>(_value.tripRecord, (value) {
      return _then(_value.copyWith(tripRecord: value));
    });
  }

  @override
  $PidsCheckerCopyWith<$Res> get pidsChecker {
    return $PidsCheckerCopyWith<$Res>(_value.pidsChecker, (value) {
      return _then(_value.copyWith(pidsChecker: value));
    });
  }
}

/// @nodoc
abstract class _$LiveDataStateCopyWith<$Res>
    implements $LiveDataStateCopyWith<$Res> {
  factory _$LiveDataStateCopyWith(
          _LiveDataState value, $Res Function(_LiveDataState) then) =
      __$LiveDataStateCopyWithImpl<$Res>;
  @override
  $Res call(
      {bool isRunning,
      DateTime tripStart,
      int tripSeconds,
      TripRecord tripRecord,
      Position? lastPosition,
      bool isLocalMode,
      double acceleration,
      double maxAcceleration,
      bool isConnecting,
      bool isDisconnecting,
      List<String> supportedPids,
      PidsChecker pidsChecker,
      String vin,
      FuelSystemStatus fuelSystemStatus,
      String userAccelerometer,
      double temperature,
      bool isTemperatureAvaliable,
      List<String> errors});

  @override
  $TripRecordCopyWith<$Res> get tripRecord;
  @override
  $PidsCheckerCopyWith<$Res> get pidsChecker;
}

/// @nodoc
class __$LiveDataStateCopyWithImpl<$Res>
    extends _$LiveDataStateCopyWithImpl<$Res>
    implements _$LiveDataStateCopyWith<$Res> {
  __$LiveDataStateCopyWithImpl(
      _LiveDataState _value, $Res Function(_LiveDataState) _then)
      : super(_value, (v) => _then(v as _LiveDataState));

  @override
  _LiveDataState get _value => super._value as _LiveDataState;

  @override
  $Res call({
    Object? isRunning = freezed,
    Object? tripStart = freezed,
    Object? tripSeconds = freezed,
    Object? tripRecord = freezed,
    Object? lastPosition = freezed,
    Object? isLocalMode = freezed,
    Object? acceleration = freezed,
    Object? maxAcceleration = freezed,
    Object? isConnecting = freezed,
    Object? isDisconnecting = freezed,
    Object? supportedPids = freezed,
    Object? pidsChecker = freezed,
    Object? vin = freezed,
    Object? fuelSystemStatus = freezed,
    Object? userAccelerometer = freezed,
    Object? temperature = freezed,
    Object? isTemperatureAvaliable = freezed,
    Object? errors = freezed,
  }) {
    return _then(_LiveDataState(
      isRunning: isRunning == freezed
          ? _value.isRunning
          : isRunning // ignore: cast_nullable_to_non_nullable
              as bool,
      tripStart: tripStart == freezed
          ? _value.tripStart
          : tripStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tripSeconds: tripSeconds == freezed
          ? _value.tripSeconds
          : tripSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      tripRecord: tripRecord == freezed
          ? _value.tripRecord
          : tripRecord // ignore: cast_nullable_to_non_nullable
              as TripRecord,
      lastPosition: lastPosition == freezed
          ? _value.lastPosition
          : lastPosition // ignore: cast_nullable_to_non_nullable
              as Position?,
      isLocalMode: isLocalMode == freezed
          ? _value.isLocalMode
          : isLocalMode // ignore: cast_nullable_to_non_nullable
              as bool,
      acceleration: acceleration == freezed
          ? _value.acceleration
          : acceleration // ignore: cast_nullable_to_non_nullable
              as double,
      maxAcceleration: maxAcceleration == freezed
          ? _value.maxAcceleration
          : maxAcceleration // ignore: cast_nullable_to_non_nullable
              as double,
      isConnecting: isConnecting == freezed
          ? _value.isConnecting
          : isConnecting // ignore: cast_nullable_to_non_nullable
              as bool,
      isDisconnecting: isDisconnecting == freezed
          ? _value.isDisconnecting
          : isDisconnecting // ignore: cast_nullable_to_non_nullable
              as bool,
      supportedPids: supportedPids == freezed
          ? _value.supportedPids
          : supportedPids // ignore: cast_nullable_to_non_nullable
              as List<String>,
      pidsChecker: pidsChecker == freezed
          ? _value.pidsChecker
          : pidsChecker // ignore: cast_nullable_to_non_nullable
              as PidsChecker,
      vin: vin == freezed
          ? _value.vin
          : vin // ignore: cast_nullable_to_non_nullable
              as String,
      fuelSystemStatus: fuelSystemStatus == freezed
          ? _value.fuelSystemStatus
          : fuelSystemStatus // ignore: cast_nullable_to_non_nullable
              as FuelSystemStatus,
      userAccelerometer: userAccelerometer == freezed
          ? _value.userAccelerometer
          : userAccelerometer // ignore: cast_nullable_to_non_nullable
              as String,
      temperature: temperature == freezed
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      isTemperatureAvaliable: isTemperatureAvaliable == freezed
          ? _value.isTemperatureAvaliable
          : isTemperatureAvaliable // ignore: cast_nullable_to_non_nullable
              as bool,
      errors: errors == freezed
          ? _value.errors
          : errors // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$_LiveDataState implements _LiveDataState {
  _$_LiveDataState(
      {this.isRunning = false,
      required this.tripStart,
      this.tripSeconds = 0,
      required this.tripRecord,
      this.lastPosition,
      this.isLocalMode = false,
      this.acceleration = 0,
      this.maxAcceleration = 0,
      this.isConnecting = true,
      this.isDisconnecting = false,
      this.supportedPids = const [],
      required this.pidsChecker,
      this.vin = '',
      this.fuelSystemStatus = FuelSystemStatus.motorOff,
      this.userAccelerometer = '',
      this.temperature = 0.0,
      this.isTemperatureAvaliable = false,
      this.errors = const []});

  @JsonKey(defaultValue: false)
  @override // Live data
  final bool isRunning;
  @override
  final DateTime tripStart;
  @JsonKey(defaultValue: 0)
  @override
  final int tripSeconds;
  @override
  final TripRecord tripRecord;
  @override
  final Position? lastPosition;
  @JsonKey(defaultValue: false)
  @override
  final bool isLocalMode;
  @JsonKey(defaultValue: 0)
  @override
  final double acceleration;
  @JsonKey(defaultValue: 0)
  @override
  final double maxAcceleration;
  @JsonKey(defaultValue: true)
  @override // Bluetooth
  final bool isConnecting;
  @JsonKey(defaultValue: false)
  @override
  final bool isDisconnecting;
  @JsonKey(defaultValue: const [])
  @override // Pids
  final List<String> supportedPids;
  @override
  final PidsChecker pidsChecker;
  @JsonKey(defaultValue: '')
  @override
  final String vin;
  @JsonKey(defaultValue: FuelSystemStatus.motorOff)
  @override
  final FuelSystemStatus fuelSystemStatus;
  @JsonKey(defaultValue: '')
  @override // Sensors
  final String userAccelerometer;
  @JsonKey(defaultValue: 0.0)
  @override
  final double temperature;
  @JsonKey(defaultValue: false)
  @override
  final bool isTemperatureAvaliable;
  @JsonKey(defaultValue: const [])
  @override // Errors
  final List<String> errors;

  @override
  String toString() {
    return 'LiveDataState(isRunning: $isRunning, tripStart: $tripStart, tripSeconds: $tripSeconds, tripRecord: $tripRecord, lastPosition: $lastPosition, isLocalMode: $isLocalMode, acceleration: $acceleration, maxAcceleration: $maxAcceleration, isConnecting: $isConnecting, isDisconnecting: $isDisconnecting, supportedPids: $supportedPids, pidsChecker: $pidsChecker, vin: $vin, fuelSystemStatus: $fuelSystemStatus, userAccelerometer: $userAccelerometer, temperature: $temperature, isTemperatureAvaliable: $isTemperatureAvaliable, errors: $errors)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LiveDataState &&
            (identical(other.isRunning, isRunning) ||
                other.isRunning == isRunning) &&
            (identical(other.tripStart, tripStart) ||
                other.tripStart == tripStart) &&
            (identical(other.tripSeconds, tripSeconds) ||
                other.tripSeconds == tripSeconds) &&
            (identical(other.tripRecord, tripRecord) ||
                other.tripRecord == tripRecord) &&
            (identical(other.lastPosition, lastPosition) ||
                other.lastPosition == lastPosition) &&
            (identical(other.isLocalMode, isLocalMode) ||
                other.isLocalMode == isLocalMode) &&
            (identical(other.acceleration, acceleration) ||
                other.acceleration == acceleration) &&
            (identical(other.maxAcceleration, maxAcceleration) ||
                other.maxAcceleration == maxAcceleration) &&
            (identical(other.isConnecting, isConnecting) ||
                other.isConnecting == isConnecting) &&
            (identical(other.isDisconnecting, isDisconnecting) ||
                other.isDisconnecting == isDisconnecting) &&
            const DeepCollectionEquality()
                .equals(other.supportedPids, supportedPids) &&
            (identical(other.pidsChecker, pidsChecker) ||
                other.pidsChecker == pidsChecker) &&
            (identical(other.vin, vin) || other.vin == vin) &&
            (identical(other.fuelSystemStatus, fuelSystemStatus) ||
                other.fuelSystemStatus == fuelSystemStatus) &&
            (identical(other.userAccelerometer, userAccelerometer) ||
                other.userAccelerometer == userAccelerometer) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.isTemperatureAvaliable, isTemperatureAvaliable) ||
                other.isTemperatureAvaliable == isTemperatureAvaliable) &&
            const DeepCollectionEquality().equals(other.errors, errors));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isRunning,
      tripStart,
      tripSeconds,
      tripRecord,
      lastPosition,
      isLocalMode,
      acceleration,
      maxAcceleration,
      isConnecting,
      isDisconnecting,
      const DeepCollectionEquality().hash(supportedPids),
      pidsChecker,
      vin,
      fuelSystemStatus,
      userAccelerometer,
      temperature,
      isTemperatureAvaliable,
      const DeepCollectionEquality().hash(errors));

  @JsonKey(ignore: true)
  @override
  _$LiveDataStateCopyWith<_LiveDataState> get copyWith =>
      __$LiveDataStateCopyWithImpl<_LiveDataState>(this, _$identity);
}

abstract class _LiveDataState implements LiveDataState {
  factory _LiveDataState(
      {bool isRunning,
      required DateTime tripStart,
      int tripSeconds,
      required TripRecord tripRecord,
      Position? lastPosition,
      bool isLocalMode,
      double acceleration,
      double maxAcceleration,
      bool isConnecting,
      bool isDisconnecting,
      List<String> supportedPids,
      required PidsChecker pidsChecker,
      String vin,
      FuelSystemStatus fuelSystemStatus,
      String userAccelerometer,
      double temperature,
      bool isTemperatureAvaliable,
      List<String> errors}) = _$_LiveDataState;

  @override // Live data
  bool get isRunning;
  @override
  DateTime get tripStart;
  @override
  int get tripSeconds;
  @override
  TripRecord get tripRecord;
  @override
  Position? get lastPosition;
  @override
  bool get isLocalMode;
  @override
  double get acceleration;
  @override
  double get maxAcceleration;
  @override // Bluetooth
  bool get isConnecting;
  @override
  bool get isDisconnecting;
  @override // Pids
  List<String> get supportedPids;
  @override
  PidsChecker get pidsChecker;
  @override
  String get vin;
  @override
  FuelSystemStatus get fuelSystemStatus;
  @override // Sensors
  String get userAccelerometer;
  @override
  double get temperature;
  @override
  bool get isTemperatureAvaliable;
  @override // Errors
  List<String> get errors;
  @override
  @JsonKey(ignore: true)
  _$LiveDataStateCopyWith<_LiveDataState> get copyWith =>
      throw _privateConstructorUsedError;
}
