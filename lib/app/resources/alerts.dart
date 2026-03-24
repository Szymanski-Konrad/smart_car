import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/feautures/alert_center/alert.dart';

abstract class Alerts {
  const Alerts._();

  static Alert refuelRecognized(double fuelDiff) => Alert.dismissible(
    title: 'Wykryto tankowanie, różnica ${fuelDiff.toStringAsFixed(3)} %',
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

  static Alert lowVoltage(double voltage) => Alert.dismissible(
    title: 'Niskie napięcie akumulatora: ${voltage.toStringAsFixed(1)} V',
    description:
        'Napięcie poniżej ${voltage.toStringAsFixed(1)} V może świadczyć o '
        'awarii alternatora lub rozładowanym akumulatorze.',
  );

  static Alert coolantOverheat(double temp) => Alert.dismissible(
    title: 'Przegrzanie silnika: ${temp.toStringAsFixed(0)} °C',
    description:
        'Temperatura cieczy chłodzącej jest zbyt wysoka. '
        'Zatrzymaj pojazd i wyłącz silnik.',
  );

  static Alert highRpmTooLong(int seconds) => Alert.dismissible(
    title: 'Długa jazda na wysokich obrotach',
    description:
        'Silnik pracuje na obrotach powyżej limitu przez ponad '
        '${seconds ~/ 60} min ${seconds % 60} s. '
        'Zmień bieg lub zwolnij.',
  );
}
