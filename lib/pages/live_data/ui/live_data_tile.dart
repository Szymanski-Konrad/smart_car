import 'dart:math';

import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:flutter/material.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';
import 'package:smart_car/pages/live_data/model/commands/oxygen_commands/oxygen_senor_volts.dart';
import 'package:smart_car/pages/live_data/model/commaned_air_fuel_ratio_command.dart';

class LiveDataTile extends StatelessWidget {
  const LiveDataTile({
    Key? key,
    required this.command,
  }) : super(key: key);

  final VisibleObdCommand command;

  Widget chart() {
    final maximum = max(command.max?.toDouble() ?? command.maxValue.toDouble(),
        command.maxValue.toDouble());
    return Sparkline(
      fallbackHeight: Constants.tileHeight,
      data: command.lastHistoryData,
      lineColor: Colors.blueGrey,
      fillColor: Colors.blueGrey.shade800,
      fillMode: FillMode.below,
      max: maximum,
      min: command.min?.toDouble() ?? command.minValue.toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Constants.tileHeight,
      width: MediaQuery.of(context).size.width * 0.31,
      child: Stack(
        children: [
          if (command.enableHistorical) chart(),
          commandInfo(context),
        ],
      ),
    );
  }

  final textTheme = const TextStyle(fontSize: 16);

  Widget commandInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: command.trendingColor),
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(command.name, style: textTheme),
                Row(
                  children: [
                    Icon(command.icon),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(command.formattedResult, style: textTheme),
                    ),
                  ],
                ),
                Text(command.formattedReactionTime, style: textTheme),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
