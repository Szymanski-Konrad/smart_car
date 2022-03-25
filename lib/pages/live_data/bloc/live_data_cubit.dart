import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:environment_sensors/environment_sensors.dart';
import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sensors/flutter_sensors.dart';

import 'package:location/location.dart';
import 'package:smart_car/app/navigation/navigation.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/app/resources/pids.dart';
import 'package:smart_car/app/resources/strings.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/obd_command.dart';
import 'package:smart_car/pages/live_data/model/battery_voltage_command.dart';
import 'package:smart_car/pages/live_data/model/commands/check_commands/check_pids_command.dart';
import 'package:smart_car/pages/live_data/model/commands/pids_checker.dart';
import 'package:smart_car/pages/live_data/model/fuel_level_command.dart';
import 'package:smart_car/pages/live_data/model/fuel_system_status_command.dart';
import 'package:smart_car/pages/live_data/model/maf_command.dart';
import 'package:smart_car/pages/live_data/model/speed_command.dart';
import 'package:smart_car/pages/live_data/model/test_data/test_command.dart';
import 'package:smart_car/pages/live_data/model/trip_record.dart';
import 'package:smart_car/utils/bt_connection.dart';
import 'package:smart_car/utils/list_extension.dart';
import 'package:smart_car/utils/location_helper.dart';
import 'package:smart_car/utils/logger.dart';
import 'package:smart_car/utils/obd_commands_extensions.dart';
import 'package:smart_car/utils/trip_files.dart';
import 'package:smart_car/utils/ui/countdown_text.dart';

class LiveDataCubit extends Cubit<LiveDataState> {
  LiveDataCubit({
    required this.address,
    String? localFile,
    required double fuelPrice,
  }) : super(LiveDataState.init(
          localFile: localFile,
          fuelPrice: fuelPrice,
        )) {
    init();
  }

  final String? address;
  int _commandIndex = 0;
  List<TestCommand> testCommands = [];
  List<ObdCommand> commands = [];
  Queue<String> specialCommands = Queue();
  Queue<String> pidsQueue = Queue<String>();
  DateTime? lastDataReciveTime;
  DateTime lastReciveCommandTime = DateTime.now();
  DateTime lastTestCommandTime = DateTime.now();

  StreamSubscription<LocationData>? locationSub;
  StreamSubscription<SensorEvent>? _accSubscription;
  StreamSubscription? _tempSubscription;
  Timer? _everySecondTimer;
  Location location = Location();
  final doubleRE = RegExp(r"-?(?:\d*\.)?\d+(?:[eE][+-]?\d+)?");

  /// Called when succesfully connected to OBD
  void _onSuccessfulConnection() {
    emit(state.copyWith(
      isConnecting: false,
      isDisconnecting: false,
    ));

    initializeObd();
  }

  /// Called when occured some connection error
  void _onConnectionError() {
    emit(state.copyWith(isConnnectingError: true));
  }

  Future<void> _listenForSensors() async {
    final stream = await SensorManager().sensorUpdates(
      sensorId: Sensors.ACCELEROMETER,
      interval: Sensors.SENSOR_DELAY_NORMAL,
    );

    _accSubscription = stream.listen((event) {
      emit(state.copyWith(
        xAccelerometer: event.data[0],
        yAccelerometer: event.data[1],
        zAccelerometer: event.data[2],
      ));
    });

    final isTemperatureAvailable = await EnvironmentSensors()
        .getSensorAvailable(SensorType.AmbientTemperature);
    if (isTemperatureAvailable) {
      _tempSubscription = EnvironmentSensors().temperature.listen((event) {
        emit(state.copyWith(temperature: event));
      });
    }

    emit(state.copyWith(isTemperatureAvaliable: isTemperatureAvailable));

    location.changeSettings(
      accuracy: LocationAccuracy.high,
    );
  }

