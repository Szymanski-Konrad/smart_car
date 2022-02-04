import 'package:smart_car/pages/live_data/model/abstract_commands/obd_command.dart';

class AuxiliaryInputStatus extends ObdCommand {
  AuxiliaryInputStatus() : super('01 1E', prio: 1000);

  @override
  void performCalculations(List<int> data) {
    if (data.isEmpty) {
      result = data[0];
      super.performCalculations(data);
    }
  }

  bool get isActive => result == 1;
}
