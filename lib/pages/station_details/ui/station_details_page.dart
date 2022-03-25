import 'package:flutter/material.dart';
import 'package:smart_car/app/navigation/navigation.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/pages/station_details/bloc/station_details_cubit.dart';
import 'package:smart_car/pages/station_details/bloc/station_details_state.dart';
import 'package:smart_car/utils/route_argument.dart';
import 'package:smart_car/utils/scoped_bloc_builder.dart';
import 'package:smart_car/utils/ui/fuel_price_card.dart';
import 'package:smart_car/utils/ui/fuel_type_helpers.dart';

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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Nazwa: ${state.station.name}'),
                  const SizedBox(height: 16.0),
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
                  const SizedBox(height: 16.0),
                  const Text('Dostępne rodzaje paliwa:'),
                  const SizedBox(height: 8.0),
                  Wrap(
                    spacing: 8.0,
                    children: [
                      if (!state.station.hasDiesel == true)
                        FuelTypeHelper.iconON(),
                      if (!state.station.hasLpg == true)
                        FuelTypeHelper.iconLPG(),
                      if (!state.station.hasPb95 == true)
                        FuelTypeHelper.iconPB95(),
                      if (!state.station.hasPb98 == true)
                        FuelTypeHelper.iconPB98(),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  const Text('Ceny paliw'),
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
                    child: const Text('Zapisz zmiany'),
                  ),
                ],
              ),
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
        FuelPriceCard(
          type: fuelType,
          price: price,
          onTap: widget.isEditable
              ? () => _showInputDialog(context, widget.cubit, price, fuelType)
              : null,
        ),
        if (!widget.isEditable)
          IconButton(
            onPressed: () => widget.cubit.enablePriceChange(widget.fuelType),
            icon: const Icon(Icons.edit),
          ),
        if (widget.isEditable) ...[
          IconButton(
            onPressed: () => widget.cubit.increasePrice(fuelType),
            icon: const Icon(Icons.keyboard_arrow_up_sharp),
          ),
          IconButton(
            onPressed: () => widget.cubit.decreasePrice(fuelType),
            icon: const Icon(Icons.keyboard_arrow_down_sharp),
          ),
          IconButton(
            onPressed: () => widget.cubit.disablePriceChange(fuelType, true),
            icon: const Icon(Icons.check),
          ),
          IconButton(
            onPressed: () => widget.cubit.disablePriceChange(fuelType, false),
            icon: const Icon(Icons.cancel_outlined),
          ),
        ],
      ],
    );
  }

  void _showInputDialog(
    BuildContext context,
    StationDetailsCubit cubit,
    double initialValue,
    FuelStationType fuelType,
  ) {
    final _textController =
        TextEditingController(text: initialValue.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wprowadź cenę'),
        content: TextField(
          autofocus: true,
          controller: _textController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(_textController.text);
              cubit.editPrice(fuelType, value);
              Navigator.of(context).pop();
            },
            child: const Text('Zapisz'),
          )
        ],
      ),
    );
  }
}
