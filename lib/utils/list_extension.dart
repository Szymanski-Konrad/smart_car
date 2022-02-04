extension DoubleListExtension<T> on List<double> {
  /// Add [value] to list, max to count of [max]
  void addWithMax(double value, int max) {
    if (length >= max) {
      removeAt(0);
    }
    add(value);
  }
}

extension ListExtension<T> on List<T> {
  E? safeFirst<E>() {
    final results = whereType<E>();
    if (results.isEmpty) return null;
    return results.first;
  }

  T? safeFirstWhere(bool Function(T element) test) {
    for (T element in this) {
      if (test(element)) return element;
    }

    return null;
  }
}