  void _onLocationChanged(LocationData currLocation) {
    final lastLocation = state.lastLocation;
    if (lastLocation == null) {
      emit(state.copyWith(lastLocation: currLocation));
      return;
    }
    final distance =
        LocationHelper.calculateDistance(lastLocation, currLocation);
    final angle =
        LocationHelper.calculateAngle(lastLocation, currLocation, distance);
    final totalDistance = state.tripRecord.gpsDistance + (distance / 1000);
    emit(state.copyWith(
      lastLocation: currLocation,
      locationSlope: angle,
      locationHeight: currLocation.altitude ?? 0,
      direction: currLocation.heading ?? 0,
      tripRecord: state.tripRecord.copyWith(
        gpsSpeed: (currLocation.speed ?? 0) * 3600 / 1000,
        gpsDistance: totalDistance,
      ),
    ));
  }

  /// Initialize cubit
  void init() async {
    emit(state.copyWith(isConnnectingError: false));

    if (address != null) {
      await BTConnection().connect(
        address: address,
        onData: _onDataReceived,
        onSuccess: _onSuccessfulConnection,
        onError: _onConnectionError,
      );
    } else if (kDebugMode) {
      _runTest();
    } else {
      return;
    }

    commands.add(BatteryVoltageCommand());
    _listenForSensors();

    locationSub = location.onLocationChanged.listen(_onLocationChanged);
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
    emit(LiveDataState.init(
      pids: state.supportedPids,
      localFile: state.localData,
      fuelPrice: state.fuelPrice,
    ));
    await _sendInitializeCommands();
    emit(state.copyWith(isRunning: true));
    _startSecondTimer();

    await LocationHelper.checkLocationService(location);

    lastReciveCommandTime = DateTime.now();
    _decideNextMove();
  }

  void sendCheckPidsCommands() {
    specialCommands.addAll(checkPidsCommands);
  }

