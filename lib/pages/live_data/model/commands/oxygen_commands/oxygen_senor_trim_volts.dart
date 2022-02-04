import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';
import 'package:smart_car/pages/live_data/model/commands/oxygen_commands/oxygen_mixin.dart';

abstract class OxygenSensorTrimVoltsCommand extends VisibleObdCommand
    implements OxygenMixin {
  OxygenSensorTrimVoltsCommand(String command)
      : super(command, prio: 1, max: 1.275, min: 0, enableHistory: false);

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
    if (data.length >= 2) {
      A = data[0] / 200;
      B = (100 * data[1] / 128) - 100;
      result = A;
      super.performCalculations(data);
    }
  }

  @override
  IconData get icon => Icons.sensors;

  @override
  String get unit => '';

  @override
  String get unitA => 'V';

  @override
  String get unitB => '%';
}

class OxygenSensorTrimVoltsCommand1 extends OxygenSensorTrimVoltsCommand {
  OxygenSensorTrimVoltsCommand1() : super('0114');

  @override
  String get description => 'Oxygen sensor 1';

  @override
  String get name => 'O2 sensor 1';
}

class OxygenSensorTrimVoltsCommand2 extends OxygenSensorTrimVoltsCommand {
  OxygenSensorTrimVoltsCommand2() : super('0115');

  @override
  String get description => 'Oxygen sensor 2';

  @override
  String get name => 'O2 sensor 2';
}

class OxygenSensorTrimVoltsCommand3 extends OxygenSensorTrimVoltsCommand {
  OxygenSensorTrimVoltsCommand3() : super('0116');

  @override
  String get description => 'Oxygen sensor 3';

  @override
  String get name => 'O2 sensor 3';
}

class OxygenSensorTrimVoltsCommand4 extends OxygenSensorTrimVoltsCommand {
  OxygenSensorTrimVoltsCommand4() : super('0117');

  @override
  String get description => 'Oxygen sensor 4';

  @override
  String get name => 'O2 sensor 4';
}

class OxygenSensorTrimVoltsCommand5 extends OxygenSensorTrimVoltsCommand {
  OxygenSensorTrimVoltsCommand5() : super('0118');

  @override
  String get description => 'Oxygen sensor 5';

  @override
  String get name => 'O2 sensor 5';
}

class OxygenSensorTrimVoltsCommand6 extends OxygenSensorTrimVoltsCommand {
  OxygenSensorTrimVoltsCommand6() : super('0119');

  @override
  String get description => 'Oxygen sensor 6';

  @override
  String get name => 'O2 sensor 6';
}

class OxygenSensorTrimVoltsCommand7 extends OxygenSensorTrimVoltsCommand {
  OxygenSensorTrimVoltsCommand7() : super('011A');

  @override
  String get description => 'Oxygen sensor 7';

  @override
  String get name => 'O2 sensor 7';
}

class OxygenSensorTrimVoltsCommand8 extends OxygenSensorTrimVoltsCommand {
  OxygenSensorTrimVoltsCommand8() : super('011B');

  @override
  String get description => 'Oxygen sensor 8';

  @override
  String get name => 'O2 sensor 8';
}
