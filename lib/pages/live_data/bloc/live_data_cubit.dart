import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_car/app/example/trips/long_trip.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/app/resources/pids.dart';
import 'package:smart_car/app/resources/strings.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/obd_command.dart';
import 'package:smart_car/pages/live_data/model/commands/check_commands/check_pids_command.dart';
import 'package:smart_car/pages/live_data/model/commands/oxygen_commands/oxygen_senor_volts.dart';
import 'package:smart_car/pages/live_data/model/commaned_air_fuel_ratio_command.dart';
import 'package:smart_car/pages/live_data/model/engine_coolant_command.dart';
import 'package:smart_car/pages/live_data/model/engine_load_command.dart';
import 'package:smart_car/pages/live_data/model/fuel_level_command.dart';
import 'package:smart_car/pages/live_data/model/fuel_system_status_command.dart';
import 'package:smart_car/pages/live_data/model/intake_air_temp_command.dart';
import 'package:smart_car/pages/live_data/model/maf_command.dart';
import 'package:smart_car/pages/live_data/model/oil_temp_command.dart';
import 'package:smart_car/pages/live_data/model/rpm_command.dart';
import 'package:smart_car/pages/live_data/model/speed_command.dart';
import 'package:smart_car/pages/live_data/model/term_fuel_trim_command.dart';
import 'package:smart_car/pages/live_data/model/test_data/test_command.dart';
import 'package:smart_car/pages/live_data/model/throttle_position_command.dart';
import 'package:smart_car/pages/live_data/model/trip_record.dart';
import 'package:sendgrid_mailer/sendgrid_mailer.dart';

class LiveDataCubit extends Cubit<LiveDataState> {
  LiveDataCubit({required this.device}) : super(LiveDataState.init()) {
    init();
  }

  // Commands to create test data to work without OBD
  List<TestCommand> testCommands = [];

  // list of commands to send
  List<ObdCommand> commands = [];
  Queue<String> specialCommands = Queue();
  Queue<String> commandsQueue = Queue();

  final BluetoothDevice device;
  int _commandIndex = 0;

  // Bluetooth
  BluetoothConnection? _connection;
  bool get isConnected => (_connection?.isConnected ?? false);

  // Timers
  Timer? _everySecondTimer;

  // GPS info
  StreamSubscription<Position>? positionSub;

  void onGpsPositionChange(Position position) {
    final lastPosition = state.lastPosition;

    if (lastPosition != null) {
      final distance = Geolocator.distanceBetween(lastPosition.latitude,
          lastPosition.longitude, position.latitude, position.longitude);
      final gpsSpeed = position.speed * 3600 / 1000;
      if (distance > Constants.minGpsDistance) {
        final gpsDistance = state.tripRecord.gpsDistance + (distance / 1000);
        emit(state.copyWith(
          tripRecord: state.tripRecord.copyWith(
            gpsDistance: gpsDistance,
            gpsSpeed: gpsSpeed,
          ),
          lastPosition: position,
        ));
      } else {
        emit(state.copyWith(
          tripRecord: state.tripRecord.copyWith(gpsSpeed: gpsSpeed),
        ));
      }
    } else {
      emit(state.copyWith(lastPosition: position));
    }
  }

