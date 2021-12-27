import 'package:smart_car/utils/trending.dart';

extension ListExtension<T> on List<double> {
  void addWithMax(double value, int max) {
    if (length >= max) {
      removeAt(0);
    }
    add(value);
  }

  Trending trending({double range = 0.0}) {
    if (length < 2) return Trending.constant;
    final mean = reduce((value, element) => value + element) / length;

    final diff = mean - first;
    if (diff.abs() <= range) return Trending.constant;
    if (diff > 0) return Trending.up;
    return Trending.down;
  }
}
