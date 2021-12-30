import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';
import 'package:smart_car/pages/live_data/model/commands/oxygen_commands/oxygen_mixin.dart';

abstract class OxygenSensorVolts extends VisibleObdCommand
    implements OxygenMixin {
  OxygenSensorVolts(String command)
      : super(command, prio: 1, max: 1.275, min: 0);

  @override
  double A = 0.0;

  @override
  double B = 0.0;

  @override
  String get formattedResult =>
      '${A.toStringAsFixed(3)} $unitA\n ${B.toStringAsFixed(3)} $unitB';

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
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
  String get unitA => 'volts';

  @override
  String get unitB => '%';
}

class OxygenSensorVolts1 extends OxygenSensorVolts {
  OxygenSensorVolts1() : super('01 14');

  @override
  String get description => 'Oxygen sensor 1';

  @override
  String get name => 'Oxygen sensor 1';
}

class OxygenSensorVolts2 extends OxygenSensorVolts {
  OxygenSensorVolts2() : super('01 15');

  @override
  String get description => 'Oxygen sensor 2';

  @override
  String get name => 'Oxygen sensor 2';
}

class OxygenSensorVolts3 extends OxygenSensorVolts {
  OxygenSensorVolts3() : super('01 16');

  @override
  String get description => 'Oxygen sensor 3';

  @override
  String get name => 'Oxygen sensor 3';
}

class OxygenSensorVolts4 extends OxygenSensorVolts {
  OxygenSensorVolts4() : super('01 17');

  @override
  String get description => 'Oxygen sensor 4';

  @override
  String get name => 'Oxygen sensor 4';
}

class OxygenSensorVolts5 extends OxygenSensorVolts {
  OxygenSensorVolts5() : super('01 18');

  @override
  String get description => 'Oxygen sensor 5';

  @override
  String get name => 'Oxygen sensor 5';
}

class OxygenSensorVolts6 extends OxygenSensorVolts {
  OxygenSensorVolts6() : super('01 19');

  @override
  String get description => 'Oxygen sensor 6';

  @override
  String get name => 'Oxygen sensor 6';
}

class OxygenSensorVolts7 extends OxygenSensorVolts {
  OxygenSensorVolts7() : super('01 1A');

  @override
  String get description => 'Oxygen sensor 7';

  @override
  String get name => 'Oxygen sensor 7';
}

class OxygenSensorVolts8 extends OxygenSensorVolts {
  OxygenSensorVolts8() : super('01 1B');

  @override
  String get description => 'Oxygen sensor 8';

  @override
  String get name => 'Oxygen sensor 8';
}
