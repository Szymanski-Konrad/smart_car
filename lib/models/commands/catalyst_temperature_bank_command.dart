import 'package:smart_car/pages/live_data/model/abstract_commands/temp_obd_command.dart';

abstract class CatalystTemperatureBankCommand extends TempObdCommand {
  CatalystTemperatureBankCommand(String command)
      : super(command, prio: 1, min: -40, max: 6513.5);

  @override
  void performCalculations(List<int> data) {
    if (data.length >= 2) {
      result = (256 * data[0] + data[1]) / 10 - 40;
      super.performCalculations(data);
    }
  }
}

class CatalystTemperatureB1S1Command extends CatalystTemperatureBankCommand {
  CatalystTemperatureB1S1Command() : super('01 3C');

  @override
  String get description => '	Catalyst Temperature: Bank 1, Sensor 1';

  @override
  String get name => 'Catalyst B1S1';
}

class CatalystTemperatureB2S1Command extends CatalystTemperatureBankCommand {
  CatalystTemperatureB2S1Command() : super('01 3D');

  @override
  String get description => '	Catalyst Temperature: Bank 2, Sensor 1';

  @override
  String get name => 'Catalyst B2S1';
}

class CatalystTemperatureB1S2Command extends CatalystTemperatureBankCommand {
  CatalystTemperatureB1S2Command() : super('01 3E');

  @override
  String get description => '	Catalyst Temperature: Bank 1, Sensor 2';

  @override
  String get name => 'Catalyst B1S2';
}

class CatalystTemperatureB2S2Command extends CatalystTemperatureBankCommand {
  CatalystTemperatureB2S2Command() : super('01 3F');

  @override
  String get description => '	Catalyst Temperature: Bank 2, Sensor 2';

  @override
  String get name => 'Catalyst B2S2';
}
