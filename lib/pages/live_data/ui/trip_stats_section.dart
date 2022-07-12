import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_cubit.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/model/trip_record.dart';
import 'package:smart_car/utils/ui/info_tile.dart';

class TripStatsSection extends StatelessWidget {
  const TripStatsSection({
    Key? key,
    required this.state,
    required this.cubit,
  }) : super(key: key);

  final LiveDataState state;
  final LiveDataCubit cubit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        runSpacing: 16.0,
        spacing: 10.0,
        children: [
          OtherInfoTile(
            state.ecoScoreData,
            previousValue: state.previousEcoScore,
          ),
          OtherInfoTile(
            state.smoothScoreData,
            previousValue: state.previousSmoothScore,
          ),
          ...state.tripRecord.timeSection.map(
            (data) => TimeInfoTile(
              data: data,
              currentInterval: state.tripRecord.currentDriveInterval,
            ),
          ),
          ...state.tripRecord.fuelUsedSection.map(
            (data) => FuelInfoTile(
              data: data,
              status: state.tripRecord.tripStatus,
            ),
          ),
          ...state.tripRecord.otherInfoSection.map((i) => OtherInfoTile(i)),
        ],
      ),
    );
  }
}
