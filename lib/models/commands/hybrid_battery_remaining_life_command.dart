import 'package:smart_car/pages/live_data/model/abstract_commands/percent_obd_command.dart';

class HybridBatteryPackRemainingLife extends PercentObdCommand {
  HybridBatteryPackRemainingLife() : super('01 5B', prio: 50);

  @override
  String get description => 'Hybrid battery pack remaining life';

  @override
  String get name => 'Battery life';
}
