import 'package:smart_car/pages/live_data/model/abstract_commands/obd_command.dart';

enum SecondaryAirStatus {
  unknown,
  upstream,
  downstream,
  outside,
  pump,
}

extension SecondaryAirStatusExtension on SecondaryAirStatus {
  String get description {
    switch (this) {
      case SecondaryAirStatus.unknown:
        return 'Unknown';
      case SecondaryAirStatus.upstream:
        return 'Upstream';
      case SecondaryAirStatus.downstream:
        return 'Downstream of catalytic converter';
      case SecondaryAirStatus.outside:
        return 'From the outside atmosphere or off';
      case SecondaryAirStatus.pump:
        return 'Pump commanded on for diagnostics';
    }
  }
}

class CommandedSecondaryAirStatusCommand extends ObdCommand {
  CommandedSecondaryAirStatusCommand() : super('0112', prio: 1000);

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      result = data[0];
      super.performCalculations(data);
    }
  }

  SecondaryAirStatus get airStatus {
    switch (result) {
      case 1:
        return SecondaryAirStatus.upstream;
      case 2:
        return SecondaryAirStatus.downstream;
      case 4:
        return SecondaryAirStatus.outside;
      case 8:
        return SecondaryAirStatus.pump;
      default:
        return SecondaryAirStatus.unknown;
    }
  }
}
