import 'package:smart_car/app/blocs/global_bloc.dart';
import 'package:smart_car/models/settings.dart';

abstract class FuelHelper {
  static double airFuelAspectRatio() => _fuelType.airFuelRatio;

  static double density() => _fuelType.density;

  static FuelType get _fuelType => GlobalBlocs.settings.state.settings.fuelType;

  static double co2EmissionInGrams(double fuel) =>
      fuel * _fuelType.carbonPercentage * 3;

  static double co2EmissionInKg(double fuel) => co2EmissionInGrams(fuel) / 1000;
}
