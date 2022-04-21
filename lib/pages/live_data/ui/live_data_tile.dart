import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:flutter/material.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';

class LiveDataTile extends StatelessWidget {
  const LiveDataTile({
    Key? key,
    required this.command,
  }) : super(key: key);

  final VisibleObdCommand command;

  Widget chart() {
    return Sparkline(
      lineWidth: 0,
      useCubicSmoothing: true,
      fallbackHeight: Constants.tileHeight,
      data: command.lastHistoryData,
      lineColor: Colors.blueGrey,
      fillColor: command.color,
      fillMode: FillMode.below,
      max: command.max.toDouble(),
      min: command.min.toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDescription(context),
      child: SizedBox(
        height: Constants.tileHeight,
        width: MediaQuery.of(context).size.width * 0.31,
        child: Stack(
          children: [
            if (command.enableHistorical && command.historyData.isNotEmpty)
              chart(),
            commandInfo(context),
          ],
        ),
      ),
    );
  }

  final textTheme = const TextStyle(fontSize: 18);

  void showDescription(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: Text(command.name),
            content: Text(command.description),
          );
        });
  }

  Widget commandInfo(BuildContext context) {
    return Container(
      height: Constants.tileHeight,
      padding: const EdgeInsets.all(8.0),
      decoration: !command.enableHistorical
          ? BoxDecoration(
              border: Border.all(color: Colors.blueGrey, width: 1.0),
            )
          : null,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  command.name,
                  maxLines: 2,
                  style: textTheme,
                  textAlign: TextAlign.center,
                ),
                Text(command.formattedResult, style: textTheme),
                // Icon(command.icon),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
