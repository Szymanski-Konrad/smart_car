import 'package:flutter/material.dart';
import 'package:smart_car/app/resources/date_formats.dart';

extension DateExtension on DateTime {
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;

  DateTime get toMidnight => DateTime(year, month, day);

  String get toDateFormat => DateFormats.dateFormat.format(toMidnight);
  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  String get toTimeFormat =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
