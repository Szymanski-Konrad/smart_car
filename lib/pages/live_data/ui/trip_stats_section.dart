import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_cubit.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/model/trip_record.dart';
import 'package:smart_car/utils/ui/acc_info_tile.dart';
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
        runSpacing: 8.0,
        spacing: 8.0,
        children: [
          if (state.isTemperatureAvaliable) OtherInfoTile(state.indoorTempData),
          // AccDataTile(values: state.xAccData, title: 'xAcc'),
          // AccDataTile(values: state.yAccData, title: 'yAcc'),
          // AccDataTile(values: state.zAccData, title: 'zAcc'),
          // AccDataTile(values: state.xGyroData, title: 'xGyro'),
          // AccDataTile(values: state.yGyroData, title: 'yGyro'),
          // AccDataTile(values: state.zGyroData, title: 'zGyro'),
          AccDataTile(values: state.acceleration, title: 'Przysp.'),
          OtherInfoTile(state.scoreData),
          OtherInfoTile(state.gForceData),
          OtherInfoTile(state.locationHeightData),
          OtherInfoTile(state.directionData),
          OtherInfoTile(state.locationSlopeData),
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
          ...state.tripRecord.countersSection.map((i) => OtherInfoTile(i)),
          ...state.tripRecord.fuelSection.map((i) => OtherInfoTile(i)),
          ...state.tripRecord.otherInfoSection.map((i) => OtherInfoTile(i)),
        ],
      ),
    );
  }
}
