import 'package:flutter/material.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/utils/ui/fuel_type_helpers.dart';

class FuelPriceCard extends StatelessWidget {
  const FuelPriceCard({
    Key? key,
    required this.type,
    required this.price,
    this.onTap,
  }) : super(key: key);

  final FuelStationType type;
  final double price;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FuelTypeHelper.selectFuelTypeIcon(type),
        const SizedBox(width: 8.0),
        GestureDetector(
          child: Text('${price.toStringAsFixed(2)} zł'),
          onTap: onTap,
        ),
      ],
    );
  }
}