  Future<void> initializeObd() async {
    emit(LiveDataState.init(pids: state.supportedPids));
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

    _everySecondTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      emit(state.copyWith(
        tripRecord: state.tripRecord.copyWith(tripSeconds: timer.tick),
      ));

      if (timer.tick % 600 == 0) saveCommands();
    });

    await _determinePosition();
    lastReciveCommandTime = DateTime.now();
    await _sendNextCommand();
  }

  void sendCheckPidsCommands() {
    specialCommands.addAll([
      '01 00',
      '01 20',
      '01 40',
      '01 60',
      '01 80',
      '01 A0',
      '01 C0',
    ]);
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

  Future<void> _runTest() async {
    final testCommands = longTrip.map(TestCommand.fromJson);

    emit(LiveDataState.init());
    emit(state.copyWith(isLocalMode: true));

    _everySecondTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final speed = commands.whereType<SpeedCommand>().first.result;
      if (speed.isFinite) {
        emit(state.copyWith(
            tripRecord: state.tripRecord.updateSeconds(speed.toInt())));
      }
      emit(state.copyWith(
        tripRecord: state.tripRecord.copyWith(tripSeconds: timer.tick),
      ));
    });

    for (final testCommand in testCommands) {
      await Future.delayed(Duration(milliseconds: testCommand.responseTime));
      _onDataReceived(testCommand.data);
    }

    _everySecondTimer?.cancel();
    _runTest();
  }

  void init() {
    commands.addAll([
      EngineCoolantCommand(),
      EngineLoadCommand(),
      FuelLevelCommand(),
      IntakeAirTempCommand(),
      MafCommand(),
      SpeedCommand(),
      RpmCommand(),
      // OilTempCommand(),
      ThrottlePositionCommand(),
      FuelSystemStatusCommand(),
      OxygenSensorVolts1(),
      OxygenSensorVolts2(),
      OxygenSensorVolts5(),
      OxygenSensorVolts6(),
      CommandedAirFuelRatioCommand(),
      ShortTermFuelTrimBank1(),
      LongTermFuelTrimBank1(),
      ShortTermFuelTrimBank2(),
      LongTermFuelTrimBank2(),
    ]);

    // userAccelerometerEvents.listen((UserAccelerometerEvent event) {
    //   emit(state.copyWith(
    //       userAccelerometer: '\n${event.x}\n${event.y}\n${event.z}'));
    // });

    positionSub = Geolocator.getPositionStream(
      intervalDuration: const Duration(milliseconds: 500),
    ).listen(onGpsPositionChange);

    if (device.address == 'AA:AA') {
      _runTest();
    } else {
      BluetoothConnection.toAddress(device.address).then((connection) {
        _connection = connection;
        emit(state.copyWith(
          isConnecting: false,
          isDisconnecting: false,
        ));
        connection.input?.listen(_onDataReceived).onDone(() {
          print('Connection is done');
        });
        initializeObd();
      }).catchError((error) {
        print('Cannot connect, exception occured');
        print(error);
      });
    }
  }

  void sendVinCommand() {
    specialCommands.add('0902');
  }

  void sendCheck9Command() {
    specialCommands.add('0900');
  }

  Queue<String> pidsQueue = Queue<String>();

  Future<void> _sendNextCommand() async {
    if (pidsQueue.isNotEmpty) {
      final command = pidsQueue.removeFirst();
      await _sendCommand(command);
    } else if (specialCommands.isNotEmpty) {
      final command = specialCommands.removeFirst();
      await _sendCommand(command);
    } else {
      String? _command;
      while (_command == null) {
        _commandIndex++;
        _commandIndex %= commands.length;
        _command = commands[_commandIndex].sendCommand();
      }
      await _sendCommand(_command);
    }
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

  Future<void> saveCommands() async {
    try {
      final feedback = jsonEncode(testCommands.map((e) => e.toJson()).toList());
      testCommands.clear();
      await sendFeedback(feedback: feedback);
    } catch (e) {
      _insertError(e.toString());
    }
  }

  Future<bool> sendFeedback({required String feedback}) async {
    final mailer = Mailer(
        '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');
    const toAddress = Address('hunteelar.programowanie@gmail.com');
    const fromAddress = Address('shoptogether07@gmail.com');
    final content = Content(
      'text/plain',
      feedback,
    );
    const subject = 'Trip json';
    const personalization = Personalization([toAddress]);
    final email =
        Email([personalization], fromAddress, subject, content: [content]);
    final result = await mailer.send(email);
    return !result.isError;
  }

  ObdCommand get _currentCommand => commands[_commandIndex];

  DateTime lastReciveCommandTime = DateTime.now();

  void _onDataReceived(Uint8List data) {
    try {
      String dataString = String.fromCharCodes(data);
      if (dataString.trim().isEmpty) {
        // logToFile('Data is empty: $data');
        return;
      }

      if (dataString.endsWith(Strings.promptCharacter)) {
        if (!state.isLocalMode && state.isRunning) {
          _sendNextCommand();
          final specialCommand = state.nextReadPidsPart;
          if (specialCommand.isNotEmpty && specialCommands.isEmpty) {
            specialCommands.add(specialCommand);
          }
        }

        return;
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
            now.difference(lastReciveCommandTime).inMilliseconds.abs();
        lastReciveCommandTime = now;

        // Create test commands
        final testCommand = TestCommand('01 ${splitted[1]}', difference, data);
        testCommands.add(testCommand);

        if (pid != PID.unknown) {
          final dataIndex = commands.lastIndexWhere(
              (element) => element.command.split(' ').last == splitted[1]);

          commands[dataIndex].commandBack(converted);

          var tripRecord = state.tripRecord;
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
              emit(state.copyWith(
                tripRecord:
                    tripRecord.updateFuelLvl(_currentCommand.result.toDouble()),
              ));
              break;
            case PID.maf:
              if (command is MafCommand) {
                final usedFuel = command.fuelUsed;
                final instFuelConsumption = command.fuel100km(
                    tripRecord.currentSpeed.toInt(), tripRecord.engineLoad);
                final avgFuelConsumption =
                    100 * tripRecord.usedFuel / tripRecord.distance;
                final speed = commands.whereType<SpeedCommand>().first.result;
                final fuelStatus =
                    commands.whereType<FuelSystemStatusCommand>().first.status;
                emit(state.copyWith(
                  tripRecord: tripRecord
                      .updateUsedFuel(usedFuel(tripRecord.engineLoad),
                          speed.toInt(), fuelStatus)
                      .copyWith(
                        instFuelConsumption: instFuelConsumption,
                        averageFuelConsumption: avgFuelConsumption,
                      )
                      .updateRange(),
                ));
              }
              break;
            case PID.speed:
              if (command is SpeedCommand) {
                final distance = command.distanceTraveled;
                final acceleration = command.acceleration();
                if (acceleration.abs() > Constants.rapidSpeedChange) {
                  tripRecord = tripRecord.updateRapidAcceleration(
                      isPositive: acceleration > 0);
                }
                final maxAcceleration =
                    max(acceleration, state.maxAcceleration);
                emit(state.copyWith(
                  tripRecord: tripRecord.copyWith(
                    distance: tripRecord.distance + distance,
                    currentSpeed: command.result.toInt(),
                  ),
                  maxAcceleration: maxAcceleration,
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
          currentPids.addAll(pids);
          emit(state
              .updateReadedPidsPart('01' + splitted[1])
              .copyWith(supportedPids: currentPids.toSet().toList()));
        } else {
          print(
              'Unsupported pid: ${splitted[1]}, description: ${pidsDescription[splitted[1]]}');
          _insertError(
              'Unsupported pid: ${splitted[1]}, description: ${pidsDescription[splitted[1]]}');
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

  @override
  Future<void> close() async {
    _everySecondTimer?.cancel();
    positionSub?.cancel();

    super.close();
  }
}
