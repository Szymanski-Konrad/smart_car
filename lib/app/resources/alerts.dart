import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/feautures/alert_center/alert.dart';

abstract class Alerts {
  const Alerts._();

  static refuelRecognized(double fuelDiff) => Alert.dismissible(
        title: 'Wykryto tankowanie, ${fuelDiff.toStringAsFixed(3)}',
        description: 'Czy chcesz je teraz wprowadzić?',
        dismissibleTitle: 'Później',
        actions: [
          AlertAction(
            title: 'Dodaj',
            onTap: () {
              GlobalBlocs.fuelLogs.createNewLog();
            },
          ),
        ],
      );
}
