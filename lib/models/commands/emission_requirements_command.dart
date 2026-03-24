import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

/// PID 0x5F - Emission requirements to which vehicle is designed
/// 1 byte enum value
class EmissionRequirementsCommand extends VisibleObdCommand {
  EmissionRequirementsCommand() : super('015F', min: 0, max: 255, prio: 1);

  static const _labels = <int, String>{
    0x01: 'OBD II (CARB)',
    0x02: 'OBD (EPA)',
    0x03: 'OBD and OBD II',
    0x04: 'OBD-I',
    0x05: 'Not OBD compliant',
    0x06: 'EOBD',
    0x07: 'EOBD and OBD II',
    0x08: 'EOBD and OBD',
    0x09: 'EOBD, OBD and OBD II',
    0x0A: 'JOBD',
    0x0B: 'JOBD and OBD II',
    0x0C: 'JOBD and EOBD',
    0x0D: 'JOBD, EOBD and OBD II',
    0x11: 'EMD',
    0x12: 'EMD+',
    0x13: 'HD OBD-C',
    0x14: 'HD OBD',
    0x15: 'WWH OBD',
    0x17: 'HD EOBD-I',
    0x18: 'HD EOBD-I N',
    0x19: 'HD EOBD-II',
    0x1A: 'HD EOBD-II N',
    0x1C: 'OBDBr-1',
    0x1D: 'OBDBr-2',
    0x1E: 'KOBD',
    0x1F: 'IOBD-I',
    0x20: 'IOBD-II',
    0x21: 'HD EOBD-VI',
  };

  int _code = 0;

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      _code = data[0];
      result = _code.toDouble();
      super.performCalculations(data);
    }
  }

  @override
  String get formattedResult => _labels[_code] ?? '0x${_code.toRadixString(16).toUpperCase()}';

  @override
  String get description => 'Emission requirements standard';

  @override
  String get name => 'Emission Std';

  @override
  String get unit => '';

  @override
  IconData get icon => Icons.eco;
}
