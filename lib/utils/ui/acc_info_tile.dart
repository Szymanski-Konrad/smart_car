import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:flutter/material.dart';
import 'package:smart_car/app/resources/constants.dart';

class AccDataTile extends StatelessWidget {
  const AccDataTile({
    Key? key,
    required this.values,
    required this.title,
  }) : super(key: key);

  final List<double> values;
  final String title;

  Widget chart() {
    return Sparkline(
      lineWidth: 0,
      useCubicSmoothing: true,
      fallbackHeight: Constants.tileHeight,
      data: values,
      lineColor: Colors.blueGrey,
      fillColor: Colors.green,
      fillMode: FillMode.below,
      max: 3,
      min: -3,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Constants.tileHeight,
      width: MediaQuery.of(context).size.width * 0.31,
      child: Stack(
        children: [
          chart(),
          commandInfo(context),
        ],
      ),
    );
  }

  final textTheme = const TextStyle(fontSize: 18);

  Widget commandInfo(BuildContext context) {
    return Container(
      height: Constants.tileHeight,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey, width: 1.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title),
                Text(
                  values.last.toStringAsFixed(2),
                  maxLines: 2,
                  style: textTheme,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
