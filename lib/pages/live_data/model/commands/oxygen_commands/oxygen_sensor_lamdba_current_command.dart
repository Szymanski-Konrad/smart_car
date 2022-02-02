import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';
import 'package:smart_car/pages/live_data/model/commands/oxygen_commands/oxygen_mixin.dart';

abstract class OxygenSensorLambdaCurrentCommand extends VisibleObdCommand
    implements OxygenMixin {
  OxygenSensorLambdaCurrentCommand(String command)
      : super(command, prio: 1, max: 0, min: 2);

  static const a = 2 / 65536;

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
      B = ((256 * data[2] + data[3]) / 256) - 128;
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
  String get unitB => 'mA';
}

class OxygenSensorLambdaCurrentCommand1
    extends OxygenSensorLambdaCurrentCommand {
  OxygenSensorLambdaCurrentCommand1() : super('01 34');

  @override
  String get description =>
      'Oxygen sensor 1 - Air-Fuel Equivalence Ratio (lambda) & Current';

  @override
  String get name => 'S.1 O2 lambda';
}

class OxygenSensorLambdaCurrentCommand2
    extends OxygenSensorLambdaCurrentCommand {
  OxygenSensorLambdaCurrentCommand2() : super('01 35');

  @override
  String get description =>
      'Oxygen sensor 2 - Air-Fuel Equivalence Ratio (lambda) & Current';

  @override
  String get name => 'S.2 O2 lambda';
}

class OxygenSensorLambdaCurrentCommand3
    extends OxygenSensorLambdaCurrentCommand {
  OxygenSensorLambdaCurrentCommand3() : super('01 36');

  @override
  String get description =>
      'Oxygen sensor 3 - Air-Fuel Equivalence Ratio (lambda) & Current';

  @override
  String get name => 'S.3 O2 lambda';
}

class OxygenSensorLambdaCurrentCommand4
    extends OxygenSensorLambdaCurrentCommand {
  OxygenSensorLambdaCurrentCommand4() : super('01 37');

  @override
  String get description =>
      'Oxygen sensor 4 - Air-Fuel Equivalence Ratio (lambda) & Current';

  @override
  String get name => 'S.4 O2 lambda';
}

class OxygenSensorLambdaCurrentCommand5
    extends OxygenSensorLambdaCurrentCommand {
  OxygenSensorLambdaCurrentCommand5() : super('01 38');

  @override
  String get description =>
      'Oxygen sensor 5 - Air-Fuel Equivalence Ratio (lambda) & Current';

  @override
  String get name => 'S.5 O2 lambda';
}

class OxygenSensorLambdaCurrentCommand6
    extends OxygenSensorLambdaCurrentCommand {
  OxygenSensorLambdaCurrentCommand6() : super('01 39');

  @override
  String get description =>
      'Oxygen sensor 6 - Air-Fuel Equivalence Ratio (lambda) & Current';

  @override
  String get name => 'S.6 O2 lambda';
}

class OxygenSensorLambdaCurrentCommand7
    extends OxygenSensorLambdaCurrentCommand {
  OxygenSensorLambdaCurrentCommand7() : super('01 3A');

  @override
  String get description =>
      'Oxygen sensor 7 - Air-Fuel Equivalence Ratio (lambda) & Current';

  @override
  String get name => 'S.7 O2 lambda';
}

class OxygenSensorLambdaCurrentCommand8
    extends OxygenSensorLambdaCurrentCommand {
  OxygenSensorLambdaCurrentCommand8() : super('01 3B');

  @override
  String get description =>
      'Oxygen sensor 8 - Air-Fuel Equivalence Ratio (lambda) & Current';

  @override
  String get name => 'S.8 O2 lambda';
}
