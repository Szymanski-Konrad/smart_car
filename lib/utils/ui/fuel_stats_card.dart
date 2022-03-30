import 'package:flutter/material.dart';
import 'package:smart_car/app/resources/strings.dart';
import 'package:smart_car/models/fuel_logs/fuel_log.dart';

class FuelStatsCard extends StatelessWidget {
  const FuelStatsCard({Key? key, required this.logs}) : super(key: key);

  final List<FuelLog> logs;

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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                  child: Text(
                      'Podsumowanie (${Strings.fuelLogsCounter(logs.length)})')),
              _buildIconText(
                logs.consumptionFormatted(),
                Icons.show_chart_outlined,
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Wszystkie'),
                        const SizedBox(height: 16.0),
                        _buildIconText(
                          logs.totalFuelFormatted(),
                          Icons.local_gas_station,
                        ),
                        _buildIconText(
                          logs.totalCostFormatted(),
                          Icons.account_balance_wallet,
                        ),
                        _buildIconText(
                          logs.totalDistanceFormatted(),
                          Icons.add_road_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Średnio'),
                        const SizedBox(height: 16.0),
                        _buildIconText(
                          logs.averageFuelFormatted(),
                          Icons.local_gas_station,
                        ),
                        _buildIconText(
                          logs.averageCostFormatted(),
                          Icons.account_balance_wallet,
                        ),
                        _buildIconText(
                          logs.averageDistanceFormatted(),
                          Icons.route,
                        ),
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
