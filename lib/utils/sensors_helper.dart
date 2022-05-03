import 'dart:math';

abstract class SensorsHelper {
  const SensorsHelper._();

  static double accelerationSum(double xData, double yData, double zData) =>
      (pow(xData, 2) + pow(yData, 2) + pow(zData, 2)).toDouble();

  static double gForceCalc(double value) => 1 + sqrt(value) / 9.8;

  /// High-pass filter
  static double filterValue(double previous, double current) {
    const alpha = 0.8;

    final gravity = alpha * previous + (1 - alpha) * current;
    return current - gravity;
  }
}
