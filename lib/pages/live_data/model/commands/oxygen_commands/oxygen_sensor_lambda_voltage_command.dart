import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';
import 'package:smart_car/pages/live_data/model/commands/oxygen_commands/oxygen_mixin.dart';

abstract class OxygenSensorLambdaVoltsCommand extends VisibleObdCommand
    implements OxygenMixin {
  OxygenSensorLambdaVoltsCommand(String command)
      : super(command, prio: 1, max: 0, min: 2);

  static const a = 2 / 65536;
  static const b = 8 / 65536;

  @override
  double A = 0.0;

  @override
  double B = 0.0;

  @override
  String get formattedResult => '${A.toStringAsFixed(3)} $unitA';

  @override
  Color get color {
    if (max * 0.9 < result) return dangerColor;
    if (max * 0.8 < result) return warningColor;
    return normalColor;
  }

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 4) {
      A = a * (256 * data[0] + data[1]);
      B = b * (256 * data[2] + data[3]);
      result = A;
      super.performCalculations(data);
    }
  }

  @override
  IconData get icon => Icons.sensors;

  @override
  String get unit => '';

  @override
  String get unitA => '';

  @override
  String get unitB => 'V';
}

class OxygenSensorLambdaVoltsCommand1 extends OxygenSensorLambdaVoltsCommand {
  OxygenSensorLambdaVoltsCommand1() : super('0124');

  @override
  String get description =>
      'Oxygen sensor 1 - Air-Fuel Equivalence Ratio (lambda) & Voltage';

  @override
  String get name => 'S.1 O2 lambda';
}

class OxygenSensorLambdaVoltsCommand2 extends OxygenSensorLambdaVoltsCommand {
  OxygenSensorLambdaVoltsCommand2() : super('0125');

  @override
  String get description =>
      'Oxygen sensor 2 - Air-Fuel Equivalence Ratio (lambda) & Voltage';

  @override
  String get name => 'S.2 O2 lambda';
}

class OxygenSensorLambdaVoltsCommand3 extends OxygenSensorLambdaVoltsCommand {
  OxygenSensorLambdaVoltsCommand3() : super('0126');

  @override
  String get description =>
      'Oxygen sensor 3 - Air-Fuel Equivalence Ratio (lambda) & Voltage';

  @override
  String get name => 'S.3 O2 lambda';
}

class OxygenSensorLambdaVoltsCommand4 extends OxygenSensorLambdaVoltsCommand {
  OxygenSensorLambdaVoltsCommand4() : super('0127');

  @override
  String get description =>
      'Oxygen sensor 4 - Air-Fuel Equivalence Ratio (lambda) & Voltage';

  @override
  String get name => 'S.4 O2 lambda';
}

class OxygenSensorLambdaVoltsCommand5 extends OxygenSensorLambdaVoltsCommand {
  OxygenSensorLambdaVoltsCommand5() : super('0128');

  @override
  String get description =>
      'Oxygen sensor 5 - Air-Fuel Equivalence Ratio (lambda) & Voltage';

  @override
  String get name => 'S.5 O2 lambda';
}

class OxygenSensorLambdaVoltsCommand6 extends OxygenSensorLambdaVoltsCommand {
  OxygenSensorLambdaVoltsCommand6() : super('0129');

  @override
  String get description =>
      'Oxygen sensor 6 - Air-Fuel Equivalence Ratio (lambda) & Voltage';

  @override
  String get name => 'S.6 O2 lambda';
}

class OxygenSensorLambdaVoltsCommand7 extends OxygenSensorLambdaVoltsCommand {
  OxygenSensorLambdaVoltsCommand7() : super('012A');

  @override
  String get description =>
      'Oxygen sensor 7 - Air-Fuel Equivalence Ratio (lambda) & Voltage';

  @override
  String get name => 'S.7 O2 lambda';
}

class OxygenSensorLambdaVoltsCommand8 extends OxygenSensorLambdaVoltsCommand {
  OxygenSensorLambdaVoltsCommand8() : super('012B');

  @override
  String get description =>
      'Oxygen sensor 8 - Air-Fuel Equivalence Ratio (lambda) & Voltage';

  @override
  String get name => 'S.8 O2 lambda';
}
