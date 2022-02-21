extension DoubleExtension on double {
  String get showSpaced {
    if (abs() < 1000) return toString();
    double value = this;
    List<int> parts = [];
    value = value.truncateToDouble();
    while (value >= 1000) {
      parts.add(value.remainder(1000).toInt());
      value = value / 1000;
    }
    parts.add(value.truncate());
    final List<String> convertedParts =
        parts.reversed.map((e) => e.toString().padLeft(3, '0')).toList();
    return '${convertedParts.join(' ')}.${remainder(1).toString().substring(2)}';
  }
}
