import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/utils/info_tile_data.dart';
import 'package:smart_car/utils/ui/info_tile.dart';

class FuelStatsSection extends StatelessWidget {
  const FuelStatsSection({
    Key? key,
    required this.records,
    required this.tripStatus,
  }) : super(key: key);

  final List<FuelTileData> records;
  final TripStatus tripStatus;

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
        height: 60,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: records
              .map((data) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FuelInfoTile(
                      data: data,
                      status: tripStatus,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
