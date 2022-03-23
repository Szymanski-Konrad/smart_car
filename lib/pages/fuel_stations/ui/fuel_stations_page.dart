import 'package:flutter/material.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/pages/fuel_stations/bloc/fuel_stations_cubit.dart';
import 'package:smart_car/pages/fuel_stations/bloc/fuel_stations_state.dart';
import 'package:smart_car/pages/fuel_stations/ui/fuel_stations_map.dart';
import 'package:smart_car/utils/scoped_bloc_builder.dart';

class FuelStationsPage extends StatelessWidget {
  const FuelStationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedBlocBuilder<FuelStationsCubit, FuelStationsState>(
      create: (_) => FuelStationsCubit(),
      builder: (context, state, cubit) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Stacje paliw'),
            centerTitle: true,
          ),
          body: _buildBody(context, cubit, state),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.search),
            onPressed: cubit.onSearch,
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    FuelStationsCubit cubit,
    FuelStationsState state,
  ) {
    return Stack(
      children: [
        Positioned.fill(
          child: FuelStationsMap(
            gasStations: state.gasStations,
            fuelType: state.fuelType,
            onLocationChanged: cubit.onLocationChanged,
          ),
        ),
        Positioned(
          right: 16,
          top: 16,
          child: SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...FuelStationType.values
                    .map((type) => _buildStationType(type, cubit, state))
                    .toList(),
              ],
            ),
          ),
        ),
        if (state.isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Widget _buildStationType(
    FuelStationType type,
    FuelStationsCubit cubit,
    FuelStationsState state,
  ) {
    return GestureDetector(
      onTap: () => cubit.switchFuelType(type),
      child: Container(
        color: state.fuelType == type ? Colors.green : Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            type.description,
          ),
        ),
      ),
    );
  }
}
