import 'package:flutter/cupertino.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';

abstract class InfoTileData<T> {
  InfoTileData({
    required this.value,
    required this.digits,
    required this.title,
    required this.unit,
    this.iconData,
  });

  final T value;
  final int digits;
  final String title;
  final String unit;
  IconData? iconData;

  String get formattedValue {
    final val = value;
    if (val is double) {
      return val.toStringAsFixed(digits);
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

class FuelTileData<T> extends InfoTileData<T> {
  FuelTileData({
    required T value,
    required int digits,
    required String title,
    required String unit,
    required this.tripStatus,
  }) : super(
          value: value,
          digits: digits,
          title: title,
          unit: unit,
        );

  final TripStatus tripStatus;
}

class TimeTileData<T> extends InfoTileData<T> {
  TimeTileData({
    required T value,
    required int digits,
    required String title,
    required String unit,
    required this.isCurrent,
  }) : super(
          value: value,
          digits: digits,
          title: title,
          unit: unit,
        );

  final bool isCurrent;
}

class OtherTileData<T> extends InfoTileData<T> {
  OtherTileData({
    required T value,
    required int digits,
    required String title,
    required String unit,
    IconData? iconData,
  }) : super(
          value: value,
          digits: digits,
          title: title,
          unit: unit,
          iconData: iconData,
        );
}
