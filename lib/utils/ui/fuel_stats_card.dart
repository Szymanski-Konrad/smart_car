import 'package:flutter/material.dart';
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Podsumowanie'),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: _buildIconText(
                      logs.fuelFormatted(),
                      Icons.local_gas_station,
                    ),
                  ),
                  Expanded(
                    child: _buildIconText(
                      logs.costFormatted(),
                      Icons.account_balance_wallet,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildIconText(
                      logs.distanceFormatted(),
                      Icons.route,
                    ),
                  ),
                  Expanded(
                    child: _buildIconText(
                      logs.consumptionFormatted(),
                      Icons.show_chart_outlined,
                    ),
                  ),
                ],
              )
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
