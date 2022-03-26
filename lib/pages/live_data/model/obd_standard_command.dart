import 'package:smart_car/pages/live_data/model/abstract_commands/obd_command.dart';

class ObdStandardCommand extends ObdCommand {
  ObdStandardCommand() : super('011C', prio: 1000);

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      result = data[0];
      super.performCalculations(data);
    }
  }

  String get status {
    if (result == 1) return 'OBD-II as defined by the CARB';
    if (result == 2) return 'OBD as defined by the EPA';
    if (result == 3) return 'OBD and OBD-II';
    if (result == 4) return 'OBD-I';
    if (result == 5) return 'Not OBD compliant';
    if (result == 6) return 'EOBD (Europe)';
    if (result == 7) return 'EOBD and OBD-II';
    if (result == 8) return 'EOBD and OBD';
    if (result == 9) return 'EOBD, OBD and OBD II';
    if (result == 10) return 'JOBD (Japan)';
    if (result == 11) return 'JOBD and OBD II';
    if (result == 12) return 'JOBD and EOBD';
    if (result == 13) return 'JOBD, EOBD, and OBD II';
    if (result == 14) return 'Reserved';
    if (result == 15) return 'Reserved';
    if (result == 16) return 'Reserved';
    if (result == 17) return 'Engine Manufacturer Diagnostics (EMD)';
    if (result == 18) return 'Engine Manufacturer Diagnostics Enhanced (EMD+)';
    if (result == 19) {
      return 'Heavy Duty On-Board Diagnostics (Child/Partial) (HD OBD-C)';
    }
    if (result == 20) return 'Heavy Duty On-Board Diagnostics (HD OBD)';
    if (result == 21) return 'World Wide Harmonized OBD (WWH OBD)';
    if (result == 22) return 'Reserved';
    if (result == 23) {
      return 'Heavy Duty Euro OBD Stage I without NOx control (HD EOBD-I)';
    }
    if (result == 24) {
      return 'Heavy Duty Euro OBD Stage I with NOx control (HD EOBD-I N)';
    }
    if (result == 25) {
      return 'Heavy Duty Euro OBD Stage II without NOx control (HD EOBD-II)';
    }
    if (result == 26) {
      return 'Heavy Duty Euro OBD Stage II with NOx control (HD EOBD-II N)';
    }
    if (result == 28) return 'Brazil OBD Phase 1 (OBDBr-1)';
    if (result == 29) return 'Brazil OBD Phase 2 (OBDBr-2)';
    if (result == 30) return 'Korean OBD (KOBD)';
    if (result == 31) return 'India OBD I (IOBD I)';
    if (result == 32) return 'India OBD II (IOBD II)';
    if (result == 33) return 'Heavy Duty Euro OBD Stage VI (HD EOBD-IV)';
    if (result >= 251 && result <= 255) {
      return 'Not available for asignment (SAE J1939 special meaning)';
    }
    return 'Reserved';
  }
}
