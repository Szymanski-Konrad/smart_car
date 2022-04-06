import 'package:flutter/material.dart';
import 'package:smart_car/app/resources/constants.dart';

@immutable
abstract class Functions {
  const Functions._();

  static double fuelToCarboGrams(double fuel) =>
      fuel * Constants.co2GramsPerFuelLiter;

  static double fuelToCarboKg(double fuel) => fuelToCarboGrams(fuel) / 1000;
}
