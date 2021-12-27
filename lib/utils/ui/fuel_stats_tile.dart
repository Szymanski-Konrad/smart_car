import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/trip_record.dart';
import 'package:smart_car/utils/info_tile_data.dart';
import 'package:smart_car/utils/ui/info_tile.dart';

class FuelStatsTile extends StatelessWidget {
  const FuelStatsTile({
    Key? key,
    required this.records,
  }) : super(key: key);

  final List<InfoTileData> records;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.31,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: Column(
        children: records
            .map((data) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InfoTile(data: data),
                ))
            .toList(),
      ),
    );
  }
}
