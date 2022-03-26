import 'package:flutter/material.dart';
import 'package:smart_car/models/fuel_logs/fuel_log.dart';
import 'package:smart_car/utils/date_extension.dart';
import 'package:smart_car/utils/ui/fuel_type_helpers.dart';

class FuelLogCard extends StatelessWidget {
  const FuelLogCard({
    Key? key,
    required this.fuelLog,
  }) : super(key: key);

  final FuelLog fuelLog;

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
                  const Text('Tankowanie'),
                  FuelTypeHelper.selectFuelTypeIcon(fuelLog.fuelType),
                  _buildIconText(
                      fuelLog.logDate.toDateFormat, Icons.calendar_today),
                ],
              ),
              _buildIconText(
                fuelLog.fuelConsumptionFormatted(),
                Icons.show_chart_outlined,
              ),
              _buildIconText(
                fuelLog.distanceFormatted(),
                Icons.directions_car,
              ),
              _buildIconText(
                fuelLog.fuelWithCost(),
                Icons.local_gas_station,
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
