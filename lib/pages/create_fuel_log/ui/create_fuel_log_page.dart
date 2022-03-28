import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_car/models/fuel_logs/fuel_log.dart';
import 'package:smart_car/models/gas_stations/gas_station.dart';
import 'package:smart_car/pages/create_fuel_log/bloc/create_fuel_log_cubit.dart';
import 'package:smart_car/pages/create_fuel_log/bloc/create_fuel_log_state.dart';
import 'package:smart_car/utils/list_extension.dart';
import 'package:smart_car/utils/route_argument.dart';
import 'package:smart_car/utils/scoped_bloc_builder.dart';
import 'package:smart_car/utils/ui/fuel_type_helpers.dart';
import 'package:smart_car/utils/validators.dart';

class CreateFuelLogPageArgument {
  CreateFuelLogPageArgument({
    required this.currentOdometer,
    required this.lastFuelPrice,
    this.fuelLog,
  });

  final double currentOdometer;
  final double lastFuelPrice;
  FuelLog? fuelLog;
}

class CreateFuelLogPage extends StatelessWidget
    with RouteArgument<CreateFuelLogPageArgument> {
  const CreateFuelLogPage({Key? key}) : super(key: key);

  static const double _labelWidth = 150.0;

  @override
  Widget build(BuildContext context) {
    final argument = getArgument(context);
    return ScopedBlocBuilder<CreateFuelLogCubit, CreateFuelLogState>(
      create: (_) => CreateFuelLogCubit(
        fuelPrice: argument.lastFuelPrice,
        odometer: argument.currentOdometer,
        fuelLog: argument.fuelLog,
      ),
      builder: (context, state, cubit) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: !state.isSaving,
            title: const Text('Nowy wpis'),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: state.isCorrect ? cubit.saveLog : null,
                icon: const Icon(Icons.check),
              ),
            ],
          ),
          body: state.isSaving
              ? const CircularProgressIndicator()
              : _createBody(context, state, cubit),
        );
      },
    );
  }

  Widget _createBody(
    BuildContext context,
    CreateFuelLogState state,
    CreateFuelLogCubit cubit,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!state.isDistanceMode)
              _buildRow(
                'Licznik (km)',
                onEdit: cubit.updateOdometer,
                controller: cubit.odometerTextController,
                validator: cubit.checkOdometerValue,
                hintText:
                    'Aktualny stan licznika: ${state.currentOdometer.toStringAsFixed(1)} km',
                suffixText: 'km',
              ),
            if (state.isDistanceMode)
              _buildRow(
                'Licznik dzienny (km)',
                controller: cubit.distanceTextController,
                onEdit: cubit.updateDistance,
                hintText:
                    'Aktualny stan licznika: ${state.currentOdometer.toStringAsFixed(1)} km',
                suffixText: 'km',
              ),
            _buildToggleFuelInputTypeRow(state, cubit),
            _buildRow(
              'Ilość paliwa',
              initialValue: state.fuelAmount.toString(),
              onEdit: cubit.updateFuelAmount,
              suffixText: 'l',
            ),
            _buildRow(
              'Cena paliwa',
              initialValue: state.fuelPrice.toString(),
              onEdit: cubit.updateFuelPrice,
              suffixText: 'zł',
            ),
            _buildSelectFuelRow(state.fuelType, cubit),
            _buildDateRow(context, state, cubit),
            _buildSelectedStationRow(state.selectedGasStation),
            _buildSelectStationRow(state, cubit),
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Center(child: Text('Podsumowanie:')),
            ),
            Text('Całkowity koszt: ${state.totalCost.toString()} zł'),
            Text('Spalanie: ${state.fuelCons}'),
          ].cast<Widget>().dividedBy(const SizedBox(height: 12.0)),
        ),
      ),
    );
  }

  Widget _buildSelectedStationRow(GasStation? gasStation) {
    return Row(
      children: [
        const SizedBox(width: _labelWidth, child: Text('Wybrana stacja')),
        if (gasStation != null) Expanded(child: Text(gasStation.stationName)),
      ],
    );
  }

  Widget _buildToggleFuelInputTypeRow(
    CreateFuelLogState state,
    CreateFuelLogCubit cubit,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text('Przebieg'),
        Switch.adaptive(
          value: state.odometerInputType == OdometerInputType.diff,
          onChanged: cubit.toggleOdometerInputType,
        ),
        const Text('Dystans'),
      ],
    );
  }

  Widget _buildSelectStationRow(
    CreateFuelLogState state,
    CreateFuelLogCubit cubit,
  ) {
    if (state.isStationsLoading) return const LinearProgressIndicator();
    final location = state.coordinates;
    if (location == null) return const Text('Brak stacji w pobliżu');
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: state.nearGasStations
            .map(
              (e) => GestureDetector(
                onTap: () => cubit.selectStation(e),
                child: Card(
                  color: e.id == state.selectedGasStation?.id
                      ? Colors.green
                      : Colors.grey[800]!,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(e.name),
                        Text('${e.distanceTo(location).toStringAsFixed(2)} km'),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSelectFuelRow(
      FuelStationType selected, CreateFuelLogCubit cubit) {
    return Row(
      children: [
        const SizedBox(
          width: _labelWidth,
          child: Text('Rodzaj paliwa'),
        ),
        Wrap(
          spacing: 8.0,
          children: FuelStationType.values
              .map(
                (e) => GestureDetector(
                  onTap: () => cubit.changeFuelType(e),
                  child: FuelTypeHelper.selectFuelTypeIcon(
                    e,
                    color: e == selected ? Colors.green : Colors.black,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRow(
    String label, {
    required Function(String?) onEdit,
    String? initialValue,
    TextEditingController? controller,
    TextInputType inputType =
        const TextInputType.numberWithOptions(decimal: true),
    String? Function(String?)? validator,
    String? hintText,
    String? suffixText,
  }) {
    return Row(
      children: [
        SizedBox(
          width: _labelWidth,
          child: Text(label),
        ),
        Expanded(
          child: FuelLogTextField(
            initalValue: initialValue,
            controller: controller,
            validator: validator,
            onEdit: onEdit,
            hintText: hintText,
            suffixText: suffixText,
            keyboardType: inputType,
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow(
    BuildContext context,
    CreateFuelLogState state,
    CreateFuelLogCubit cubit,
  ) {
    return Row(
      children: [
        const SizedBox(
          width: 150,
          child: Text('Data'),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: state.date,
                firstDate: DateTime(2000, 1, 1),
                lastDate: DateTime.now(),
              );
              cubit.dateUpdate(date);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(state.dateDesc),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: state.time,
              );
              cubit.timeUpdate(time);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(state.timeDesc),
            ),
          ),
        )
      ],
    );
  }
}

class FuelLogTextField extends StatefulWidget {
  const FuelLogTextField({
    Key? key,
    required this.initalValue,
    required this.onEdit,
    this.validator,
    this.hintText,
    this.suffixText,
    this.keyboardType = TextInputType.number,
    this.onInitialChange,
    this.controller,
  }) : super(key: key);

  final String? initalValue;
  final TextEditingController? controller;
  final String? hintText;
  final String? suffixText;
  final Function(String) onEdit;
  final String? Function(String?)? validator;
  final Function(String)? onInitialChange;
  final TextInputType keyboardType;

  @override
  State<FuelLogTextField> createState() => _FuelLogTextFieldState();
}

class _FuelLogTextFieldState extends State<FuelLogTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      initialValue: widget.controller != null ? null : widget.initalValue,
      keyboardType: widget.keyboardType,
      inputFormatters: [
        if (widget.keyboardType == TextInputType.number)
          FilteringTextInputFormatter.digitsOnly,
        if (widget.keyboardType.index == 2)
          FilteringTextInputFormatter.deny(RegExp(r','),
              replacementString: '.'),
      ],
      validator: widget.validator ?? Validators.positiveNumberValidator,
      decoration: InputDecoration(
        helperText: widget.hintText,
        suffixText: widget.suffixText,
      ),
      onChanged: widget.onEdit,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
