extension DateExtension on DateTime {
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;
}
