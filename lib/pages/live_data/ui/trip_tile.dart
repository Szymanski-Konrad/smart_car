import 'package:flutter/material.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/pages/live_data/model/trip/trip_part_details.dart';

class TripTile extends StatelessWidget {
  const TripTile({Key? key, required this.details}) : super(key: key);

  final TripPartDetails details;

  final textTheme = const TextStyle(fontSize: 16);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
      ),
      height: Constants.tileHeight,
      width: MediaQuery.of(context).size.width * 0.31,
      child: Column(
        children: [
          Text(details.title, style: textTheme),
          Text(details.formattedValue, style: textTheme),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(details.icon ?? Icons.bubble_chart),
              Text(details.unit),
            ],
          )
        ],
      ),
    );
  }
}
