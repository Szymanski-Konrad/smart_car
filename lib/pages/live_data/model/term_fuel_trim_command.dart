import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

abstract class TermFuelTrim extends VisibleObdCommand {
  TermFuelTrim(String command)
      : super(
          command,
          prio: 1,
          max: 99.2,
          min: -100,
        );

  @override
  Color get color {
    if (max * 0.9 < result) return dangerColor;
    if (max * 0.8 < result) return warningColor;
    return normalColor;
  }

  @override
  String get formattedResult => '${result.toStringAsFixed(3)} $unit';

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      result = (100 * data[0] / 128) - 100;
      result /= 100;
      super.performCalculations(data);
    }
  }

  @override
  IconData get icon => Icons.shortcut;

  @override
  String get unit => '%';
}

class ShortTermFuelTrimBank1 extends TermFuelTrim {
  ShortTermFuelTrimBank1() : super('01 06');

  @override
  String get name => 'STFT - Bank 1';

  @override
  String get description => 'Short term fuel trim - bank 1';
}

class LongTermFuelTrimBank1 extends TermFuelTrim {
  LongTermFuelTrimBank1() : super('01 07');

  @override
  String get name => 'LTFT - Bank 1';

  @override
  String get description => 'Long term fuel trim - bank 1';
}

class ShortTermFuelTrimBank2 extends TermFuelTrim {
  ShortTermFuelTrimBank2() : super('01 08');

  @override
  String get name => 'STFT - Bank 2';

  @override
  String get description => 'Short term fuel trim - bank 2';
}

class LongTermFuelTrimBank2 extends TermFuelTrim {
  LongTermFuelTrimBank2() : super('01 09');

  @override
  String get name => 'LTFT - Bank 2';

  @override
  String get description => 'Long term fuel trim - bank 2';
}
