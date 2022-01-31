import 'package:smart_car/utils/trending.dart';

extension DoubleListExtension<T> on List<double> {
  /// Add [value] to list, max to count of [max]
  void addWithMax(double value, int max) {
    if (length >= max) {
      removeAt(0);
    }
    add(value);
  }

  /// Calcute trending based on values in list with [range] tolerance
  Trending trending({double range = 0.0}) {
    if (length < 2) return Trending.constant;
    final mean = reduce((value, element) => value + element) / length;

    final diff = mean - first;
    if (diff.abs() <= range) return Trending.constant;
    if (diff > 0) return Trending.up;
    return Trending.down;
  }
}

extension ListExtension<T> on List<T> {
  E? safeFirst<E>() {
    final results = whereType<E>();
    if (results.isEmpty) return null;
    return results.first;
  }
}
