import 'package:smart_car/app/resources/strings.dart';
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
        return Strings.fuelSystemMotofOff;
      case FuelSystemStatus.insufficientEngineTemp:
        return Strings.fuelSystemInsufficientEngineTemp;
      case FuelSystemStatus.good:
        return Strings.fuelSystemGood;
      case FuelSystemStatus.fuelCut:
        return Strings.fuelSystemCut;
      case FuelSystemStatus.systemFailure:
        return Strings.fuelSystemFailure;
      case FuelSystemStatus.oxygenSensorFailure:
        return Strings.fuelSystemOxygenSensorFailure;
      case FuelSystemStatus.unknown:
        return Strings.fuelSystemUnknown;
    }
  }
}

class FuelSystemStatusCommand extends ObdCommand {
  FuelSystemStatusCommand() : super('0103', prio: 0);

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
