import 'package:flutter/material.dart';
import 'package:smart_car/models/gas_stations/fuel_info.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/utils/ui/fuel_type_helpers.dart';
import 'package:timeago/timeago.dart' as timeago;

class FuelPriceCard extends StatelessWidget {
  const FuelPriceCard({
    Key? key,
    required this.type,
    required this.fuelInfo,
    this.changeDate,
    this.onTap,
  }) : super(key: key);

  final FuelStationType type;
  final FuelInfo fuelInfo;
  final DateTime? changeDate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final _changeDate = changeDate;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FuelTypeHelper.selectFuelTypeIcon(type),
        const SizedBox(width: 8.0),
        GestureDetector(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${fuelInfo.price.toStringAsFixed(2)} zł',
              style: priceStyle,
            ),
          ),
          onTap: onTap,
        ),
        if (_changeDate != null && onTap == null)
          Text(timeago.format(_changeDate)),
      ],
    );
  }

  TextStyle? get priceStyle => onTap != null
      ? const TextStyle(
          color: Colors.amber,
          decorationThickness: 2,
          decoration: TextDecoration.underline,
        )
      : null;
}
