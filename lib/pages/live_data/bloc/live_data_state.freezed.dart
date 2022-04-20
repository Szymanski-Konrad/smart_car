// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
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
      {required TripRecord tripRecord,
      LocationData? firstLocation,
      LocationData? lastLocation,
      bool isLocalMode = false,
      double fuelPrice = 0,
      double score = 0,
      List<double> acceleration = const [],
      double direction = 0,
      double locationSlope = 0,
      double locationHeight = 0,
      double tripAltitudeCumulation = 0,
      double localTripProgress = 0.0,
      String localData = Constants.defaultLocalFile,
      bool isRunning = false,
      bool isConnecting = true,
      bool isDisconnecting = false,
      bool isConnnectingError = false,
      bool isTripEnded = false,
      bool isTripClosing = false,
      List<String> supportedPids = const [],
      required PidsChecker pidsChecker,
      String vin = '',
      FuelSystemStatus fuelSystemStatus = FuelSystemStatus.motorOff,
      int averageResponseTime = 0,
      int totalResponseTime = 0,
      List<double> xAccData = const [0],
      List<double> yAccData = const [0],
      List<double> zAccData = const [0],
      List<double> xGyroData = const [0],
      List<double> yGyroData = const [0],
      List<double> zGyroData = const [0],
      bool isTemperatureAvaliable = false,
      double temperature = 0.0,
      bool isTurning = false,
      bool isHighGforce = false,
      List<String> errors = const []}) {
    return _LiveDataState(
      tripRecord: tripRecord,
      firstLocation: firstLocation,
      lastLocation: lastLocation,
      isLocalMode: isLocalMode,
      fuelPrice: fuelPrice,
      score: score,
      acceleration: acceleration,
      direction: direction,
      locationSlope: locationSlope,
      locationHeight: locationHeight,
      tripAltitudeCumulation: tripAltitudeCumulation,
      localTripProgress: localTripProgress,
      localData: localData,
      isRunning: isRunning,
      isConnecting: isConnecting,
      isDisconnecting: isDisconnecting,
      isConnnectingError: isConnnectingError,
      isTripEnded: isTripEnded,
      isTripClosing: isTripClosing,
      supportedPids: supportedPids,
      pidsChecker: pidsChecker,
      vin: vin,
      fuelSystemStatus: fuelSystemStatus,
      averageResponseTime: averageResponseTime,
      totalResponseTime: totalResponseTime,
      xAccData: xAccData,
      yAccData: yAccData,
      zAccData: zAccData,
      xGyroData: xGyroData,
      yGyroData: yGyroData,
      zGyroData: zGyroData,
      isTemperatureAvaliable: isTemperatureAvaliable,
      temperature: temperature,
      isTurning: isTurning,
      isHighGforce: isHighGforce,
      errors: errors,
    );
  }
}

/// @nodoc
const $LiveDataState = _$LiveDataStateTearOff();

