import 'package:smart_car/pages/live_data/model/abstract_commands/percent_obd_command.dart';

class EGRErrorCommand extends PercentObdCommand {
  EGRErrorCommand() : super('012D', prio: 1, max: 99.2, min: -100);

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      result = (100 * data[0] / 128) - 100;
      super.performCalculations(data);
    }
  }

  @override
  String get description => 'EGR Error';

  @override
  String get name => 'EGR Error';
}
