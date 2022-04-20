import 'package:flutter/material.dart';
import 'package:smart_car/models/trip_summary/trip_summary.dart';
import 'package:smart_car/pages/trip_summary/bloc/trip_summary_cubit.dart';
import 'package:smart_car/pages/trip_summary/bloc/trip_summary_state.dart';
import 'package:smart_car/utils/scoped_bloc_builder.dart';

class TripSummaryPage extends StatelessWidget {
  const TripSummaryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedBlocBuilder<TripSummaryCubit, TripSummaryState>(
      create: (_) => TripSummaryCubit(),
      builder: (context, state, cubit) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Zapisane przejazdy'),
          ),
          body: _buildContent(context, state, cubit),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    TripSummaryState state,
    TripSummaryCubit cubit,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TripSummaryCard(trips: state.trips),
          const SizedBox(height: 32.0),
          ...state.trips.reversed.map((trip) => TripCard(trip: trip)),
        ],
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  const TripCard({
    Key? key,
    required this.trip,
  }) : super(key: key);

  final TripSummary trip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Przejazd:'),
                        const SizedBox(height: 16.0),
                        _buildIconText(trip.distanceFormat, Icons.route),
                        _buildIconText(
                            trip.fuelLevelFormat, Icons.difference_rounded),
                        _buildIconText(trip.avgFuelConsumptionFormat,
                            Icons.local_gas_station),
                        _buildIconText(trip.fuelUsedFormat,
                            Icons.local_fire_department_sharp),
                        _buildIconText(
                            trip.fuelPriceFormat, Icons.attach_money),
                        _buildIconText(
                          trip.savedCarboFormat,
                          Icons.co2,
                        ),
                        _buildIconText(
                          trip.producedCarboFormat,
                          Icons.co2,
                        ),
                        if (trip.fuelDiff > 0)
                          _buildIconText(
                            trip.fuelDiffFormat,
                            Icons.battery_full_rounded,
                          ),
                        if (trip.fuelDiff > 0)
                          _buildIconText(
                            trip.fuelRatioFormat,
                            Icons.aspect_ratio,
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIconText(
                          trip.dateTimeFormat,
                          Icons.calendar_today,
                        ),
                        _buildIconText(trip.avgSpeedFormat, Icons.speed),
                        _buildIconText(trip.totalTimeFormat, Icons.timelapse),
                        _buildIconText(
                            trip.driveTimeFormat, Icons.time_to_leave),
                        _buildIconText(trip.idleTimeFormat, Icons.sports_score),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconText(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        const SizedBox(width: 8.0),
        Text(text),
      ],
    );
  }
}

class TripSummaryCard extends StatelessWidget {
  const TripSummaryCard({
    Key? key,
    required this.trips,
  }) : super(key: key);

  final List<TripSummary> trips;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Text('Podsumowanie (${trips.length} przejazdy'),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Łącznie'),
                      const SizedBox(height: 16.0),
                      _buildIconText(
                        trips.totalFuelFormatted(),
                        Icons.local_gas_station,
                      ),
                      _buildIconText(
                        trips.totalDistanceFormatted(),
                        Icons.add_road,
                      ),
                      _buildIconText(
                          trips.totalCarboProducedFormatted(), Icons.co2),
                      _buildIconText(
                          trips.totalCarboSavedFormatted(), Icons.co2),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Średnio'),
                      const SizedBox(height: 16.0),
                      _buildIconText(
                        trips.averageDistanceFormatted(),
                        Icons.add_road,
                      ),
                      _buildIconText(
                        trips.averageSpeedFormatted(),
                        Icons.speed,
                      ),
                      _buildIconText(
                        trips.consumptionFormatted(),
                        Icons.local_gas_station,
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIconText(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        const SizedBox(width: 8.0),
        Text(text),
      ],
    );
  }
}
