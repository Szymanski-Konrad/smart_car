import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:location/location.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/app/navigation/navigation.dart';
import 'package:smart_car/app/resources/alerts.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/app/resources/pids.dart';
import 'package:smart_car/app/resources/strings.dart';
import 'package:smart_car/feautures/alert_center/alert_center.dart';
import 'package:smart_car/feautures/trip_score/trip_dataset_model.dart';
import 'package:smart_car/models/trip_score_model.dart';
import 'package:smart_car/models/trip_summary/trip_summary.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/obd_command.dart';
import 'package:smart_car/pages/live_data/model/battery_voltage_command.dart';
import 'package:smart_car/pages/live_data/model/commands/check_commands/check_pids_command.dart';
import 'package:smart_car/pages/live_data/model/commands/check_commands/vin_command.dart';
import 'package:smart_car/pages/live_data/model/commands/pids_checker.dart';
import 'package:smart_car/pages/live_data/model/fuel_level_command.dart';
import 'package:smart_car/pages/live_data/model/fuel_system_status_command.dart';
import 'package:smart_car/pages/live_data/model/maf_command.dart';
import 'package:smart_car/pages/live_data/model/map_command.dart';
import 'package:smart_car/pages/live_data/model/rpm_command.dart';
import 'package:smart_car/pages/live_data/model/speed_command.dart';
import 'package:smart_car/pages/live_data/model/test_data/test_command.dart';
import 'package:smart_car/pages/live_data/model/trip_record.dart';
import 'package:smart_car/services/data_logger.dart';
import 'package:smart_car/services/firestore_handler.dart';
import 'package:smart_car/services/trip_storage.dart';
import 'package:smart_car/utils/bt_connection.dart';
import 'package:smart_car/utils/list_extension.dart';
import 'package:smart_car/utils/location_helper.dart';
import 'package:smart_car/utils/logger.dart';
import 'package:smart_car/utils/obd_commands_extensions.dart';
import 'package:smart_car/utils/sensors_helper.dart';
import 'package:smart_car/utils/trip_files.dart';
import 'package:uuid/uuid.dart';

class LiveDataCubit extends Cubit<LiveDataState> {
  LiveDataCubit({
    required this.address,
    String? localFile,
    required double fuelPrice,
    required double tankSize,
  }) : super(
         LiveDataState.init(
           localFile: localFile,
           fuelPrice: fuelPrice,
           tankSize: tankSize,
         ),
       ) {
    initialize();
  }

  String? address;
  int _commandIndex = 0;
  List<TestCommand> testCommands = [];
  List<ObdCommand> commands = [];
  Queue<String> specialCommands = Queue();
  Queue<String> pidsQueue = Queue<String>();
  DateTime lastReciveCommandTime = DateTime.now();
  DateTime lastTestCommandTime = DateTime.now();

  StreamSubscription<LocationData>? locationSub;
  StreamSubscription<UserAccelerometerEvent>? _accSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroSubsription;
  StreamSubscription<BarometerEvent>? _barometerSubscription;
  Timer? _everySecondTimer;
  Timer? _everyMinuteTimer;
  final doubleRE = RegExp(r"-?(?:\d*\.)?\d+(?:[eE][+-]?\d+)?");

  void initialize() async {
    final ecoJson = await rootBundle.loadString('assets/models/ecoModel.json');
    final smoothJson = await rootBundle.loadString(
      'assets/models/smoothModel.json',
    );
    ecoModel = KnnRegressor.fromJson(ecoJson);
    smoothModel = KnnRegressor.fromJson(smoothJson);
  }

  KnnRegressor? ecoModel;
  KnnRegressor? smoothModel;

  /// Create new connection
  void createConnection({
    required String? newAddress,
    String? localFile,
    required double fuelPrice,
    required double tankSize,
    required bool isLocalMode,
  }) async {
    if (state.isRunning) return;
    if (isLocalMode) {
      _everyMinuteTimer?.cancel();
      _everySecondTimer?.cancel();
    }
    if (address != null) return;
    await BTConnection().close();
    reset();
    address = newAddress;
    emit(
      LiveDataState.init(
        localFile: localFile,
        fuelPrice: fuelPrice,
        tankSize: tankSize,
      ),
    );
    init();
  }

