import 'package:flutter/cupertino.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_cubit.dart';
import 'package:smart_car/pages/live_data/bloc/live_data_state.dart';
import 'package:smart_car/pages/live_data/model/trip_record.dart';
import 'package:smart_car/utils/ui/acc_info_tile.dart';
import 'package:smart_car/utils/ui/info_tile.dart';

class OtherTripStatsSection extends StatelessWidget {
  const OtherTripStatsSection({
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
          if (state.isTemperatureAvaliable) OtherInfoTile(state.indoorTempData),
          if (state.isBarometerAvaliable) OtherInfoTile(state.barometerData),
          AccDataTile(values: state.acceleration, title: 'Przyspieszenie'),
          ...state.tripRecord.countersSection.map(
              (i) => OtherInfoTile(i, updates: state.tripRecord.updateTime)),
          ...state.tripRecord.otherSection.map(
              (i) => OtherInfoTile(i, updates: state.tripRecord.updateTime)),
          OtherInfoTile(state.gForceData),
          OtherInfoTile(state.locationHeightData),
          OtherInfoTile(state.directionData),
          OtherInfoTile(state.locationSlopeData),
        ],
      ),
    );
  }
}