  /// Start timer, which fire every second
  void _startSecondTimer() {
    _everySecondTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        final now = DateTime.now();
        if (now.difference(lastReciveCommandTime).inSeconds >=
                Durations.maxNoDataReciveSeconds &&
            !state.isTripClosing) {
          motorOff();
        }
        final speed = commands.safeFirst<SpeedCommand>()?.result ?? 0;
        final fuelStatus = commands.safeFirst<FuelSystemStatusCommand>();
        final tripStatus = fuelStatus?.tripStatus(speed);
        emit(
          state.copyWith(
            averageResponseTime: averageResponseTime,
            totalResponseTime: totalResponseTime,
            tripRecord: state.tripRecord.updateTripStatus(speed, tripStatus),
          ),
        );
      },
    );
  }

  /// Testing local file of recorded trips
  Future<void> _runTest() async {
    final json =
        await rootBundle.loadString('assets/json/${state.localData}.json');
    final decoded = List<Map<String, dynamic>>.from(jsonDecode(json));
    final testCommands = decoded.map(TestCommand.fromJson).toList();
    emit(state.localMode());
    _startSecondTimer();
    int index = 0;
    final percentyl =
        testCommands.length > 10000 ? testCommands.length ~/ 10000 : 1; // 0.01%
    for (final testCommand in testCommands) {
      commands
          .safeFirstWhere((element) =>
              element.command == testCommand.command.replaceAll(' ', ''))
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
    emit(state.copyWith(
      isTripClosing: true,
      isTripEnded: true,
    ));
    BTConnection().close();
    saveCommands();
    await goBackWithDelay();
  }

  /// Wait x seconds before closing with showing info to user
  Future<void> goBackWithDelay() async {
    await showAndroidToast(
      backgroundColor: Colors.green,
      alignment: Alignment.center,
      child: const CountDownText(duration: Durations.closingTripDuration),
      duration: Durations.closingTripDuration,
      context: ToastProvider.context,
    );
    if (Navigation.instance.canPop()) Navigation.instance.pop();
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
    try {
      String dataString = String.fromCharCodes(data);
      if (dataString.trim().isEmpty) {
        return;
      }

      if ((dataString.contains('.') ||
              dataString.contains('V') ||
              dataString.contains('ATRV')) &&
          !dataString.contains('ELM')) {
        _processBatteryVoltageCommand(dataString, data);
      }

      if (dataString.endsWith(Strings.promptCharacter)) {
        if (!state.isLocalMode && state.isRunning) {
          _decideNextMove();
        }

        return;
      }
      lastReciveCommandTime = DateTime.now();

      if (dataString.startsWith('41')) {
        final receivedData = _convertReceivedData(dataString);
        final pid = PIDExtension.code(receivedData.command);
        final specialPid = SpecialPIDExtension.code(receivedData.command);
        final now = DateTime.now();
        final difference =
            now.difference(lastTestCommandTime).inMilliseconds.abs();
        lastTestCommandTime = now;

        // Create test commands
        if (!state.isLocalMode) {
          final testCommand =
              TestCommand('01${receivedData.command}', difference, data);
          testCommands.add(testCommand);
        }

        if (pid != PID.unknown && commands.isNotEmpty) {
          final dataIndex = commands.lastIndexWhere((element) =>
              element.command.substring(2) == receivedData.command);
          if (dataIndex == -1) return;
          commands[dataIndex].commandBack(receivedData.data, state.isLocalMode);

          final tripRecord = state.tripRecord;
          final command = commands[dataIndex];

          switch (pid) {
            case PID.fuelSystemStatus:
              if (command is FuelSystemStatusCommand) {
                emit(state.copyWith(fuelSystemStatus: command.status));
              }
              break;
            case PID.fuelLevel:
              if (command is FuelLevelCommand) {
                emit(state.copyWith(
                  tripRecord:
                      tripRecord.updateFuelLvl(command.result.toDouble()),
                ));
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
                  (commands.airFuelRatio ?? 1.0) * 14.7,
                );

                emit(state.copyWith(
                  tripRecord: tripRecord
                      .updateUsedFuel(
                        command.fuelUsed(),
                        commands.speed,
                        commands.fuelSystemStatus,
                        state.fuelPrice,
                      )
                      .copyWith(instFuelConsumption: instFuelConsumption),
                ));
              }
              break;
            case PID.speed:
              if (command is SpeedCommand) {
                final acceleration = command.acceleration();
                emit(state.copyWith(
                  tripRecord: tripRecord
                      .updateDistance(
                        command.distanceTraveled,
                        command.result.toInt(),
                      )
                      .updateRapidAcceleration(acceleration: acceleration),
                ));
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
        _insertError('Not recognized data: $dataString');
      }
    } catch (e) {
      _insertError(e.toString());
    }
  }

  void _processBatteryVoltageCommand(String dataString, Uint8List data) {
    final dataIndex =
        commands.lastIndexWhere((element) => element is BatteryVoltageCommand);
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
    final checkPid =
        pids.where((element) => checkPidsCommands.contains(element)).toList();
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
    emit(state
        .updateReadedPidsPart('01' + receivedData.command)
        .copyWith(supportedPids: currentPids.toSet().toList()));
  }

  // Convert [dataString] to more readable struct
  ReceivedData _convertReceivedData(String dataString) {
    final splitted = <String>[];
    for (int i = 0; i <= dataString.length - 2; i += 2) {
      splitted.add(dataString.substring(i, i + 2));
    }
    final data =
        splitted.skip(2).map((hex) => int.parse(hex, radix: 16)).toList();

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
          0, (previousValue, element) => previousValue + element.responseTime);

  int get averageResponseTime =>
      commands.isEmpty ? 0 : (totalResponseTime / commands.length).ceil();

  double _calculateShortFuelTrim() =>
      1.0 + (commands.stft1 + commands.stft2) / 100;
  double _calculateLongFuelTrim() =>
      1.0 + (commands.ltft1 + commands.ltft2) / 100;

  @override
  Future<void> close() async {
    _everySecondTimer?.cancel();
    await saveCommands();
    await BTConnection().close();
    await locationSub?.cancel();
    await _accSubscription?.cancel();
    await _tempSubscription?.cancel();
    super.close();
  }
}
