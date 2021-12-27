class InfoTileData<T> {
  InfoTileData({
    required this.value,
    required this.digits,
    required this.title,
    required this.unit,
  });

  final T value;
  final int digits;
  final String title;
  final String unit;

  String get formattedValue {
    final val = value;
    if (val is double) {
      return val > 0 ? val.toStringAsFixed(digits) : '-.-';
    } else if (val is Duration) {
      return val.toString().substring(0, 7);
    } else if (val is String) {
      return val;
    } else if (val is int) {
      return val.toString();
    }

    throw ArgumentError.value(val, 'Unsupported type of value');
  }
}
