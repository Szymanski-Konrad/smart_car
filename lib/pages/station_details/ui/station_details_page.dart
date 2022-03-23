import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/pages/station_details/bloc/station_details_cubit.dart';
import 'package:smart_car/pages/station_details/bloc/station_details_state.dart';
import 'package:smart_car/utils/route_argument.dart';
import 'package:smart_car/utils/scoped_bloc_builder.dart';

class StationDetailsPageArguments {
  StationDetailsPageArguments({required this.station});

  final GasStation station;
}

class StationDetailsPage extends StatelessWidget
    with RouteArgument<StationDetailsPageArguments> {
  const StationDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Szczegóły stacji')),
      body: ScopedBlocBuilder<StationDetailsCubit, StationDetailsState>(
        create: (_) => StationDetailsCubit(getArgument(context).station),
        builder: (context, state, cubit) => SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Nazwa: ${state.station.name}'),
                const SizedBox(height: 8.0),
                Text('Ceny paliw: ${state.station.fuelPrices.toString()}'),
                Text(
                    'Lokalizacja ${state.station.coordinates.toSexagesimal()}'),
                if (state.station.brand != null)
                  Text('Sieć: ${state.station.brand}'),
                if (state.station.city != null)
                  Text('Miasto: ${state.station.city}'),
                if (state.station.openingHours != null)
                  Text('Godziny otwarcia: ${state.station.openingHours}'),
                if (state.station.stationOperator != null)
                  Text('Operator: ${state.station.stationOperator}'),
                if (state.station.street != null)
                  Text('Ulica: ${state.station.street}'),
                Wrap(
                  children: [
                    if (state.station.hasDiesel == true) const Text('Diesel ✅'),
                    if (state.station.hasElectricity == true)
                      const Text('Prąd ✅'),
                    if (state.station.hasLpg == true) const Text('LPG ✅'),
                    if (state.station.hasPb95 == true) const Text('Pb95 ✅'),
                    if (state.station.hasPb98 == true) const Text('Pb98 ✅'),
                    if (state.station.hasShop == true) const Text('Sklep ✅'),
                  ],
                ),
                ...FuelStationType.values.map(
                  (type) => FuelPriceRow(
                    cubit: cubit,
                    fuelType: type,
                    price: state.fuelPrice(type),
                    isEditable: state.isPriceEdited(type),
                    isEnabled: state.containsPrice(type),
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      state.updatePrices.isEmpty ? cubit.saveChanges : null,
                  child: Text('Zapisz zmiany'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FuelPriceRow extends StatefulWidget {
  const FuelPriceRow({
    Key? key,
    required this.cubit,
    required this.fuelType,
    required this.price,
    required this.isEditable,
    required this.isEnabled,
  }) : super(key: key);

  final StationDetailsCubit cubit;
  final FuelStationType fuelType;
  final double? price;
  final bool isEditable;
  final bool isEnabled;

  @override
  State<FuelPriceRow> createState() => _FuelPriceRowState();
}

class _FuelPriceRowState extends State<FuelPriceRow> {
  @override
  Widget build(BuildContext context) {
    final price = widget.price;
    final fuelType = widget.fuelType;
    if (price == null || !widget.isEnabled) {
      return TextButton(
        onPressed: () => widget.cubit.addNewFuelType(widget.fuelType),
        child: Text('+ ${widget.fuelType.name}'),
      );
    }
    return Row(
      children: [
        const Icon(Icons.local_gas_station),
        const SizedBox(width: 8.0),
        Text(widget.fuelType.name),
        const SizedBox(width: 8.0),
        Text(price.toStringAsFixed(2)),
        const SizedBox(width: 8.0),
        if (!widget.isEditable)
          IconButton(
            onPressed: () => widget.cubit.enablePriceChange(widget.fuelType),
            icon: Icon(Icons.edit),
          ),
        if (widget.isEditable) ...[
          IconButton(
            onPressed: () => widget.cubit.increasePrice(fuelType),
            icon: Icon(Icons.keyboard_arrow_up_sharp),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            onPressed: () => widget.cubit.decreasePrice(fuelType),
            icon: Icon(Icons.keyboard_arrow_down_sharp),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            onPressed: () => widget.cubit.disablePriceChange(fuelType, true),
            icon: Icon(Icons.check),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            onPressed: () => widget.cubit.disablePriceChange(fuelType, false),
            icon: Icon(Icons.cancel_outlined),
          ),
        ],
      ],
    );
  }
}
