import 'package:smart_car/pages/live_data/model/abstract_commands/obd_command.dart';

class VinCommand extends ObdCommand {
  VinCommand() : super('0902', prio: 10);

  List<String> parts = [];

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      parts.add(String.fromCharCodes(data));
    }
    super.performCalculations(data);
  }
}