  // Reset variables
  void reset() {
    _commandIndex = 0;
    testCommands.clear();
    commands.clear();
    specialCommands.clear();
    pidsQueue.clear();
    locationSub?.cancel();
    _accSubscription?.cancel();
    _gyroSubsription?.cancel();
    _barometerSubscription?.cancel();
    _everyMinuteTimer?.cancel();
    _everySecondTimer?.cancel();
  }

  void closeConnection() async {
    reset();
    await motorOff();
    address = null;
  }

  bool get isAlreadyConnected => address != null;

  /// Called when succesfully connected to OBD
  void _onSuccessfulConnection() {
    emit(state.copyWith(isConnecting: false, isDisconnecting: false));

    initializeObd();
  }

  /// Called when occured some connection error
  void _onConnectionError() {
    emit(state.copyWith(isConnnectingError: true));
  }

  void checkGforce() {
    if (!state.isHighGforce) {
      if (state.gForce > 1.3) {
        emit(
          state.copyWith(
            isHighGforce: true,
            tripRecord: state.tripRecord.updateHighGForce(),
          ),
        );
      }
    } else if (state.gForce < 1.1) {
      emit(state.copyWith(isHighGforce: false));
    }
  }

  void checkTurning() {
    final rotation = state.yGyroData;
    if (!state.isTurning) {
      if (rotation.abs() > 0.25) {
        emit(
          state.copyWith(
            isTurning: true,
            tripRecord: state.tripRecord.updateTurning(rotation > 0),
          ),
        );
      }
    } else if (rotation.abs() < 0.1) {
      emit(state.copyWith(isTurning: false));
    }
  }

