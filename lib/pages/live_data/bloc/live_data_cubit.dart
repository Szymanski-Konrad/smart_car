import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:environment_sensors/environment_sensors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/app/resources/pids.dart';
import 'package:smart_car/app/resources/strings.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/obd_command.dart';
import 'package:smart_car/pages/live_data/model/commands/check_commands/check_pids_command.dart';
import 'package:smart_car/pages/live_data/model/commaned_air_fuel_ratio_command.dart';
import 'package:smart_car/pages/live_data/model/fuel_level_command.dart';
import 'package:smart_car/pages/live_data/model/fuel_system_status_command.dart';
import 'package:smart_car/pages/live_data/model/maf_command.dart';
import 'package:smart_car/pages/live_data/model/speed_command.dart';
import 'package:smart_car/pages/live_data/model/term_fuel_trim_command.dart';
import 'package:smart_car/pages/live_data/model/test_data/test_command.dart';
import 'package:smart_car/pages/live_data/model/throttle_position_command.dart';
import 'package:smart_car/pages/live_data/model/trip_record.dart';
import 'package:sendgrid_mailer/sendgrid_mailer.dart';
import 'package:smart_car/utils/list_extension.dart';

class LiveDataCubit extends Cubit<LiveDataState> {
  LiveDataCubit({required this.device}) : super(LiveDataState.init()) {
    init();
  }

  // Commands to create test data to work without OBD
  List<TestCommand> testCommands = [];

  // list of commands to send
  List<ObdCommand> commands = [];
  Queue<String> specialCommands = Queue();
  Queue<String> pidsQueue = Queue<String>();

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

  /// Save trip file
  Future<void> saveCommandsToFile() async {
    if (testCommands.isNotEmpty) {
      final feedback = jsonEncode(testCommands.map((e) => e.toJson()).toList());
      Directory appDocDir = await getApplicationDocumentsDirectory();
      final now = DateTime.now();
      final path = '${appDocDir.path}/trip${now.toString()}.json';
      File file = File(path);
      file.writeAsString(feedback);
    }
  }

  /// Show files in app documents directory
  Future<List<String>> showFilesInDirectory() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final files = appDocDir.listSync();
    final paths = files.map((e) => e.path).toList();
    return paths.where((element) => element.contains('trip')).toList();
  }

  Future<void> sendTripsToMail(List<String> files) async {
    final mailOptions = MailOptions(
      body: 'Sending my last trips',
      recipients: ['hunteelar.programowanie@gmail.com'],
      isHTML: true,
      attachments: files,
    );

    await FlutterMailer.send(mailOptions);
    for (final path in files) {
      final file = File(path);
      file.delete();
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
      final speed = commands.safeFirst<SpeedCommand>()?.result;
      emit(state.copyWith(
          tripRecord:
              state.tripRecord.updateSeconds(speed ?? 0, state.isLocalMode)));
    });

    await _determinePosition();
    lastReciveCommandTime = DateTime.now();
    _decideNextMove();
    // await _sendNextCommand();
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
    final json = await rootBundle.loadString('assets/json/legionowo_trip.json');
    final decoded = List<Map<String, dynamic>>.from(jsonDecode(json));
    final testCommands = decoded.map(TestCommand.fromJson).toList();
    emit(state.localMode());

    _everySecondTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        final speed = commands.safeFirst<SpeedCommand>()?.result;
        emit(state.copyWith(
            tripRecord:
                state.tripRecord.updateSeconds(speed ?? 0, state.isLocalMode)));
      },
    );

    int index = 0;
    for (final testCommand in testCommands) {
      await Future.delayed(Duration(
          milliseconds: testCommand.responseTime ~/ Constants.liveModeSpeedUp));
      _onDataReceived(testCommand.data);
      index++;
      if (index % 1000 == 0) {
        final percentage = (index / testCommands.length) * 100;
        emit(state.copyWith(localTripProgress: percentage));
      }
    }

    _everySecondTimer?.cancel();
    _runTest();
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

  void init() async {
    // userAccelerometerEvents.listen((UserAccelerometerEvent event) {
    //   emit(state.copyWith(
    //       userAccelerometer: '\n${event.x}\n${event.y}\n${event.z}'));
    // });

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
        print('connected, now initializing obd');
        initializeObd();
      }).catchError((error) {
        print('Cannot connect, exception occured');
        print(error);
      });
    }

    final environmentSensors = EnvironmentSensors();

    final isTemperatureAvailable = await environmentSensors
        .getSensorAvailable(SensorType.AmbientTemperature);
    emit(state.copyWith(isTemperatureAvaliable: isTemperatureAvailable));
    if (isTemperatureAvailable) {
      environmentSensors.temperature.listen((event) {
        print(event);
        emit(state.copyWith(temperature: event));
      });
    }

    positionSub = Geolocator.getPositionStream(
      intervalDuration: const Duration(milliseconds: 500),
    ).listen(onGpsPositionChange);
  }

  void sendVinCommand() {
    specialCommands.add('0902');
  }

  void sendCheck9Command() {
    specialCommands.add('0900');
  }

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
        if (commands.isNotEmpty) {
          _commandIndex++;
          _commandIndex %= commands.length;
          _command = commands[_commandIndex].sendCommand();
        }
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
      saveCommandsToFile();
      // final feedback = jsonEncode(testCommands.map((e) => e.toJson()).toList());
      // testCommands.clear();
      // await _sendFeedback(feedback: feedback);
    } catch (e) {
      _insertError(e.toString());
    }
  }

  Future<bool> _sendFeedback({required String feedback}) async {
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

  DateTime lastReciveCommandTime = DateTime.now();

  void _decideNextMove() {
    final specialCommand = state.nextReadPidsPart;
    if (specialCommand.isNotEmpty && specialCommands.isEmpty) {
      specialCommands.add(specialCommand);
    }
    _sendNextCommand();
  }

  void _onDataReceived(Uint8List data) {
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
        if (!state.isLocalMode) {
          final testCommand =
              TestCommand('01 ${splitted[1]}', difference, data);
          testCommands.add(testCommand);
        }

        if (pid != PID.unknown && commands.isNotEmpty) {
          final dataIndex = commands.lastIndexWhere(
              (element) => element.command.split(' ').last == splitted[1]);
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
                      .updateUsedFuel(usedFuel(tripRecord.engineLoad),
                          speed ?? 0, fuelStatus ?? FuelSystemStatus.motorOff)
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
            case PID.throttlePosition:
              if (command is ThrottlePositionCommand) {
                final position = command.result.toDouble();
                emit(state.copyWith(
                    throttlePressed:
                        position > Constants.throttlePositionIdle));
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

  @override
  Future<void> close() async {
    await saveCommands();
    _connection?.finish();
    _everySecondTimer?.cancel();
    positionSub?.cancel();

    super.close();
  }
}
