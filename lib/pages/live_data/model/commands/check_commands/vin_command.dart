import 'package:smart_car/pages/live_data/model/abstract_commands/obd_command.dart';

class VinCommand extends ObdCommand {
  VinCommand() : super('0902', prio: 1000);

  String vin = '';

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      final _data = data.where((element) => element != 13);
      vin = _extractVin(String.fromCharCodes(_data));
    }
    super.performCalculations(data);
  }

  String _extractVin(String data) {
    final vinString = data
        .replaceFirst('014', '')
        .replaceFirst('0:', '')
        .replaceFirst('1:', '')
        .replaceFirst('2:', '')
        .replaceFirst('4902', '')
        .trim();

    final vin = <int>[];

    for (int i = 0; i <= vinString.length - 2; i += 2) {
      final ascii = int.parse(vinString.substring(i, i + 2), radix: 16);
      if (isAscii(ascii)) {
        vin.add(ascii);
      }
    }

    return vin.map(String.fromCharCode).join();
  }

  bool isAscii(int value) {
    return (value >= 48 && value <= 57) ||
        (value >= 65 && value <= 90) ||
        (value >= 97 && value <= 122);
  }
}