  Future<void> _listenForSensors() async {
    final gyroStream = gyroscopeEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    );
    final accStream = userAccelerometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    );

    try {
      _accSubscription = accStream.listen(
        (event) {
          final xData = SensorsHelper.filterValue(state.xAccData, event.x);
          final yData = SensorsHelper.filterValue(state.yAccData, event.y);
          final zData = SensorsHelper.filterValue(state.zAccData, event.z);
          final acceleration = SensorsHelper.accelerationSum(
            xData,
            yData,
            zData,
          );
          final gForce = SensorsHelper.gForceCalc(acceleration);
          emit(
            state.copyWith(
              xAccData: xData,
              yAccData: yData,
              zAccData: zData,
              gForce: gForce,
            ),
          );
          checkGforce();
        },
        onError: (Object error, StackTrace stackTrace) async {
          _insertError('User accelerometer unavailable: $error');
          emit(
            state.copyWith(
              xAccData: 0,
              yAccData: 0,
              zAccData: 0,
              gForce: 0,
              isHighGforce: false,
            ),
          );
          await _accSubscription?.cancel();
          _accSubscription = null;
        },
        cancelOnError: true,
      );
    } on PlatformException catch (e) {
      _insertError('User accelerometer unavailable: ${e.message ?? e.code}');
      emit(
        state.copyWith(
          xAccData: 0,
          yAccData: 0,
          zAccData: 0,
          gForce: 0,
          isHighGforce: false,
        ),
      );
    } catch (e) {
      _insertError('User accelerometer unavailable: $e');
      emit(
        state.copyWith(
          xAccData: 0,
          yAccData: 0,
          zAccData: 0,
          gForce: 0,
          isHighGforce: false,
        ),
      );
    }

    try {
      _gyroSubsription = gyroStream.listen(
        (event) {
          emit(
            state.copyWith(
              xGyroData: event.x,
              yGyroData: event.y,
              zGyroData: event.z,
            ),
          );
          checkTurning();
        },
        onError: (Object error, StackTrace stackTrace) async {
          _insertError('Gyroscope unavailable: $error');
          emit(
            state.copyWith(
              xGyroData: 0,
              yGyroData: 0,
              zGyroData: 0,
              isTurning: false,
            ),
          );
          await _gyroSubsription?.cancel();
          _gyroSubsription = null;
        },
        cancelOnError: true,
      );
    } on PlatformException catch (e) {
      _insertError('Gyroscope unavailable: ${e.message ?? e.code}');
      emit(
        state.copyWith(
          xGyroData: 0,
          yGyroData: 0,
          zGyroData: 0,
          isTurning: false,
        ),
      );
    } catch (e) {
      _insertError('Gyroscope unavailable: $e');
      emit(
        state.copyWith(
          xGyroData: 0,
          yGyroData: 0,
          zGyroData: 0,
          isTurning: false,
        ),
      );
    }

    // sensors_plus does not provide ambient temperature.
    emit(state.copyWith(isTemperatureAvaliable: false));

    // Barometer is optional on many devices; treat errors as "not available".
    try {
      _barometerSubscription =
          barometerEventStream(
            samplingPeriod: SensorInterval.uiInterval,
          ).listen(
            (event) {
              emit(state.copyWith(barometer: event.pressure));
            },
            onError: (Object error, StackTrace stackTrace) async {
              _insertError('Barometer unavailable: $error');
              emit(state.copyWith(isBarometerAvaliable: false, barometer: 0.0));
              await _barometerSubscription?.cancel();
              _barometerSubscription = null;
            },
            cancelOnError: true,
          );
      emit(state.copyWith(isBarometerAvaliable: true));
    } on PlatformException catch (e) {
      _insertError('Barometer unavailable: ${e.message ?? e.code}');
      emit(state.copyWith(isBarometerAvaliable: false, barometer: 0.0));
    } catch (e) {
      _insertError('Barometer unavailable: $e');
      emit(state.copyWith(isBarometerAvaliable: false, barometer: 0.0));
    }
  }

  void _onLocationChanged(LocationData currLocation) {
    final lastLocation = state.lastLocation;
    if (state.firstLocation == null) {
      emit(
        state.copyWith(
          firstLocation: currLocation,
          lastLocation: currLocation,
          gpsPoints: [currLocation.toLatLng],
        ),
      );
      return;
    }
    if (lastLocation == null) {
      emit(state.copyWith(lastLocation: currLocation));
      return;
    }
    final distance = LocationHelper.calculateDistance(
      lastLocation,
      currLocation,
    );
    if (distance < 100) return;
    final gpsPoints = List<LatLng>.from(state.gpsPoints);
    gpsPoints.add(currLocation.toLatLng);
    final angle = LocationHelper.calculateAngle(
      lastLocation,
      currLocation,
      distance,
    );
    double altitudeCumulation = LocationHelper.calculateAltitudeDiff(
      lastLocation,
      currLocation,
    );

    final totalDistance = state.tripRecord.gpsDistance + (distance / 1000);
    final altitudeCumulative =
        state.tripRecord.altitudeCumulative + altitudeCumulation;

    // Log GPS data
    DataLogger.instance.logMap({
      'latitude': currLocation.latitude,
      'longitude': currLocation.longitude,
      'altitude': currLocation.altitude,
      'speed': currLocation.speed,
      'heading': currLocation.heading,
      'distance': distance,
      'totalDistance': totalDistance,
      'slope': angle,
    }, prefix: 'GPS');

    emit(
      state.copyWith(
        lastLocation: currLocation,
        locationSlope: angle,
        locationHeight: currLocation.altitude ?? 0,
        direction: currLocation.heading ?? 0,
        gpsPoints: gpsPoints,
        tripRecord: state.tripRecord.copyWith(
          gpsSpeed: (currLocation.speed ?? 0) * 3600 / 1000,
          gpsDistance: totalDistance,
          altitudeCumulative: altitudeCumulative,
        ),
      ),
    );
  }

  /// Initialize cubit
  void init() async {
    emit(state.copyWith(isConnnectingError: false));

    // Start data logging session
    await DataLogger.instance.startSession(
      metadata: {
        'deviceAddress': address,
        'vin': state.vin,
        'startTime': DateTime.now().toIso8601String(),
      },
    );

    // Start trip recording for JSON export
    TripStorage.instance.startRecording(
      metadata: {'deviceAddress': address, 'vin': state.vin},
    );

    if (address != null) {
      await BTConnection().connect(
        address: address,
        onData: _onDataReceived,
        onSuccess: _onSuccessfulConnection,
        onError: _onConnectionError,
      );
    } else {
      if (_everySecondTimer?.isActive != true) {
        _runTest();
      }
    }

    _listenForSensors();

    final gpsEnabled = await LocationHelper.checkLocationService();

    if (gpsEnabled) {
      Location.instance.changeSettings(accuracy: LocationAccuracy.navigation);
      locationSub = Location.instance.onLocationChanged.listen(
        _onLocationChanged,
      );
    }
  }

  /// Send command for preparing obd
  Future<void> _sendInitializeCommands() async {
    for (final comm in initializeCommands) {
      BTConnection().sendCommand(comm, onError: _insertError);
      if (comm == 'AT Z') {
        await Future.delayed(const Duration(milliseconds: 1000));
      } else {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }

  Future<void> initializeObd() async {
    emit(
      LiveDataState.init(
        pids: state.supportedPids,
        localFile: state.localData,
        fuelPrice: state.fuelPrice,
        tankSize: state.tripRecord.tankSize,
      ),
    );
    await _sendInitializeCommands();
    commands.add(BatteryVoltageCommand());
    commands.add(VinCommand());
    emit(state.copyWith(isRunning: true));
    _startSecondTimer();
    _startScoreTimer();

    lastReciveCommandTime = DateTime.now();
    _decideNextMove();
  }

  void sendCheckPidsCommands() {
    specialCommands.addAll(checkPidsCommands);
  }

  /// Start timer, which fire every second
  void _startSecondTimer() {
    _everySecondTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final isMotorOff =
          commands.safeFirst<FuelSystemStatusCommand>()?.status ==
          FuelSystemStatus.motorOff;
      if ((now.difference(lastReciveCommandTime).inSeconds >=
                  AppDurations.maxNoDataReciveSeconds ||
              isMotorOff) &&
          state.isRunning &&
          !state.isTripClosing) {
        motorOff();
      }
      final speed = commands.safeFirst<SpeedCommand>()?.result ?? 0;
      final rpm = commands.safeFirst<RpmCommand>()?.result ?? 0;
      final fuelStatus = commands.safeFirst<FuelSystemStatusCommand>();
      final tripStatus = fuelStatus?.tripStatus(speed);

      // Log periodic state snapshot (sensors, calculated values)
      final snapshotData = {
        'speed': speed,
        'rpm': rpm,
        'gForce': state.gForce,
        'xAcc': state.xAccData,
        'yAcc': state.yAccData,
        'zAcc': state.zAccData,
        'tripStatus': tripStatus?.name,
        'usedFuel': state.tripRecord.usedFuel,
        'distance': state.tripRecord.distance,
        'avgFuelConsumption': state.tripRecord.avgFuelConsumption,
        'instFuelConsumption': state.tripRecord.instFuelConsumption,
        'fuelLevel': state.tripRecord.currentFuelLvl,
        'gpsSpeed': state.tripRecord.gpsSpeed,
        'altitude': state.locationHeight,
        'slope': state.locationSlope,
      };
      DataLogger.instance.logMap(snapshotData, prefix: 'SNAPSHOT');

      // Record snapshot for trip JSON export
      TripStorage.instance.recordSnapshot(snapshotData);

      emit(
        state.copyWith(
          averageResponseTime: averageResponseTime,
          totalResponseTime: totalResponseTime,
          tripRecord: state.tripRecord.updateTripStatus(speed, rpm, tripStatus),
        ),
      );
    });
  }

  void _startScoreTimer() {
    _everyMinuteTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      calculateScore();
    });
  }

  /// Testing local file of recorded trips
  Future<void> _runTest() async {
    final json = await rootBundle.loadString(
      'assets/json/${state.localData}.json',
    );
    final decoded = List<Map<String, dynamic>>.from(jsonDecode(json));
    final testCommands = decoded.map(TestCommand.fromJson).toList();
    emit(state.localMode());
    commands.add(BatteryVoltageCommand());
    commands.add(VinCommand());
    _startSecondTimer();
    _startScoreTimer();
    int index = 0;
    final percentyl = testCommands.length > 10000
        ? testCommands.length ~/ 10000
        : 1; // 0.01%
    for (final testCommand in testCommands) {
      commands
          .safeFirstWhere(
            (element) =>
                element.command == testCommand.command.replaceAll(' ', ''),
          )
          ?.sendCommand(isLocalMode: true);
      if (testCommand.responseTime > 0) {
        await Future.delayed(Duration(milliseconds: testCommand.responseTime));
      } else {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      if (_everySecondTimer?.isActive == true) {
        _onDataReceived(testCommand.data);
        index++;
        if (index % percentyl == 0) {
          final percentage = (index / testCommands.length) * 100;
          emit(state.copyWith(localTripProgress: percentage));
        }
      }
    }

    _everySecondTimer?.cancel();
    _runTest();
  }

  /// Modify commands list
  void editCommandList(bool value, String pid) {
    if (value) {
      addCommand(pid);
    } else {
      removeCommand(pid);
    }
  }

  void addCommand(String command) {
    final pid = PIDExtension.code(command.substring(command.length - 2));
    final obdCommand = pid.command;
    if (obdCommand == null) {
      print('Unsupported PID: $command');
      return;
    }

    commands.add(obdCommand);
  }

  void removeCommand(String command) {
    commands.removeWhere((element) => element.command == command);
  }

  /// Find next command to send
  Future<void> _sendNextCommand() async {
    String? _command;
    if (pidsQueue.isNotEmpty) {
      _command = pidsQueue.removeFirst();
    } else if (specialCommands.isNotEmpty) {
      _command = specialCommands.removeFirst();
    } else {
      while (_command == null) {
        if (commands.isNotEmpty) {
          _commandIndex++;
          _commandIndex %= commands.length;
          _command = commands[_commandIndex].sendCommand();
        }
      }
    }
    await BTConnection().sendCommand(_command, onError: _insertError);
  }

  /// Process closing trip after detect motor off
  Future<void> motorOff() async {
    if (state.isLocalMode) return;
    _everySecondTimer?.cancel();

    // Stop data logging session
    await DataLogger.instance.stopSession();

    // Save trip to JSON file
    if (state.tripRecord.totalTripSeconds > 30) {
      await TripStorage.instance.stopRecording(
        _tripRecordToJson(state.tripRecord),
        metadata: {'vin': state.vin, 'deviceAddress': address},
      );
    } else {
      TripStorage.instance.cancelRecording();
    }

    final fuelLevel = commands.fuelLevel;
    if (fuelLevel != null) {
      GlobalBlocs.settings.updateLeftFuel(fuelLevel);
      GlobalBlocs.settings.updateStats(
        fuelLeft: fuelLevel,
        distance: state.tripRecord.distance,
        fuelUsed: state.tripRecord.totalFuelUsed,
      );
    }
    emit(state.copyWith(isTripClosing: true, isTripEnded: true));
    BTConnection().close();
    if (state.tripRecord.totalTripSeconds > 30) {
      await FirestoreHandler.saveTripDataset(state.datasets);
      // saveCommands();
      // await generateTripSummary();
    }

    await goBackWithDelay();
  }

  /// Wait x seconds before closing with showing info to user
  Future<void> goBackWithDelay() async {
    await Future.delayed(AppDurations.closingTripDuration);
    if (Navigation.instance.canPop()) Navigation.instance.pop();
  }

  Future<void> calculateScore() async {
    final tripScoreModel = state.toTripScoreModel();
    if (!state.isLocalMode) {
      final tripDataset = TripDatasetModelExtension.fromTripScoreModel(
        tripScoreModel,
      );
      emit(state.addDataset(tripDataset));
    }
    final data = TripDatasetModelExtension.fromTripScoreModel(tripScoreModel);
    final eco = ecoModel?.predict(
      DataFrame([data.toEcoRow], headerExists: false),
    );
    final smooth = smoothModel?.predict(
      DataFrame([data.toSmoothRow], headerExists: false),
    );
    final ecoScore = eco?.rows.first.first as double;
    final smoothScore = smooth?.rows.first.first as double;
    emit(
      state.copyWith(
        ecoScore: ecoScore,
        smoothScore: smoothScore,
        previousEcoScore: state.ecoScore,
        previousSmoothScore: state.smoothScore,
      ),
    );
    lastTripScoreModel = tripScoreModel;
  }

  TripScoreModel? lastTripScoreModel;

  Future<void> generateTripSummary() async {
    final tripSummary = TripSummary(
      id: const Uuid().v1(),
      startTripTime: state.tripRecord.startTripDate,
      endTripTime: DateTime.now(),
      distance: state.tripRecord.distance,
      gpsDistance: state.tripRecord.gpsDistance,
      avgSpeed: state.tripRecord.averageSpeed,
      fuelUsed: state.tripRecord.usedFuel,
      tripSeconds: state.tripRecord.tripSeconds,
      idleTripSeconds: state.tripRecord.idleTripSeconds,
      rapidAccelerations: state.tripRecord.rapidAccelerations,
      rapidBreakings: state.tripRecord.rapidBreakings,
      startFuelLvl: state.tripRecord.startFuelLvl,
      endFuelLvl: state.tripRecord.currentFuelLvl,
      fuelPrice: state.fuelPrice,
      avgFuelConsumption: state.tripRecord.avgFuelConsumption,
      savedFuel: state.tripRecord.savedFuel,
      idleFuel: state.tripRecord.idleUsedFuel,
      driveFuel: state.tripRecord.usedFuel,
      startLocation: state.firstLocation?.toLatLng,
      endLocation: state.lastLocation?.toLatLng,
      hightGforce: state.tripRecord.highGforce,
      leftTurns: state.tripRecord.leftTurns,
      rightTurns: state.tripRecord.rightTurns,
      tankSize: state.tripRecord.tankSize,
      altitudeCumulative: state.tripRecord.altitudeCumulative,
      overRPMDriveTime: state.tripRecord.overRPMDriveTime,
      underRPMDriveTime: state.tripRecord.underRPMDriveTime,
      locations: state.gpsPoints,
      accDecc: state.tripRecord.accDecc,
      starts: state.tripRecord.starts,
      ecoScore: state.ecoScore,
      smoothScore: state.smoothScore,
      vin: GlobalBlocs.settings.state.settings.vin,
    );
    await FirestoreHandler.saveTripSummary(tripSummary);
  }

  /// Save commands for future local testing
  Future<void> saveCommands() async {
    try {
      await TripFiles.saveCommandsToFile(testCommands);
      testCommands.clear();
    } catch (e) {
      _insertError(e.toString());
    }
  }

  /// Check if need to send special command
  void _decideNextMove() {
    final specialCommand = state.pidsChecker.nextReadPidsPart;
    if (specialCommand != null && specialCommands.isEmpty) {
      specialCommands.add(specialCommand);
    }
    _sendNextCommand();
  }

  /// Processing fetched data from OBD II
  void _onDataReceived(Uint8List data) {
    if (isClosed) return;
    try {
      String dataString = String.fromCharCodes(data);
      emit(state.copyWith(lastReceivedData: dataString));
      if (dataString.trim().isEmpty) {
        return;
      }

      /// Fetching battery voltage
      if (dataString.contains('.') && dataString.contains('V')) {
        _processBatteryVoltageCommand(dataString, data);
      }

      if (dataString.endsWith(Strings.promptCharacter)) {
        if (!state.isLocalMode && state.isRunning) {
          _decideNextMove();
        }

        return;
      }
      lastReciveCommandTime = DateTime.now();

      /// Fetch vin data
      if (dataString.startsWith('014')) {
        final receivedData = ReceivedData(
          data: data,
          command: '0902',
          splitted: [dataString],
        );
        final now = DateTime.now();
        final difference = now
            .difference(lastTestCommandTime)
            .inMilliseconds
            .abs();
        lastTestCommandTime = now;

        // Create test commands
        if (!state.isLocalMode) {
          final testCommand = TestCommand(
            '09${receivedData.command}',
            difference,
            data,
          );
          testCommands.add(testCommand);
        }
        commands.safeFirst<VinCommand>()?.commandBack(
          receivedData.data,
          state.isLocalMode,
        );

        final vin = commands.safeFirst<VinCommand>()?.vin;
        emit(state.copyWith(vin: vin));
        GlobalBlocs.settings.updateVin(vin);
        return;
      } else if (dataString.startsWith('41')) {
        final receivedData = _convertReceivedData(dataString);
        final pid = PIDExtension.code(receivedData.command);
        final specialPid = SpecialPIDExtension.code(receivedData.command);
        final now = DateTime.now();
        final difference = now
            .difference(lastTestCommandTime)
            .inMilliseconds
            .abs();
        lastTestCommandTime = now;

        // Create test commands
        if (!state.isLocalMode) {
          final testCommand = TestCommand(
            '01${receivedData.command}',
            difference,
            data,
          );
          testCommands.add(testCommand);
        }

        if (pid != PID.unknown && commands.isNotEmpty) {
          final dataIndex = commands.lastIndexWhere(
            (element) => element.command.substring(2) == receivedData.command,
          );
          if (dataIndex == -1) return;
          commands[dataIndex].commandBack(receivedData.data, state.isLocalMode);

          final tripRecord = state.tripRecord;
          final command = commands[dataIndex];

          // Log command to DataLogger
          DataLogger.instance.logCommand(command);

          switch (pid) {
            case PID.fuelSystemStatus:
              if (command is FuelSystemStatusCommand) {
                emit(state.copyWith(fuelSystemStatus: command.status));
              }
              break;
            case PID.fuelLevel:
              if (command is FuelLevelCommand) {
                final current = command.result.toDouble();
                final cached = GlobalBlocs.settings.state.settings.leftFuel;
                if (cached != null &&
                    current > cached + Constants.minFuelDiff &&
                    !state.alreadyAskedForFueling) {
                  AlertCenter.show(Alerts.refuelRecognized(current - cached));
                  emit(state.copyWith(alreadyAskedForFueling: true));
                }
                emit(
                  state.copyWith(tripRecord: tripRecord.updateFuelLvl(current)),
                );
              }
              break;
            case PID.maf:
              if (command is MafCommand) {
                final shortFuelTrim = _calculateShortFuelTrim();
                final longFuelTrim = _calculateLongFuelTrim();
                final instFuelConsumption = command.fuel100km(
                  tripRecord.currentSpeed,
                  shortFuelTrim,
                  longFuelTrim,
                  commands.airFuelRatio ?? 1.0,
                );

                emit(
                  state.copyWith(
                    tripRecord: tripRecord
                        .updateUsedFuel(
                          command.fuelUsed(),
                          commands.speed,
                          commands.fuelSystemStatus,
                          state.fuelPrice,
                        )
                        .copyWith(instFuelConsumption: instFuelConsumption),
                  ),
                );
              }
              break;
            case PID.intakeManifoldAbsolutePressure:
              if (command is MapCommand) {
                // Oblicz zużycie paliwa z MAP gdy MAF nie jest dostępny
                // Sprawdzamy czy MAF (PID 10) jest na liście obsługiwanych PIDów
                final mafPid = '01${Pids.maf}'; // 0110
                final hasMaf =
                    state.supportedPids.contains(mafPid) ||
                    state.supportedPids.contains(Pids.maf);
                if (!hasMaf) {
                  final shortFuelTrim = _calculateShortFuelTrim();
                  final longFuelTrim = _calculateLongFuelTrim();
                  final settingsCapacity =
                      GlobalBlocs.settings.state.settings.engineCapacity;
                  // Domyślnie 1600 cm³ jeśli nie podano lub 0
                  final engineCapacity = settingsCapacity > 0
                      ? settingsCapacity
                      : 1600;
                  final rpm = commands.rpm;
                  final intakeAirTemp = commands.intakeAirTemp;

                  final instFuelConsumption = command.fuel100kmFromMAP(
                    speed: tripRecord.currentSpeed,
                    rpm: rpm,
                    intakeAirTemp: intakeAirTemp,
                    engineDisplacementCc: engineCapacity,
                    longTerm: longFuelTrim,
                    shortTerm: shortFuelTrim,
                    ratio: commands.airFuelRatio ?? 1.0,
                  );

                  emit(
                    state.copyWith(
                      tripRecord: tripRecord
                          .updateUsedFuel(
                            command.fuelUsed(),
                            commands.speed,
                            commands.fuelSystemStatus,
                            state.fuelPrice,
                          )
                          .copyWith(instFuelConsumption: instFuelConsumption),
                    ),
                  );
                }
              }
              break;
            case PID.speed:
              if (command is SpeedCommand) {
                final acceleration = command.acceleration();
                final accelerations = List<double>.from(state.acceleration);
                accelerations.addWithMax(acceleration, 100);
                emit(
                  state.copyWith(
                    acceleration: accelerations,
                    tripRecord: tripRecord
                        .updateDistance(
                          command.distanceTraveled,
                          command.result.toInt(),
                        )
                        .updateRapidAcceleration(acceleration: acceleration),
                  ),
                );
              }
              break;
            default:
              break;
          }
        } else if (specialPid != SpecialPID.unknown) {
          _processSpecialPid(receivedData);
        } else {
          final error = commands.isEmpty
              ? 'Commands list is empty'
              : 'Unsupported pid: ${receivedData.command}, description: ${pidsDescription[receivedData.command]}';
          _insertError(error);
        }
      } else {
        _insertError('Not recognized data: $dataString, values: $data');
      }
    } catch (e) {
      _insertError(e.toString());
    }
  }

  void _processBatteryVoltageCommand(String dataString, Uint8List data) {
    final dataIndex = commands.lastIndexWhere(
      (element) => element is BatteryVoltageCommand,
    );
    var numbers = doubleRE
        .allMatches(dataString)
        .map((m) => double.tryParse(m[0] ?? ''))
        .toList();
    final value = numbers.first;

    if (dataIndex == -1 || value == null) return;
    final voltage = (value * 10).toInt();
    commands[dataIndex].commandBack([voltage], state.isLocalMode);

    final now = DateTime.now();
    final difference = now.difference(lastTestCommandTime).inMilliseconds.abs();
    lastTestCommandTime = now;

    // Create test commands
    if (!state.isLocalMode) {
      final testCommand = TestCommand('ATRV', difference, data);
      testCommands.add(testCommand);
    }
  }

  void _processSpecialPid(ReceivedData receivedData) {
    final pids = CheckPidsCommand.extractSupportedPids(
      receivedData.splitted,
      receivedData.command,
    );
    final checkPid = pids
        .where((element) => checkPidsCommands.contains(element))
        .toList();
    if (checkPid.isNotEmpty) {
      final special = checkPid.first;
      specialCommands.add(special);
      pids.remove(special);
      emit(state.updateSupportedPidsPart(special));
    }
    final currentPids = List<String>.from(state.supportedPids);
    for (var pid in pids) {
      if (!currentPids.contains(pid)) addCommand(pid);
    }
    currentPids.addAll(pids);
    emit(
      state
          .updateReadedPidsPart('01${receivedData.command}')
          .copyWith(supportedPids: currentPids.toSet().toList()),
    );
  }

  // Convert [dataString] to more readable struct
  ReceivedData _convertReceivedData(String dataString) {
    final splitted = <String>[];
    for (int i = 0; i <= dataString.length - 2; i += 2) {
      splitted.add(dataString.substring(i, i + 2));
    }
    final data = splitted
        .skip(2)
        .map((hex) => int.parse(hex, radix: 16))
        .toList();

    return ReceivedData(data: data, command: splitted[1], splitted: splitted);
  }

  void _insertError(String error) {
    final errors = List<String>.from(state.errors);
    errors.add(error);
    Logger.logToFile(error);
    emit(state.copyWith(errors: errors));
  }

  void listenAllPids(List<String> pids) {
    pidsQueue.addAll(pids);
  }

  int get totalResponseTime => commands.isEmpty
      ? 0
      : commands.fold<int>(
          0,
          (previousValue, element) => previousValue + element.responseTime,
        );

  int get averageResponseTime =>
      commands.isEmpty ? 0 : (totalResponseTime / commands.length).ceil();

  double _calculateShortFuelTrim() => (commands.stft1 + commands.stft2) / 100;
  double _calculateLongFuelTrim() => (commands.ltft1 + commands.ltft2) / 100;

  /// Convert TripRecord to JSON map for storage
  Map<String, dynamic> _tripRecordToJson(TripRecord record) => {
    'startFuelLvl': record.startFuelLvl,
    'currentFuelLvl': record.currentFuelLvl,
    'instFuelConsumption': record.instFuelConsumption,
    'usedFuel': record.usedFuel,
    'idleUsedFuel': record.idleUsedFuel,
    'savedFuel': record.savedFuel,
    'tankSize': record.tankSize,
    'fuelPrice': record.fuelPrice,
    'gpsSpeed': record.gpsSpeed,
    'gpsDistance': record.gpsDistance,
    'altitudeCumulative': record.altitudeCumulative,
    'startTripDate': record.startTripDate.toIso8601String(),
    'tripSeconds': record.tripSeconds,
    'idleTripSeconds': record.idleTripSeconds,
    'currentDriveInterval': record.currentDriveInterval,
    'overRPMDriveTime': record.overRPMDriveTime,
    'underRPMDriveTime': record.underRPMDriveTime,
    'distance': record.distance,
    'currentSpeed': record.currentSpeed,
    'tripStatus': record.tripStatus.name,
    'rapidAccelerations': record.rapidAccelerations,
    'rapidBreakings': record.rapidBreakings,
    'leftTurns': record.leftTurns,
    'rightTurns': record.rightTurns,
    'highGforce': record.highGforce,
    'starts': record.starts,
    'accDecc': record.accDecc,
    // Computed values
    'totalFuelUsed': record.totalFuelUsed,
    'avgFuelConsumption': record.avgFuelConsumption,
    'averageSpeed': record.averageSpeed,
  };

  @override
  Future<void> close() async {
    _everySecondTimer?.cancel();
    _everyMinuteTimer?.cancel();
    // await saveCommands();

    // Stop data logging if still running
    if (DataLogger.instance.isLogging) {
      await DataLogger.instance.stopSession();
    }

    // Cancel trip recording if still running
    if (TripStorage.instance.isRecording) {
      TripStorage.instance.cancelRecording();
    }

    await BTConnection().close();
    await locationSub?.cancel();
    await _accSubscription?.cancel();
    await _gyroSubsription?.cancel();
    await _barometerSubscription?.cancel();
    super.close();
  }
}
