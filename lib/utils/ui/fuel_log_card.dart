import 'package:flutter/material.dart';
import 'package:smart_car/models/fuel_logs/fuel_log.dart';
import 'package:smart_car/utils/date_extension.dart';

class FuelLogCard extends StatelessWidget {
  const FuelLogCard({
    Key? key,
    required this.fuelLog,
  }) : super(key: key);

  final FuelLog fuelLog;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIconText(
                      fuelLog.logDate.toDateFormat, Icons.calendar_today),
                  _buildIconText(
                      fuelLog.fuelConsumption, Icons.account_balance_wallet),
                ],
              ),
            ),
            const VerticalDivider(
              width: 32.0,
              thickness: 2.0,
              color: Colors.blue,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIconText(fuelLog.odometerFormatted(), Icons.speed),
                  _buildIconText(fuelLog.totalCostFormatted(),
                      Icons.account_balance_wallet),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconText(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8.0),
        Text(text),
      ],
    );
  }
}
