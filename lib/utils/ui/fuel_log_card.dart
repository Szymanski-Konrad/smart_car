import 'package:flutter/material.dart';
import 'package:smart_car/app/navigation/navigation.dart';
import 'package:smart_car/app/navigation/routes.dart';
import 'package:smart_car/models/fuel_logs/fuel_log.dart';
import 'package:smart_car/pages/create_fuel_log/ui/create_fuel_log_page.dart';
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
    final station = fuelLog.stationName;
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
                fuelLog.odometerDiffFormat(),
                Icons.directions_car,
              ),
              _buildIconText(
                fuelLog.fuelWithCost(),
                Icons.local_gas_station,
              ),
              if (station != null)
                _buildIconText(
                  station,
                  Icons.location_on,
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      final argument = CreateFuelLogPageArgument(
                        currentOdometer: fuelLog.odometer,
                        lastFuelPrice: fuelLog.fuelPrice,
                        fuelLog: fuelLog,
                      );
                      Navigation.instance.push(
                        SharedRoutes.createFuelLog,
                        arguments: argument,
                      );
                    },
                    icon: const Icon(Icons.edit),
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