/// @nodoc
mixin _$LiveDataState {
// Live data
  TripRecord get tripRecord => throw _privateConstructorUsedError;
  LocationData? get firstLocation => throw _privateConstructorUsedError;
  LocationData? get lastLocation => throw _privateConstructorUsedError;
  bool get isLocalMode => throw _privateConstructorUsedError;
  double get fuelPrice => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;
  List<double> get acceleration => throw _privateConstructorUsedError; // GPS
  double get direction => throw _privateConstructorUsedError;
  double get locationSlope => throw _privateConstructorUsedError;
  double get locationHeight => throw _privateConstructorUsedError;
  double get tripAltitudeCumulation =>
      throw _privateConstructorUsedError; // Just for testing
  double get localTripProgress => throw _privateConstructorUsedError;
  String get localData => throw _privateConstructorUsedError; // Bluetooth
  bool get isRunning => throw _privateConstructorUsedError;
  bool get isConnecting => throw _privateConstructorUsedError;
  bool get isDisconnecting => throw _privateConstructorUsedError;
  bool get isConnnectingError => throw _privateConstructorUsedError;
  bool get isTripEnded => throw _privateConstructorUsedError;
  bool get isTripClosing => throw _privateConstructorUsedError; // Pids
  List<String> get supportedPids => throw _privateConstructorUsedError;
  PidsChecker get pidsChecker => throw _privateConstructorUsedError;
  String get vin => throw _privateConstructorUsedError;
  FuelSystemStatus get fuelSystemStatus => throw _privateConstructorUsedError;
  int get averageResponseTime => throw _privateConstructorUsedError;
  int get totalResponseTime => throw _privateConstructorUsedError; // Sensors
  List<double> get xAccData => throw _privateConstructorUsedError;
  List<double> get yAccData => throw _privateConstructorUsedError;
  List<double> get zAccData => throw _privateConstructorUsedError;
  List<double> get xGyroData => throw _privateConstructorUsedError;
  List<double> get yGyroData => throw _privateConstructorUsedError;
  List<double> get zGyroData => throw _privateConstructorUsedError;
  bool get isTemperatureAvaliable => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  bool get isTurning => throw _privateConstructorUsedError;
  bool get isHighGforce => throw _privateConstructorUsedError; // Errors
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
      {TripRecord tripRecord,
      LocationData? firstLocation,
      LocationData? lastLocation,
      bool isLocalMode,
      double fuelPrice,
      double score,
      List<double> acceleration,
      double direction,
      double locationSlope,
      double locationHeight,
      double tripAltitudeCumulation,
      double localTripProgress,
      String localData,
      bool isRunning,
      bool isConnecting,
      bool isDisconnecting,
      bool isConnnectingError,
      bool isTripEnded,
      bool isTripClosing,
      List<String> supportedPids,
      PidsChecker pidsChecker,
      String vin,
      FuelSystemStatus fuelSystemStatus,
      int averageResponseTime,
      int totalResponseTime,
      List<double> xAccData,
      List<double> yAccData,
      List<double> zAccData,
      List<double> xGyroData,
      List<double> yGyroData,
      List<double> zGyroData,
      bool isTemperatureAvaliable,
      double temperature,
      bool isTurning,
      bool isHighGforce,
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
    Object? tripRecord = freezed,
    Object? firstLocation = freezed,
    Object? lastLocation = freezed,
    Object? isLocalMode = freezed,
    Object? fuelPrice = freezed,
    Object? score = freezed,
    Object? acceleration = freezed,
    Object? direction = freezed,
    Object? locationSlope = freezed,
    Object? locationHeight = freezed,
    Object? tripAltitudeCumulation = freezed,
    Object? localTripProgress = freezed,
    Object? localData = freezed,
    Object? isRunning = freezed,
    Object? isConnecting = freezed,
    Object? isDisconnecting = freezed,
    Object? isConnnectingError = freezed,
    Object? isTripEnded = freezed,
    Object? isTripClosing = freezed,
    Object? supportedPids = freezed,
    Object? pidsChecker = freezed,
    Object? vin = freezed,
    Object? fuelSystemStatus = freezed,
    Object? averageResponseTime = freezed,
    Object? totalResponseTime = freezed,
    Object? xAccData = freezed,
    Object? yAccData = freezed,
    Object? zAccData = freezed,
    Object? xGyroData = freezed,
    Object? yGyroData = freezed,
    Object? zGyroData = freezed,
    Object? isTemperatureAvaliable = freezed,
    Object? temperature = freezed,
    Object? isTurning = freezed,
    Object? isHighGforce = freezed,
    Object? errors = freezed,
  }) {
    return _then(_value.copyWith(
      tripRecord: tripRecord == freezed
          ? _value.tripRecord
          : tripRecord // ignore: cast_nullable_to_non_nullable
              as TripRecord,
      firstLocation: firstLocation == freezed
          ? _value.firstLocation
          : firstLocation // ignore: cast_nullable_to_non_nullable
              as LocationData?,
      lastLocation: lastLocation == freezed
          ? _value.lastLocation
          : lastLocation // ignore: cast_nullable_to_non_nullable
              as LocationData?,
      isLocalMode: isLocalMode == freezed
          ? _value.isLocalMode
          : isLocalMode // ignore: cast_nullable_to_non_nullable
              as bool,
      fuelPrice: fuelPrice == freezed
          ? _value.fuelPrice
          : fuelPrice // ignore: cast_nullable_to_non_nullable
              as double,
      score: score == freezed
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      acceleration: acceleration == freezed
          ? _value.acceleration
          : acceleration // ignore: cast_nullable_to_non_nullable
              as List<double>,
      direction: direction == freezed
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as double,
      locationSlope: locationSlope == freezed
          ? _value.locationSlope
          : locationSlope // ignore: cast_nullable_to_non_nullable
              as double,
      locationHeight: locationHeight == freezed
          ? _value.locationHeight
          : locationHeight // ignore: cast_nullable_to_non_nullable
              as double,
      tripAltitudeCumulation: tripAltitudeCumulation == freezed
          ? _value.tripAltitudeCumulation
          : tripAltitudeCumulation // ignore: cast_nullable_to_non_nullable
              as double,
      localTripProgress: localTripProgress == freezed
          ? _value.localTripProgress
          : localTripProgress // ignore: cast_nullable_to_non_nullable
              as double,
      localData: localData == freezed
          ? _value.localData
          : localData // ignore: cast_nullable_to_non_nullable
              as String,
      isRunning: isRunning == freezed
          ? _value.isRunning
          : isRunning // ignore: cast_nullable_to_non_nullable
              as bool,
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
      isTripEnded: isTripEnded == freezed
          ? _value.isTripEnded
          : isTripEnded // ignore: cast_nullable_to_non_nullable
              as bool,
      isTripClosing: isTripClosing == freezed
          ? _value.isTripClosing
          : isTripClosing // ignore: cast_nullable_to_non_nullable
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
      averageResponseTime: averageResponseTime == freezed
          ? _value.averageResponseTime
          : averageResponseTime // ignore: cast_nullable_to_non_nullable
              as int,
      totalResponseTime: totalResponseTime == freezed
          ? _value.totalResponseTime
          : totalResponseTime // ignore: cast_nullable_to_non_nullable
              as int,
      xAccData: xAccData == freezed
          ? _value.xAccData
          : xAccData // ignore: cast_nullable_to_non_nullable
              as List<double>,
      yAccData: yAccData == freezed
          ? _value.yAccData
          : yAccData // ignore: cast_nullable_to_non_nullable
              as List<double>,
      zAccData: zAccData == freezed
          ? _value.zAccData
          : zAccData // ignore: cast_nullable_to_non_nullable
              as List<double>,
      xGyroData: xGyroData == freezed
          ? _value.xGyroData
          : xGyroData // ignore: cast_nullable_to_non_nullable
              as List<double>,
      yGyroData: yGyroData == freezed
          ? _value.yGyroData
          : yGyroData // ignore: cast_nullable_to_non_nullable
              as List<double>,
      zGyroData: zGyroData == freezed
          ? _value.zGyroData
          : zGyroData // ignore: cast_nullable_to_non_nullable
              as List<double>,
      isTemperatureAvaliable: isTemperatureAvaliable == freezed
          ? _value.isTemperatureAvaliable
          : isTemperatureAvaliable // ignore: cast_nullable_to_non_nullable
              as bool,
      temperature: temperature == freezed
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      isTurning: isTurning == freezed
          ? _value.isTurning
          : isTurning // ignore: cast_nullable_to_non_nullable
              as bool,
      isHighGforce: isHighGforce == freezed
          ? _value.isHighGforce
          : isHighGforce // ignore: cast_nullable_to_non_nullable
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
      {TripRecord tripRecord,
      LocationData? firstLocation,
      LocationData? lastLocation,
      bool isLocalMode,
      double fuelPrice,
      double score,
      List<double> acceleration,
      double direction,
      double locationSlope,
      double locationHeight,
      double tripAltitudeCumulation,
      double localTripProgress,
      String localData,
      bool isRunning,
      bool isConnecting,
      bool isDisconnecting,
      bool isConnnectingError,
      bool isTripEnded,
      bool isTripClosing,
      List<String> supportedPids,
      PidsChecker pidsChecker,
      String vin,
      FuelSystemStatus fuelSystemStatus,
      int averageResponseTime,
      int totalResponseTime,
      List<double> xAccData,
      List<double> yAccData,
      List<double> zAccData,
      List<double> xGyroData,
      List<double> yGyroData,
      List<double> zGyroData,
      bool isTemperatureAvaliable,
      double temperature,
      bool isTurning,
      bool isHighGforce,
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
    Object? tripRecord = freezed,
    Object? firstLocation = freezed,
    Object? lastLocation = freezed,
    Object? isLocalMode = freezed,
    Object? fuelPrice = freezed,
    Object? score = freezed,
    Object? acceleration = freezed,
    Object? direction = freezed,
    Object? locationSlope = freezed,
    Object? locationHeight = freezed,
    Object? tripAltitudeCumulation = freezed,
    Object? localTripProgress = freezed,
    Object? localData = freezed,
    Object? isRunning = freezed,
    Object? isConnecting = freezed,
    Object? isDisconnecting = freezed,
    Object? isConnnectingError = freezed,
    Object? isTripEnded = freezed,
    Object? isTripClosing = freezed,
    Object? supportedPids = freezed,
    Object? pidsChecker = freezed,
    Object? vin = freezed,
    Object? fuelSystemStatus = freezed,
    Object? averageResponseTime = freezed,
    Object? totalResponseTime = freezed,
    Object? xAccData = freezed,
    Object? yAccData = freezed,
    Object? zAccData = freezed,
    Object? xGyroData = freezed,
    Object? yGyroData = freezed,
    Object? zGyroData = freezed,
    Object? isTemperatureAvaliable = freezed,
    Object? temperature = freezed,
    Object? isTurning = freezed,
    Object? isHighGforce = freezed,
    Object? errors = freezed,
  }) {
    return _then(_LiveDataState(
      tripRecord: tripRecord == freezed
          ? _value.tripRecord
          : tripRecord // ignore: cast_nullable_to_non_nullable
              as TripRecord,
      firstLocation: firstLocation == freezed
          ? _value.firstLocation
          : firstLocation // ignore: cast_nullable_to_non_nullable
              as LocationData?,
      lastLocation: lastLocation == freezed
          ? _value.lastLocation
          : lastLocation // ignore: cast_nullable_to_non_nullable
              as LocationData?,
      isLocalMode: isLocalMode == freezed
          ? _value.isLocalMode
          : isLocalMode // ignore: cast_nullable_to_non_nullable
              as bool,
      fuelPrice: fuelPrice == freezed
          ? _value.fuelPrice
          : fuelPrice // ignore: cast_nullable_to_non_nullable
              as double,
      score: score == freezed
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      acceleration: acceleration == freezed
          ? _value.acceleration
          : acceleration // ignore: cast_nullable_to_non_nullable
              as List<double>,
      direction: direction == freezed
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as double,
      locationSlope: locationSlope == freezed
          ? _value.locationSlope
          : locationSlope // ignore: cast_nullable_to_non_nullable
              as double,
      locationHeight: locationHeight == freezed
          ? _value.locationHeight
          : locationHeight // ignore: cast_nullable_to_non_nullable
              as double,
      tripAltitudeCumulation: tripAltitudeCumulation == freezed
          ? _value.tripAltitudeCumulation
          : tripAltitudeCumulation // ignore: cast_nullable_to_non_nullable
              as double,
      localTripProgress: localTripProgress == freezed
          ? _value.localTripProgress
          : localTripProgress // ignore: cast_nullable_to_non_nullable
              as double,
      localData: localData == freezed
          ? _value.localData
          : localData // ignore: cast_nullable_to_non_nullable
              as String,
      isRunning: isRunning == freezed
          ? _value.isRunning
          : isRunning // ignore: cast_nullable_to_non_nullable
              as bool,
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
      isTripEnded: isTripEnded == freezed
          ? _value.isTripEnded
          : isTripEnded // ignore: cast_nullable_to_non_nullable
              as bool,
      isTripClosing: isTripClosing == freezed
          ? _value.isTripClosing
          : isTripClosing // ignore: cast_nullable_to_non_nullable
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
      averageResponseTime: averageResponseTime == freezed
          ? _value.averageResponseTime
          : averageResponseTime // ignore: cast_nullable_to_non_nullable
              as int,
      totalResponseTime: totalResponseTime == freezed
          ? _value.totalResponseTime
          : totalResponseTime // ignore: cast_nullable_to_non_nullable
              as int,
      xAccData: xAccData == freezed
          ? _value.xAccData
          : xAccData // ignore: cast_nullable_to_non_nullable
              as List<double>,
      yAccData: yAccData == freezed
          ? _value.yAccData
          : yAccData // ignore: cast_nullable_to_non_nullable
              as List<double>,
      zAccData: zAccData == freezed
          ? _value.zAccData
          : zAccData // ignore: cast_nullable_to_non_nullable
              as List<double>,
      xGyroData: xGyroData == freezed
          ? _value.xGyroData
          : xGyroData // ignore: cast_nullable_to_non_nullable
              as List<double>,
      yGyroData: yGyroData == freezed
          ? _value.yGyroData
          : yGyroData // ignore: cast_nullable_to_non_nullable
              as List<double>,
      zGyroData: zGyroData == freezed
          ? _value.zGyroData
          : zGyroData // ignore: cast_nullable_to_non_nullable
              as List<double>,
      isTemperatureAvaliable: isTemperatureAvaliable == freezed
          ? _value.isTemperatureAvaliable
          : isTemperatureAvaliable // ignore: cast_nullable_to_non_nullable
              as bool,
      temperature: temperature == freezed
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      isTurning: isTurning == freezed
          ? _value.isTurning
          : isTurning // ignore: cast_nullable_to_non_nullable
              as bool,
      isHighGforce: isHighGforce == freezed
          ? _value.isHighGforce
          : isHighGforce // ignore: cast_nullable_to_non_nullable
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
      {required this.tripRecord,
      this.firstLocation,
      this.lastLocation,
      this.isLocalMode = false,
      this.fuelPrice = 0,
      this.score = 0,
      this.acceleration = const [],
      this.direction = 0,
      this.locationSlope = 0,
      this.locationHeight = 0,
      this.tripAltitudeCumulation = 0,
      this.localTripProgress = 0.0,
      this.localData = Constants.defaultLocalFile,
      this.isRunning = false,
      this.isConnecting = true,
      this.isDisconnecting = false,
      this.isConnnectingError = false,
      this.isTripEnded = false,
      this.isTripClosing = false,
      this.supportedPids = const [],
      required this.pidsChecker,
      this.vin = '',
      this.fuelSystemStatus = FuelSystemStatus.motorOff,
      this.averageResponseTime = 0,
      this.totalResponseTime = 0,
      this.xAccData = const [0],
      this.yAccData = const [0],
      this.zAccData = const [0],
      this.xGyroData = const [0],
      this.yGyroData = const [0],
      this.zGyroData = const [0],
      this.isTemperatureAvaliable = false,
      this.temperature = 0.0,
      this.isTurning = false,
      this.isHighGforce = false,
      this.errors = const []});

  @override // Live data
  final TripRecord tripRecord;
  @override
  final LocationData? firstLocation;
  @override
  final LocationData? lastLocation;
  @JsonKey()
  @override
  final bool isLocalMode;
  @JsonKey()
  @override
  final double fuelPrice;
  @JsonKey()
  @override
  final double score;
  @JsonKey()
  @override
  final List<double> acceleration;
  @JsonKey()
  @override // GPS
  final double direction;
  @JsonKey()
  @override
  final double locationSlope;
  @JsonKey()
  @override
  final double locationHeight;
  @JsonKey()
  @override
  final double tripAltitudeCumulation;
  @JsonKey()
  @override // Just for testing
  final double localTripProgress;
  @JsonKey()
  @override
  final String localData;
  @JsonKey()
  @override // Bluetooth
  final bool isRunning;
  @JsonKey()
  @override
  final bool isConnecting;
  @JsonKey()
  @override
  final bool isDisconnecting;
  @JsonKey()
  @override
  final bool isConnnectingError;
  @JsonKey()
  @override
  final bool isTripEnded;
  @JsonKey()
  @override
  final bool isTripClosing;
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
  @override
  final int averageResponseTime;
  @JsonKey()
  @override
  final int totalResponseTime;
  @JsonKey()
  @override // Sensors
  final List<double> xAccData;
  @JsonKey()
  @override
  final List<double> yAccData;
  @JsonKey()
  @override
  final List<double> zAccData;
  @JsonKey()
  @override
  final List<double> xGyroData;
  @JsonKey()
  @override
  final List<double> yGyroData;
  @JsonKey()
  @override
  final List<double> zGyroData;
  @JsonKey()
  @override
  final bool isTemperatureAvaliable;
  @JsonKey()
  @override
  final double temperature;
  @JsonKey()
  @override
  final bool isTurning;
  @JsonKey()
  @override
  final bool isHighGforce;
  @JsonKey()
  @override // Errors
  final List<String> errors;

  @override
  String toString() {
    return 'LiveDataState(tripRecord: $tripRecord, firstLocation: $firstLocation, lastLocation: $lastLocation, isLocalMode: $isLocalMode, fuelPrice: $fuelPrice, score: $score, acceleration: $acceleration, direction: $direction, locationSlope: $locationSlope, locationHeight: $locationHeight, tripAltitudeCumulation: $tripAltitudeCumulation, localTripProgress: $localTripProgress, localData: $localData, isRunning: $isRunning, isConnecting: $isConnecting, isDisconnecting: $isDisconnecting, isConnnectingError: $isConnnectingError, isTripEnded: $isTripEnded, isTripClosing: $isTripClosing, supportedPids: $supportedPids, pidsChecker: $pidsChecker, vin: $vin, fuelSystemStatus: $fuelSystemStatus, averageResponseTime: $averageResponseTime, totalResponseTime: $totalResponseTime, xAccData: $xAccData, yAccData: $yAccData, zAccData: $zAccData, xGyroData: $xGyroData, yGyroData: $yGyroData, zGyroData: $zGyroData, isTemperatureAvaliable: $isTemperatureAvaliable, temperature: $temperature, isTurning: $isTurning, isHighGforce: $isHighGforce, errors: $errors)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LiveDataState &&
            const DeepCollectionEquality()
                .equals(other.tripRecord, tripRecord) &&
            const DeepCollectionEquality()
                .equals(other.firstLocation, firstLocation) &&
            const DeepCollectionEquality()
                .equals(other.lastLocation, lastLocation) &&
            const DeepCollectionEquality()
                .equals(other.isLocalMode, isLocalMode) &&
            const DeepCollectionEquality().equals(other.fuelPrice, fuelPrice) &&
            const DeepCollectionEquality().equals(other.score, score) &&
            const DeepCollectionEquality()
                .equals(other.acceleration, acceleration) &&
            const DeepCollectionEquality().equals(other.direction, direction) &&
            const DeepCollectionEquality()
                .equals(other.locationSlope, locationSlope) &&
            const DeepCollectionEquality()
                .equals(other.locationHeight, locationHeight) &&
            const DeepCollectionEquality()
                .equals(other.tripAltitudeCumulation, tripAltitudeCumulation) &&
            const DeepCollectionEquality()
                .equals(other.localTripProgress, localTripProgress) &&
            const DeepCollectionEquality().equals(other.localData, localData) &&
            const DeepCollectionEquality().equals(other.isRunning, isRunning) &&
            const DeepCollectionEquality()
                .equals(other.isConnecting, isConnecting) &&
            const DeepCollectionEquality()
                .equals(other.isDisconnecting, isDisconnecting) &&
            const DeepCollectionEquality()
                .equals(other.isConnnectingError, isConnnectingError) &&
            const DeepCollectionEquality()
                .equals(other.isTripEnded, isTripEnded) &&
            const DeepCollectionEquality()
                .equals(other.isTripClosing, isTripClosing) &&
            const DeepCollectionEquality()
                .equals(other.supportedPids, supportedPids) &&
            const DeepCollectionEquality()
                .equals(other.pidsChecker, pidsChecker) &&
            const DeepCollectionEquality().equals(other.vin, vin) &&
            const DeepCollectionEquality()
                .equals(other.fuelSystemStatus, fuelSystemStatus) &&
            const DeepCollectionEquality()
                .equals(other.averageResponseTime, averageResponseTime) &&
            const DeepCollectionEquality()
                .equals(other.totalResponseTime, totalResponseTime) &&
            const DeepCollectionEquality().equals(other.xAccData, xAccData) &&
            const DeepCollectionEquality().equals(other.yAccData, yAccData) &&
            const DeepCollectionEquality().equals(other.zAccData, zAccData) &&
            const DeepCollectionEquality().equals(other.xGyroData, xGyroData) &&
            const DeepCollectionEquality().equals(other.yGyroData, yGyroData) &&
            const DeepCollectionEquality().equals(other.zGyroData, zGyroData) &&
            const DeepCollectionEquality()
                .equals(other.isTemperatureAvaliable, isTemperatureAvaliable) &&
            const DeepCollectionEquality()
                .equals(other.temperature, temperature) &&
            const DeepCollectionEquality().equals(other.isTurning, isTurning) &&
            const DeepCollectionEquality()
                .equals(other.isHighGforce, isHighGforce) &&
            const DeepCollectionEquality().equals(other.errors, errors));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        const DeepCollectionEquality().hash(tripRecord),
        const DeepCollectionEquality().hash(firstLocation),
        const DeepCollectionEquality().hash(lastLocation),
        const DeepCollectionEquality().hash(isLocalMode),
        const DeepCollectionEquality().hash(fuelPrice),
        const DeepCollectionEquality().hash(score),
        const DeepCollectionEquality().hash(acceleration),
        const DeepCollectionEquality().hash(direction),
        const DeepCollectionEquality().hash(locationSlope),
        const DeepCollectionEquality().hash(locationHeight),
        const DeepCollectionEquality().hash(tripAltitudeCumulation),
        const DeepCollectionEquality().hash(localTripProgress),
        const DeepCollectionEquality().hash(localData),
        const DeepCollectionEquality().hash(isRunning),
        const DeepCollectionEquality().hash(isConnecting),
        const DeepCollectionEquality().hash(isDisconnecting),
        const DeepCollectionEquality().hash(isConnnectingError),
        const DeepCollectionEquality().hash(isTripEnded),
        const DeepCollectionEquality().hash(isTripClosing),
        const DeepCollectionEquality().hash(supportedPids),
        const DeepCollectionEquality().hash(pidsChecker),
        const DeepCollectionEquality().hash(vin),
        const DeepCollectionEquality().hash(fuelSystemStatus),
        const DeepCollectionEquality().hash(averageResponseTime),
        const DeepCollectionEquality().hash(totalResponseTime),
        const DeepCollectionEquality().hash(xAccData),
        const DeepCollectionEquality().hash(yAccData),
        const DeepCollectionEquality().hash(zAccData),
        const DeepCollectionEquality().hash(xGyroData),
        const DeepCollectionEquality().hash(yGyroData),
        const DeepCollectionEquality().hash(zGyroData),
        const DeepCollectionEquality().hash(isTemperatureAvaliable),
        const DeepCollectionEquality().hash(temperature),
        const DeepCollectionEquality().hash(isTurning),
        const DeepCollectionEquality().hash(isHighGforce),
        const DeepCollectionEquality().hash(errors)
      ]);

  @JsonKey(ignore: true)
  @override
  _$LiveDataStateCopyWith<_LiveDataState> get copyWith =>
      __$LiveDataStateCopyWithImpl<_LiveDataState>(this, _$identity);
}

abstract class _LiveDataState implements LiveDataState {
  factory _LiveDataState(
      {required TripRecord tripRecord,
      LocationData? firstLocation,
      LocationData? lastLocation,
      bool isLocalMode,
      double fuelPrice,
      double score,
      List<double> acceleration,
      double direction,
      double locationSlope,
      double locationHeight,
      double tripAltitudeCumulation,
      double localTripProgress,
      String localData,
      bool isRunning,
      bool isConnecting,
      bool isDisconnecting,
      bool isConnnectingError,
      bool isTripEnded,
      bool isTripClosing,
      List<String> supportedPids,
      required PidsChecker pidsChecker,
      String vin,
      FuelSystemStatus fuelSystemStatus,
      int averageResponseTime,
      int totalResponseTime,
      List<double> xAccData,
      List<double> yAccData,
      List<double> zAccData,
      List<double> xGyroData,
      List<double> yGyroData,
      List<double> zGyroData,
      bool isTemperatureAvaliable,
      double temperature,
      bool isTurning,
      bool isHighGforce,
      List<String> errors}) = _$_LiveDataState;

  @override // Live data
  TripRecord get tripRecord;
  @override
  LocationData? get firstLocation;
  @override
  LocationData? get lastLocation;
  @override
  bool get isLocalMode;
  @override
  double get fuelPrice;
  @override
  double get score;
  @override
  List<double> get acceleration;
  @override // GPS
  double get direction;
  @override
  double get locationSlope;
  @override
  double get locationHeight;
  @override
  double get tripAltitudeCumulation;
  @override // Just for testing
  double get localTripProgress;
  @override
  String get localData;
  @override // Bluetooth
  bool get isRunning;
  @override
  bool get isConnecting;
  @override
  bool get isDisconnecting;
  @override
  bool get isConnnectingError;
  @override
  bool get isTripEnded;
  @override
  bool get isTripClosing;
  @override // Pids
  List<String> get supportedPids;
  @override
  PidsChecker get pidsChecker;
  @override
  String get vin;
  @override
  FuelSystemStatus get fuelSystemStatus;
  @override
  int get averageResponseTime;
  @override
  int get totalResponseTime;
  @override // Sensors
  List<double> get xAccData;
  @override
  List<double> get yAccData;
  @override
  List<double> get zAccData;
  @override
  List<double> get xGyroData;
  @override
  List<double> get yGyroData;
  @override
  List<double> get zGyroData;
  @override
  bool get isTemperatureAvaliable;
  @override
  double get temperature;
  @override
  bool get isTurning;
  @override
  bool get isHighGforce;
  @override // Errors
  List<String> get errors;
  @override
  @JsonKey(ignore: true)
  _$LiveDataStateCopyWith<_LiveDataState> get copyWith =>
      throw _privateConstructorUsedError;
}
