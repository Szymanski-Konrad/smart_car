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
            if (command.enableHistorical) chart(),
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
            title: Text(command.namePL ?? command.name),
            content: Text(command.descriptionPL ?? 'Brak informacji'),
          );
        });
  }

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
                Text(
                  command.name,
                  maxLines: 1,
                  style: textTheme,
                ),
                Text(command.formattedResult, style: textTheme),
                Row(
                  children: [
                    Icon(command.icon),
                    const SizedBox(width: 8),
                    Text(command.formattedReactionTime, style: textTheme),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
