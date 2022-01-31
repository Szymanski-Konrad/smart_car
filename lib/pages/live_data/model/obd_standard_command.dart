import 'package:smart_car/pages/live_data/model/abstract_commands/obd_command.dart';

class ObdStandardCommand extends ObdCommand {
  ObdStandardCommand() : super('01 1C', prio: 1000);

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      result = data[0];
      super.performCalculations(data);
    }
  }

  String get status {
    switch (result) {
      case 1:
        return 'OBD-II as defined by the CARB';

      ///TODO: Implement rest of cases https://en.wikipedia.org/wiki/OBD-II_PIDs#Service_01_PID_1C
      case 251:
      case 252:
      case 253:
      case 254:
      case 255:
        return 'Not available for asignment (SAE J1939 special meaning)';
      default:
        return 'Reserved';
    }
  }
}
