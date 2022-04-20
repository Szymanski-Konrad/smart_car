extension DoubleListExtension<T> on List<double> {
  /// Add [value] to list, max to count of [max]
  void addWithMax(double value, int max) {
    if (length >= max) {
      removeAt(0);
    }
    add(value);
  }

  List<double> takeLast(int count) {
    if (length < count) return this;
    return sublist(length - count);
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

  List<T> dividedBy(T divider) {
    if (isEmpty) return [];
    final List<T> list = [];
    list.add(first);
    for (int i = 1; i < length; i++) {
      list.add(divider);
      list.add(elementAt(i));
    }
    return list;
  }
}
