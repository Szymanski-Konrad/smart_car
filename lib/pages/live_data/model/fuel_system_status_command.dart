import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/app/resources/strings.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
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
  String get fullDescription {
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

  String get description {
    switch (this) {
      case FuelSystemStatus.motorOff:
        return Strings.fuelSystemMotofOffShort;
      case FuelSystemStatus.insufficientEngineTemp:
        return Strings.fuelSystemInsufficientEngineTempShort;
      case FuelSystemStatus.good:
        return Strings.fuelSystemGoodShort;
      case FuelSystemStatus.fuelCut:
        return Strings.fuelSystemCutShort;
      case FuelSystemStatus.systemFailure:
        return Strings.fuelSystemFailureShort;
      case FuelSystemStatus.oxygenSensorFailure:
        return Strings.fuelSystemOxygenSensorFailureShort;
      case FuelSystemStatus.unknown:
        return Strings.fuelSystemUnknownShort;
    }
  }

  IconData get icon {
    switch (this) {
      case FuelSystemStatus.motorOff:
        return LineIcons.powerOff;
      case FuelSystemStatus.insufficientEngineTemp:
        return LineIcons.thermometerEmpty;
      case FuelSystemStatus.good:
        return LineIcons.thermometerFull;
      case FuelSystemStatus.fuelCut:
        return LineIcons.handHoldingUsDollar;
      case FuelSystemStatus.systemFailure:
      case FuelSystemStatus.oxygenSensorFailure:
        return LineIcons.carCrash;
      case FuelSystemStatus.unknown:
        return LineIcons.question;
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

  TripStatus tripStatus(num speed) {
    return speed < Constants.idleSpeedLimit
        ? TripStatus.idle
        : status == FuelSystemStatus.fuelCut
            ? TripStatus.savingFuel
            : TripStatus.driving;
  }
}
