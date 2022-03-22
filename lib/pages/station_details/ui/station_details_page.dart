import 'package:flutter/material.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/pages/station_details/bloc/station_details_cubit.dart';
import 'package:smart_car/pages/station_details/bloc/station_details_state.dart';
import 'package:smart_car/utils/route_argument.dart';
import 'package:smart_car/utils/scoped_bloc_builder.dart';

class StationDetailsPageArguments {
  StationDetailsPageArguments({required this.station});

  final GasStation station;
}

class StationDetailsPage extends StatelessWidget
    with RouteArgument<StationDetailsPageArguments> {
  const StationDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Szczegóły stacji')),
      body: ScopedBlocBuilder<StationDetailsCubit, StationDetailsState>(
        create: (_) => StationDetailsCubit(getArgument(context).station),
        builder: (context, state, cubit) => SingleChildScrollView(
          child: Column(
            children: [],
          ),
        ),
      ),
    );
  }
}
