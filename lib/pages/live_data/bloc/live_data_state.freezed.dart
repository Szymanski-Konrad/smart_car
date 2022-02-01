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
      bool throttlePressed = false,
      int currentTimeSpent = 0,
      double currentFuelBurnt = 0,
      TripStatus tripStatus = TripStatus.idle,
      double localTripProgress = 0.0,
      String localData = Constants.defaultLocalFile,
      bool isConnecting = true,
      bool isDisconnecting = false,
      bool isConnnectingError = false,
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
      throttlePressed: throttlePressed,
      currentTimeSpent: currentTimeSpent,
      currentFuelBurnt: currentFuelBurnt,
      tripStatus: tripStatus,
      localTripProgress: localTripProgress,
      localData: localData,
      isConnecting: isConnecting,
      isDisconnecting: isDisconnecting,
      isConnnectingError: isConnnectingError,
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
  bool get throttlePressed => throw _privateConstructorUsedError;
  int get currentTimeSpent => throw _privateConstructorUsedError;
  double get currentFuelBurnt => throw _privateConstructorUsedError;
  TripStatus get tripStatus =>
      throw _privateConstructorUsedError; // Just for testing
  double get localTripProgress => throw _privateConstructorUsedError;
  String get localData => throw _privateConstructorUsedError; // Bluetooth
  bool get isConnecting => throw _privateConstructorUsedError;
  bool get isDisconnecting => throw _privateConstructorUsedError;
  bool get isConnnectingError => throw _privateConstructorUsedError; // Pids
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
      bool throttlePressed,
      int currentTimeSpent,
      double currentFuelBurnt,
      TripStatus tripStatus,
      double localTripProgress,
      String localData,
      bool isConnecting,
      bool isDisconnecting,
      bool isConnnectingError,
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
    Object? throttlePressed = freezed,
    Object? currentTimeSpent = freezed,
    Object? currentFuelBurnt = freezed,
    Object? tripStatus = freezed,
    Object? localTripProgress = freezed,
    Object? localData = freezed,
    Object? isConnecting = freezed,
    Object? isDisconnecting = freezed,
    Object? isConnnectingError = freezed,
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
      throttlePressed: throttlePressed == freezed
          ? _value.throttlePressed
          : throttlePressed // ignore: cast_nullable_to_non_nullable
              as bool,
      currentTimeSpent: currentTimeSpent == freezed
          ? _value.currentTimeSpent
          : currentTimeSpent // ignore: cast_nullable_to_non_nullable
              as int,
      currentFuelBurnt: currentFuelBurnt == freezed
          ? _value.currentFuelBurnt
          : currentFuelBurnt // ignore: cast_nullable_to_non_nullable
              as double,
      tripStatus: tripStatus == freezed
          ? _value.tripStatus
          : tripStatus // ignore: cast_nullable_to_non_nullable
              as TripStatus,
      localTripProgress: localTripProgress == freezed
          ? _value.localTripProgress
          : localTripProgress // ignore: cast_nullable_to_non_nullable
              as double,
      localData: localData == freezed
          ? _value.localData
          : localData // ignore: cast_nullable_to_non_nullable
              as String,
      isConnecting: isConnecting == freezed
          ? _value.isConnecting
          : isConnecting // ignore: cast_nullable_to_non_nullable
              as bool,
      isDisconnecting: isDisconnecting == freezed
          ? _value.isDisconnecting
          : isDisconnecting // ignore: cast_nullable_to_non_nullable
              as bool,
      isConnnectingError: isConnnectingError == freezed
          ? _value.isConnnectingError
          : isConnnectingError // ignore: cast_nullable_to_non_nullable
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
      bool throttlePressed,
      int currentTimeSpent,
      double currentFuelBurnt,
      TripStatus tripStatus,
      double localTripProgress,
      String localData,
      bool isConnecting,
      bool isDisconnecting,
      bool isConnnectingError,
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
    Object? throttlePressed = freezed,
    Object? currentTimeSpent = freezed,
    Object? currentFuelBurnt = freezed,
    Object? tripStatus = freezed,
    Object? localTripProgress = freezed,
    Object? localData = freezed,
    Object? isConnecting = freezed,
    Object? isDisconnecting = freezed,
    Object? isConnnectingError = freezed,
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
      throttlePressed: throttlePressed == freezed
          ? _value.throttlePressed
          : throttlePressed // ignore: cast_nullable_to_non_nullable
              as bool,
      currentTimeSpent: currentTimeSpent == freezed
          ? _value.currentTimeSpent
          : currentTimeSpent // ignore: cast_nullable_to_non_nullable
              as int,
      currentFuelBurnt: currentFuelBurnt == freezed
          ? _value.currentFuelBurnt
          : currentFuelBurnt // ignore: cast_nullable_to_non_nullable
              as double,
      tripStatus: tripStatus == freezed
          ? _value.tripStatus
          : tripStatus // ignore: cast_nullable_to_non_nullable
              as TripStatus,
      localTripProgress: localTripProgress == freezed
          ? _value.localTripProgress
          : localTripProgress // ignore: cast_nullable_to_non_nullable
              as double,
      localData: localData == freezed
          ? _value.localData
          : localData // ignore: cast_nullable_to_non_nullable
              as String,
      isConnecting: isConnecting == freezed
          ? _value.isConnecting
          : isConnecting // ignore: cast_nullable_to_non_nullable
              as bool,
      isDisconnecting: isDisconnecting == freezed
          ? _value.isDisconnecting
          : isDisconnecting // ignore: cast_nullable_to_non_nullable
              as bool,
      isConnnectingError: isConnnectingError == freezed
          ? _value.isConnnectingError
          : isConnnectingError // ignore: cast_nullable_to_non_nullable
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
      this.throttlePressed = false,
      this.currentTimeSpent = 0,
      this.currentFuelBurnt = 0,
      this.tripStatus = TripStatus.idle,
      this.localTripProgress = 0.0,
      this.localData = Constants.defaultLocalFile,
      this.isConnecting = true,
      this.isDisconnecting = false,
      this.isConnnectingError = false,
      this.supportedPids = const [],
      required this.pidsChecker,
      this.vin = '',
      this.fuelSystemStatus = FuelSystemStatus.motorOff,
      this.userAccelerometer = '',
      this.temperature = 0.0,
      this.isTemperatureAvaliable = false,
      this.errors = const []});

  @JsonKey()
  @override // Live data
  final bool isRunning;
  @override
  final DateTime tripStart;
  @JsonKey()
  @override
  final int tripSeconds;
  @override
  final TripRecord tripRecord;
  @override
  final Position? lastPosition;
  @JsonKey()
  @override
  final bool isLocalMode;
  @JsonKey()
  @override
  final double acceleration;
  @JsonKey()
  @override
  final bool throttlePressed;
  @JsonKey()
  @override
  final int currentTimeSpent;
  @JsonKey()
  @override
  final double currentFuelBurnt;
  @JsonKey()
  @override
  final TripStatus tripStatus;
  @JsonKey()
  @override // Just for testing
  final double localTripProgress;
  @JsonKey()
  @override
  final String localData;
  @JsonKey()
  @override // Bluetooth
  final bool isConnecting;
  @JsonKey()
  @override
  final bool isDisconnecting;
  @JsonKey()
  @override
  final bool isConnnectingError;
  @JsonKey()
  @override // Pids
  final List<String> supportedPids;
  @override
  final PidsChecker pidsChecker;
  @JsonKey()
  @override
  final String vin;
  @JsonKey()
  @override
  final FuelSystemStatus fuelSystemStatus;
  @JsonKey()
  @override // Sensors
  final String userAccelerometer;
  @JsonKey()
  @override
  final double temperature;
  @JsonKey()
  @override
  final bool isTemperatureAvaliable;
  @JsonKey()
  @override // Errors
  final List<String> errors;

  @override
  String toString() {
    return 'LiveDataState(isRunning: $isRunning, tripStart: $tripStart, tripSeconds: $tripSeconds, tripRecord: $tripRecord, lastPosition: $lastPosition, isLocalMode: $isLocalMode, acceleration: $acceleration, throttlePressed: $throttlePressed, currentTimeSpent: $currentTimeSpent, currentFuelBurnt: $currentFuelBurnt, tripStatus: $tripStatus, localTripProgress: $localTripProgress, localData: $localData, isConnecting: $isConnecting, isDisconnecting: $isDisconnecting, isConnnectingError: $isConnnectingError, supportedPids: $supportedPids, pidsChecker: $pidsChecker, vin: $vin, fuelSystemStatus: $fuelSystemStatus, userAccelerometer: $userAccelerometer, temperature: $temperature, isTemperatureAvaliable: $isTemperatureAvaliable, errors: $errors)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LiveDataState &&
            const DeepCollectionEquality().equals(other.isRunning, isRunning) &&
            const DeepCollectionEquality().equals(other.tripStart, tripStart) &&
            const DeepCollectionEquality()
                .equals(other.tripSeconds, tripSeconds) &&
            const DeepCollectionEquality()
                .equals(other.tripRecord, tripRecord) &&
            const DeepCollectionEquality()
                .equals(other.lastPosition, lastPosition) &&
            const DeepCollectionEquality()
                .equals(other.isLocalMode, isLocalMode) &&
            const DeepCollectionEquality()
                .equals(other.acceleration, acceleration) &&
            const DeepCollectionEquality()
                .equals(other.throttlePressed, throttlePressed) &&
            const DeepCollectionEquality()
                .equals(other.currentTimeSpent, currentTimeSpent) &&
            const DeepCollectionEquality()
                .equals(other.currentFuelBurnt, currentFuelBurnt) &&
            const DeepCollectionEquality()
                .equals(other.tripStatus, tripStatus) &&
            const DeepCollectionEquality()
                .equals(other.localTripProgress, localTripProgress) &&
            const DeepCollectionEquality().equals(other.localData, localData) &&
            const DeepCollectionEquality()
                .equals(other.isConnecting, isConnecting) &&
            const DeepCollectionEquality()
                .equals(other.isDisconnecting, isDisconnecting) &&
            const DeepCollectionEquality()
                .equals(other.isConnnectingError, isConnnectingError) &&
            const DeepCollectionEquality()
                .equals(other.supportedPids, supportedPids) &&
            const DeepCollectionEquality()
                .equals(other.pidsChecker, pidsChecker) &&
            const DeepCollectionEquality().equals(other.vin, vin) &&
            const DeepCollectionEquality()
                .equals(other.fuelSystemStatus, fuelSystemStatus) &&
            const DeepCollectionEquality()
                .equals(other.userAccelerometer, userAccelerometer) &&
            const DeepCollectionEquality()
                .equals(other.temperature, temperature) &&
            const DeepCollectionEquality()
                .equals(other.isTemperatureAvaliable, isTemperatureAvaliable) &&
            const DeepCollectionEquality().equals(other.errors, errors));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        const DeepCollectionEquality().hash(isRunning),
        const DeepCollectionEquality().hash(tripStart),
        const DeepCollectionEquality().hash(tripSeconds),
        const DeepCollectionEquality().hash(tripRecord),
        const DeepCollectionEquality().hash(lastPosition),
        const DeepCollectionEquality().hash(isLocalMode),
        const DeepCollectionEquality().hash(acceleration),
        const DeepCollectionEquality().hash(throttlePressed),
        const DeepCollectionEquality().hash(currentTimeSpent),
        const DeepCollectionEquality().hash(currentFuelBurnt),
        const DeepCollectionEquality().hash(tripStatus),
        const DeepCollectionEquality().hash(localTripProgress),
        const DeepCollectionEquality().hash(localData),
        const DeepCollectionEquality().hash(isConnecting),
        const DeepCollectionEquality().hash(isDisconnecting),
        const DeepCollectionEquality().hash(isConnnectingError),
        const DeepCollectionEquality().hash(supportedPids),
        const DeepCollectionEquality().hash(pidsChecker),
        const DeepCollectionEquality().hash(vin),
        const DeepCollectionEquality().hash(fuelSystemStatus),
        const DeepCollectionEquality().hash(userAccelerometer),
        const DeepCollectionEquality().hash(temperature),
        const DeepCollectionEquality().hash(isTemperatureAvaliable),
        const DeepCollectionEquality().hash(errors)
      ]);

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
      bool throttlePressed,
      int currentTimeSpent,
      double currentFuelBurnt,
      TripStatus tripStatus,
      double localTripProgress,
      String localData,
      bool isConnecting,
      bool isDisconnecting,
      bool isConnnectingError,
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
  bool get throttlePressed;
  @override
  int get currentTimeSpent;
  @override
  double get currentFuelBurnt;
  @override
  TripStatus get tripStatus;
  @override // Just for testing
  double get localTripProgress;
  @override
  String get localData;
  @override // Bluetooth
  bool get isConnecting;
  @override
  bool get isDisconnecting;
  @override
  bool get isConnnectingError;
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
