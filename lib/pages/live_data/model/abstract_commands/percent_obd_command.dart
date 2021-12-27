import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

abstract class PercentObdCommand extends VisibleObdCommand {
  PercentObdCommand(String command, {required int prio})
      : super(command, min: 0, max: 100, prio: prio);

  @override
  String get formattedResult =>
      result.isFinite ? '${result.toInt()} %' : super.formattedResult;

  @override
  String get unit => '%';

  @override
  void performCalculations(List<int> data) {
    previousResult = result;
    result = (100 * data[0]) / 255;
    super.performCalculations(data);
  }
}
