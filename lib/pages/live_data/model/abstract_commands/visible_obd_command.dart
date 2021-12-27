import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/obd_command.dart';
import 'package:smart_car/utils/trending.dart';

abstract class VisibleObdCommand extends ObdCommand {
  VisibleObdCommand(String command, {num? min, num? max, required int prio})
      : super(command, min: min, max: max, prio: prio);

  String get name;
  String get description;
  String get unit;
  String get formattedResult => '-.- $unit';
  String get formattedReactionTime => '$responseTime ms';
  Trending trending = Trending.constant;
  IconData get icon;
  num previousResult = double.nan;

  IconData get trendingIcon => trending.icon;

  @override
  void performCalculations(List<int> data) {
    super.performCalculations(data);
    if (result > previousResult) {
      trending = Trending.up;
    } else if (result == previousResult) {
      trending = Trending.constant;
    } else {
      trending = Trending.down;
    }
  }

  Color get trendingColor {
    switch (trending) {
      case Trending.up:
        return Colors.green;
      case Trending.constant:
        return Colors.white;
      case Trending.down:
        return Colors.red;
    }
  }
}
