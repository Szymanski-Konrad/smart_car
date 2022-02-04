import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

abstract class PercentObdCommand extends VisibleObdCommand {
  PercentObdCommand(String command,
      {required int prio,
      double min = 0,
      double max = 100,
      bool enableHistory = true})
      : super(command,
            min: min, max: max, prio: prio, enableHistory: enableHistory);

  @override
  String get formattedResult =>
      result.isFinite ? '${result.toInt()} %' : super.formattedResult;

  @override
  String get unit => '%';

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      result = (100 * data[0]) / 255;
      super.performCalculations(data);
    }
  }
}
