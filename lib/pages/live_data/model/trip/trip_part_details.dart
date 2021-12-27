import 'package:flutter/material.dart';

class TripPartDetails<T> {
  TripPartDetails({
    required this.value,
    required this.title,
    required this.unit,
    required this.description,
    this.icon,
  });

  final T value;
  final String title;
  final String unit;
  final String description;
  final IconData? icon;

  String get formattedValue {
    final val = value;
    if (val is double) {
      return val > 0 ? val.toStringAsFixed(2) : '-.-';
    } else if (val is Duration) {
      return val.toString().substring(0, 7);
    } else if (val is String) {
      return val;
    }

    throw ArgumentError.value(val, 'Unsupported type of value');
  }
}
