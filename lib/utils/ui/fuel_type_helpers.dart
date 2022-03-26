import 'package:flutter/material.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';

abstract class FuelTypeHelper {
  FuelTypeHelper._();

  static Widget selectFuelTypeIcon(FuelStationType type, {Color? color}) {
    switch (type) {
      case FuelStationType.pb95:
        return _buildFuelTypeIcon('PB95', color ?? Colors.green);
      case FuelStationType.pb98:
        return _buildFuelTypeIcon('PB98', color ?? Colors.green);
      case FuelStationType.diesel:
        return _buildFuelTypeIcon('ON', color ?? Colors.black);
      case FuelStationType.lpg:
        return _buildFuelTypeIcon('LPG', color ?? Colors.red);
    }
  }

  static Widget iconPB95() {
    return _buildFuelTypeIcon('PB95', Colors.green);
  }

  static Widget iconPB98() {
    return _buildFuelTypeIcon('PB98', Colors.green);
  }

  static Widget iconON() {
    return _buildFuelTypeIcon('ON', Colors.black);
  }

  static Widget iconLPG() {
    return _buildFuelTypeIcon('LPG', Colors.red);
  }

  static Widget _buildFuelTypeIcon(
    String value,
    Color background,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8.0),
      ),
      height: 30,
      width: 40,
      child: Center(
        child: Text(
          value,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
