import 'package:flutter/material.dart';
import 'package:smart_car/utils/info_tile_data.dart';
import 'package:smart_car/utils/ui/info_tile.dart';

class TimeStatsSection extends StatelessWidget {
  const TimeStatsSection({
    Key? key,
    required this.records,
    required this.currentInterval,
  }) : super(key: key);

  final List<TimeTileData> records;
  final int currentInterval;

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: MediaQuery.of(context).size.width * 0.31,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey,
          width: 3,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 80,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: records
              .map((data) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TimeInfoTile(
                      data: data,
                      currentInterval: currentInterval,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
