import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class EngineReferenceTorqueCommand extends VisibleObdCommand {
  EngineReferenceTorqueCommand() : super('0163', min: 0, max: 65535, prio: 1);

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      result = 256 * data[0] + data[1];
      super.performCalculations(data);
    }
  }

  @override
  String get description => 'Engine reference torque';

  @override
  String get name => 'Torque';

  @override
  String get unit => 'Nm';
}
