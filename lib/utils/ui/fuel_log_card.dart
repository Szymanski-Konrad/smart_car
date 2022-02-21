import 'package:flutter/material.dart';
import 'package:smart_car/models/fuel_logs/fuel_log.dart';

class FuelLogCard extends StatelessWidget {
  const FuelLogCard({
    Key? key,
    required this.fuelLog,
  }) : super(key: key);

  final FuelLog fuelLog;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Column(
        children: [
          Text(fuelLog.showOdometer),
          Text(fuelLog.showOdometerDiff),
          Text(fuelLog.logDate.toString()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(fuelLog.showFuelPrice),
              Text(fuelLog.showTotalPrice),
            ],
          ),
        ],
      ),
    );
  }
}
