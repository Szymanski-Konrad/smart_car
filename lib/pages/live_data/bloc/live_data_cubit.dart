import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:environment_sensors/environment_sensors.dart';
import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_car/app/navigation/navigation.dart';
import 'package:smart_car/app/resources/configs.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/app/resources/pids.dart';
import 'package:smart_car/app/resources/strings.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/obd_command.dart';
import 'package:smart_car/pages/live_data/model/battery_voltage_command.dart';
import 'package:smart_car/pages/live_data/model/commands/check_commands/check_pids_command.dart';
import 'package:smart_car/pages/live_data/model/commaned_air_fuel_ratio_command.dart';
import 'package:smart_car/pages/live_data/model/fuel_level_command.dart';
import 'package:smart_car/pages/live_data/model/fuel_system_status_command.dart';
import 'package:smart_car/pages/live_data/model/maf_command.dart';
import 'package:smart_car/pages/live_data/model/speed_command.dart';
import 'package:smart_car/pages/live_data/model/term_fuel_trim_command.dart';
import 'package:smart_car/pages/live_data/model/test_data/test_command.dart';
import 'package:smart_car/pages/live_data/model/trip_record.dart';
import 'package:smart_car/utils/list_extension.dart';
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
  BluetoothConnection? _connection;
  StreamSubscription<Position>? positionSub;
  StreamSubscription<SensorEvent>? _accSubscription;
  Timer? _everySecondTimer;

  /// Initialize cubit
  void init() async {
    emit(state.copyWith(isConnnectingError: false));

    final stream = await SensorManager().sensorUpdates(
      sensorId: Sensors.ACCELEROMETER,
      interval: Sensors.SENSOR_DELAY_UI,
    );

    _accSubscription = stream.listen((event) {
      emit(state.copyWith(
        xAccelerometer: event.data[0],
        yAccelerometer: event.data[1],
        zAccelerometer: event.data[2],
      ));
    });

    commands.add(BatteryVoltageCommand());

    if (address != null) {
      BluetoothConnection.toAddress(address).then((connection) {
        _connection = connection;
        emit(state.copyWith(
          isConnecting: false,
          isDisconnecting: false,
        ));
        connection.input?.listen(_onDataReceived).onDone(() {
          print('Connection is done');
        });
        initializeObd();
        _initBackgroundWorking();
      }).catchError((error) {
        print('Cannot connect, exception occured');
        print(error);
        emit(state.copyWith(isConnnectingError: true));
      });
    } else if (kDebugMode) {
      _runTest();
    }

    final isTemperatureAvailable = await EnvironmentSensors()
        .getSensorAvailable(SensorType.AmbientTemperature);
    emit(state.copyWith(isTemperatureAvaliable: isTemperatureAvailable));
    if (isTemperatureAvailable) {
      EnvironmentSensors().temperature.listen((event) {
        emit(state.copyWith(temperature: event));
      });
    }

    positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: Constants.minGpsDistance,
      ),
    ).listen(onGpsPositionChange);
  }

  Future<void> _initBackgroundWorking() async {
    final hasPermissions = await FlutterBackground.initialize(
        androidConfig: Configs.backgroundConfig);
    if (hasPermissions) {
      await FlutterBackground.enableBackgroundExecution();
    }
  }

  void onGpsPositionChange(Position position) {
    final lastPosition = state.lastPosition;

    if (lastPosition != null) {
      final distance = Geolocator.distanceBetween(
        lastPosition.latitude,
        lastPosition.longitude,
        position.latitude,
        position.longitude,
      );
      final gpsSpeed = position.speed * 3600 / 1000;
      emit(state.copyWith(
          tripRecord: state.tripRecord.copyWith(gpsSpeed: gpsSpeed)));
      if (distance > Constants.minGpsDistance) {
        final gpsDistance = state.tripRecord.gpsDistance + (distance / 1000);
        emit(state.copyWith(
          tripRecord: state.tripRecord.copyWith(
            gpsDistance: gpsDistance,
            gpsSpeed: gpsSpeed,
          ),
        ));
      }
    }
    emit(state.copyWith(lastPosition: position));
  }

  Future<void> initializeObd() async {
    emit(LiveDataState.init(
      pids: state.supportedPids,
      localFile: state.localData,
      fuelPrice: state.fuelPrice,
    ));
    _sendCommand('AT Z'); // Reset obd
    await Future.delayed(const Duration(milliseconds: 1000));
    _sendCommand('AT E0'); // Echo off
    await Future.delayed(const Duration(milliseconds: 200));
    _sendCommand('AT L0'); // Line feed off
    await Future.delayed(const Duration(milliseconds: 200));
    _sendCommand('ATS0'); // Spaces off
    await Future.delayed(const Duration(milliseconds: 200));
    _sendCommand('AT ST 96'); // Set timeout 150 ms
    await Future.delayed(const Duration(milliseconds: 200));
    _sendCommand('AT SP 0'); // Select protocol command
    await Future.delayed(const Duration(milliseconds: 200));
    _sendCommand('AT E0'); // Echo off
    await Future.delayed(const Duration(milliseconds: 200));
    emit(state.copyWith(isRunning: true));
    _startSecondTimer();

    await _determinePosition();
    lastReciveCommandTime = DateTime.now();
    _decideNextMove();
  }

  void sendCheckPidsCommands() {
    specialCommands.addAll(checkPidsCommands);
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

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
        final fuelStatus =
            commands.safeFirst<FuelSystemStatusCommand>()?.status;
        final tripStatus = speed < Constants.idleSpeedLimit
            ? TripStatus.idle
            : fuelStatus == FuelSystemStatus.fuelCut
                ? TripStatus.savingFuel
                : TripStatus.driving;
        emit(
          state.copyWith(
            averageResponseTime: averageResponseTime,
            totalResponseTime: totalResponseTime,
            tripStatus: tripStatus,
            tripRecord: state.tripRecord
                .updateSeconds(speed)
                .updateTripStatus(tripStatus),
          ),
        );
      },
    );
  }

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
      _onDataReceived(testCommand.data);
      index++;
      if (index % percentyl == 0) {
        final percentage = (index / testCommands.length) * 100;
        emit(state.copyWith(localTripProgress: percentage));
      }
    }

    _everySecondTimer?.cancel();
    _runTest();
  }

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
    await _sendCommand(_command);
  }

  Future<void> _sendCommand(String command) async {
    if (command.isNotEmpty) {
      try {
        final uft = Uint8List.fromList(utf8.encode(command + '\r\n'));
        _connection?.output.add(uft);
        await _connection?.output.allSent;
      } catch (e) {
        _insertError(e.toString());
      }
    }
  }

  /// Process closing trip after detect motor off
  Future<void> motorOff() async {
    if (state.isLocalMode) return;
    emit(state.copyWith(
      isTripClosing: true,
      isTripEnded: true,
    ));
    _connection?.close();
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
    final specialCommand = state.nextReadPidsPart;
    if (specialCommand != null && specialCommands.isEmpty) {
      specialCommands.add(specialCommand);
    }
    _sendNextCommand();
  }

  void _onDataReceived(Uint8List data) {
    lastReciveCommandTime = DateTime.now();

    try {
      String dataString = String.fromCharCodes(data);
      if (dataString.trim().isEmpty) {
        return;
      }

      if (dataString.endsWith(Strings.promptCharacter)) {
        if (!state.isLocalMode && state.isRunning) {
          _decideNextMove();
        }

        return;
      }

      if (dataString.endsWith('V')) {
        final dataIndex =
            commands.lastIndexWhere((element) => element.command == 'ATRV');
        final value =
            double.tryParse(dataString.substring(1, dataString.length - 1));
        if (dataIndex == -1 || value == null) return;
        final voltage = (value * 10).toInt();
        commands[dataIndex].commandBack([voltage], state.isLocalMode);

        final now = DateTime.now();
        final difference =
            now.difference(lastTestCommandTime).inMilliseconds.abs();
        lastTestCommandTime = now;

        // Create test commands
        if (!state.isLocalMode) {
          final testCommand = TestCommand('ATRV', difference, data);
          testCommands.add(testCommand);
        }
      }

      if (dataString.startsWith('41')) {
        final splitted = <String>[];
        for (int i = 0; i <= dataString.length - 2; i += 2) {
          splitted.add(dataString.substring(i, i + 2));
        }
        final converted =
            splitted.skip(2).map((hex) => int.parse(hex, radix: 16)).toList();

        final pid = PIDExtension.code(splitted[1]);
        final specialPid = SpecialPIDExtension.code(splitted[1]);
        final now = DateTime.now();
        final difference =
            now.difference(lastTestCommandTime).inMilliseconds.abs();
        lastTestCommandTime = now;

        // Create test commands
        if (!state.isLocalMode) {
          final testCommand = TestCommand('01${splitted[1]}', difference, data);
          testCommands.add(testCommand);
        }

        if (pid != PID.unknown && commands.isNotEmpty) {
          final dataIndex = commands.lastIndexWhere(
              (element) => element.command.substring(2) == splitted[1]);
          if (dataIndex == -1) return;
          commands[dataIndex].commandBack(converted, state.isLocalMode);

          final tripRecord = state.tripRecord;
          final command = commands[dataIndex];

          switch (pid) {
            case PID.engineLoad:
              emit(state.copyWith(
                  tripRecord:
                      tripRecord.updateEngineLoad(command.result.toDouble())));
              break;
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
                final stft1 =
                    commands.safeFirst<ShortTermFuelTrimBank1>()?.result;
                final ltft1 =
                    commands.safeFirst<LongTermFuelTrimBank1>()?.result;
                final stft2 =
                    commands.safeFirst<ShortTermFuelTrimBank2>()?.result;
                final ltft2 =
                    commands.safeFirst<LongTermFuelTrimBank2>()?.result;
                final airFuelRatio =
                    commands.safeFirst<CommandedAirFuelRatioCommand>()?.result;

                final shortFuelTrim =
                    1.0 + (stft1 ?? 0.0 + (stft2 ?? 0.0)).toDouble();
                final longFuelTrim =
                    1.0 + (ltft1 ?? 0.0 + (ltft2 ?? 0.0)).toDouble();

                final usedFuel = command.fuelUsed;
                final instFuelConsumption = command.fuel100km(
                  tripRecord.currentSpeed,
                  tripRecord.engineLoad,
                  shortFuelTrim,
                  longFuelTrim,
                  (airFuelRatio ?? 1.0) * 14.7,
                );
                final avgFuelConsumption =
                    100 * tripRecord.usedFuel / tripRecord.distance;
                final speed = commands.safeFirst<SpeedCommand>()?.result;
                final fuelStatus =
                    commands.safeFirst<FuelSystemStatusCommand>()?.status;
                final kmPerL = command.kmPerL(tripRecord.currentSpeed);

                emit(state.copyWith(
                  tripRecord: tripRecord
                      .updateUsedFuel(
                        usedFuel(tripRecord.engineLoad),
                        speed ?? 0,
                        fuelStatus ?? FuelSystemStatus.motorOff,
                        state.fuelPrice,
                      )
                      .copyWith(
                        instFuelConsumption: instFuelConsumption,
                        averageFuelConsumption: avgFuelConsumption,
                        kmPerL: kmPerL,
                      )
                      .updateRange(),
                ));
              }
              break;
            case PID.speed:
              if (command is SpeedCommand) {
                final distance = command.distanceTraveled;
                final acceleration = command.acceleration();
                emit(state.copyWith(
                  tripRecord: tripRecord
                      .updateDistance(distance, command.result.toInt())
                      .updateRapidAcceleration(acceleration: acceleration),
                  acceleration: acceleration,
                ));
              }
              break;
            default:
              break;
          }
        } else if (specialPid != SpecialPID.unknown) {
          final pids = CheckPidsCommand.extractSupportedPids(
              splitted.toList(), splitted[1]);
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
          emit(state
              .updateReadedPidsPart('01' + splitted[1])
              .copyWith(supportedPids: currentPids.toSet().toList()));
        } else {
          final error = commands.isEmpty
              ? 'Commands list is empty'
              : 'Unsupported pid: ${splitted[1]}, description: ${pidsDescription[splitted[1]]}';
          _insertError(error);
        }
      }
    } catch (e) {
      _insertError(e.toString());
    }
  }

  void _insertError(String error) {
    final errors = List<String>.from(state.errors);
    errors.add(error);
    logToFile(error);
    emit(state.copyWith(errors: errors));
  }

  void logToFile(Object data) {
    if (data.toString().isNotEmpty) {
      FlutterLogs.logToFile(
        appendTimeStamp: true,
        logFileName: "device",
        overwrite: false,
        logMessage: '${data.toString()}\n',
      );
    }
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

  @override
  Future<void> close() async {
    _everySecondTimer?.cancel();
    _accSubscription?.cancel();
    await saveCommands();
    await _connection?.finish();
    await positionSub?.cancel();
    if (FlutterBackground.isBackgroundExecutionEnabled) {
      await FlutterBackground.disableBackgroundExecution();
    }
    super.close();
  }
}
