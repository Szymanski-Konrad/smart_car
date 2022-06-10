import 'package:flutter/cupertino.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/model/trip_record.dart';

abstract class InfoTileData<T> {
  InfoTileData({
    required this.value,
    required this.digits,
    required this.title,
    required this.unit,
    this.iconData,
    this.fontColor,
    this.tripDataType,
  });

  final T value;
  final int digits;
  final String title;
  final String unit;
  IconData? iconData;
  Color? fontColor;
  List<TripDataType>? tripDataType;

  String get formattedValue {
    final val = value;
    if (val is double) {
      if (val < 0) return '-.-';
      return val.toStringAsFixed(digits);
    } else if (val is Duration) {
      return val.toString().substring(0, 7);
    } else if (val is String) {
      return val;
    } else if (val is int) {
      if (val < 0) return '-.-';
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
    Color? color,
  }) : super(
          value: value,
          digits: digits,
          title: title,
          unit: unit,
          fontColor: color,
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
    Color? color,
  }) : super(
          value: value,
          digits: digits,
          title: title,
          unit: unit,
          fontColor: color,
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
    Color? color,
    List<TripDataType>? tripDataType,
  }) : super(
          value: value,
          digits: digits,
          title: title,
          unit: unit,
          iconData: iconData,
          fontColor: color,
          tripDataType: tripDataType,
        );
}
