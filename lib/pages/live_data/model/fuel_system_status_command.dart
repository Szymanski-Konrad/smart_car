import 'package:smart_car/pages/live_data/model/abstract_commands/obd_command.dart';

enum FuelSystemStatus {
  motorOff,
  insufficientEngineTemp,
  good,
  fuelCut,
  systemFailure,
  oxygenSensorFailure,
  unknown,
}

extension FuelSystemStatusExtension on FuelSystemStatus {
  String get description {
    switch (this) {
      case FuelSystemStatus.motorOff:
        return 'Vehicle motor is off';
      case FuelSystemStatus.insufficientEngineTemp:
        return 'Engine temperature is low, drive carefully';
      case FuelSystemStatus.good:
        return 'Engine is in good temperature. Do your best ;)';
      case FuelSystemStatus.fuelCut:
        return 'Car not use fuel. You are saving world (and money) ;)';
      case FuelSystemStatus.systemFailure:
        return 'Something wrong with car. Slow down and visit mechanic';
      case FuelSystemStatus.oxygenSensorFailure:
        return 'Oxygen sensor failure. Please contact with mechanic';
      case FuelSystemStatus.unknown:
        return 'Unknown fuel system status';
    }
  }
}

class FuelSystemStatusCommand extends ObdCommand {
  FuelSystemStatusCommand() : super('01 03', prio: 0);

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      result = data[0];
      super.performCalculations(data);
    }
  }

  FuelSystemStatus get status {
    switch (result) {
      case 0:
        return FuelSystemStatus.motorOff;
      case 1:
        return FuelSystemStatus.insufficientEngineTemp;
      case 2:
        return FuelSystemStatus.good;
      case 4:
        return FuelSystemStatus.fuelCut;
      case 8:
        return FuelSystemStatus.systemFailure;
      case 16:
        return FuelSystemStatus.oxygenSensorFailure;
      default:
        return FuelSystemStatus.unknown;
    }
  }
}
