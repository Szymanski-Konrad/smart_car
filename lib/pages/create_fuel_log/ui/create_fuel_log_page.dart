import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_car/pages/create_fuel_log/bloc/create_fuel_log_cubit.dart';
import 'package:smart_car/pages/create_fuel_log/bloc/create_fuel_log_state.dart';
import 'package:smart_car/utils/route_argument.dart';
import 'package:smart_car/utils/scoped_bloc_builder.dart';
import 'package:smart_car/utils/validators.dart';

class CreateFuelLogPageArgument {
  CreateFuelLogPageArgument({
    required this.currentOdometer,
    required this.lastFuelPrice,
  });

  final double currentOdometer;
  final double lastFuelPrice;
}

class CreateFuelLogPage extends StatelessWidget
    with RouteArgument<CreateFuelLogPageArgument> {
  const CreateFuelLogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final argument = getArgument(context);
    return ScopedBlocBuilder<CreateFuelLogCubit, CreateFuelLogState>(
      create: (_) => CreateFuelLogCubit(
        fuelPrice: argument.lastFuelPrice,
        odometer: argument.currentOdometer,
      ),
      builder: (context, state, cubit) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Nowy wpis'),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: state.isCorrect ? cubit.saveLog : null,
                icon: const Icon(Icons.check),
              ),
            ],
          ),
          body: _createBody(context, state, cubit),
        );
      },
    );
  }

  Widget _createBody(
    BuildContext context,
    CreateFuelLogState state,
    CreateFuelLogCubit cubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildRow(
              'Licznik (km)', state.odometer.toString(), cubit.updateOdometer),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildRow('Ilość paliwa', state.fuelAmount.toString(),
              cubit.updateFuelAmount),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildRow(
              'Cena paliwa', state.fuelPrice.toString(), cubit.updateFuelPrice),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildDateRow(context, state, cubit),
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('Podsumowanie:')),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Całkowity koszt ${state.totalPrice.toString()} zł'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Spalanie: ${state.fuelCons} zł'),
        ),
      ],
    );
  }

  Widget _buildRow(
    String label,
    String? initialValue,
    Function(String?) onEdit, {
    TextInputType inputType =
        const TextInputType.numberWithOptions(decimal: true),
  }) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(label),
        ),
        Expanded(
          child: FuelLogTextField(
            initalValue: initialValue,
            onEdit: onEdit,
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
    this.keyboardType = TextInputType.number,
  }) : super(key: key);

  final String? initalValue;
  final Function(String) onEdit;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  @override
  State<FuelLogTextField> createState() => _FuelLogTextFieldState();
}

class _FuelLogTextFieldState extends State<FuelLogTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: widget.initalValue,
      keyboardType: widget.keyboardType,
      inputFormatters: [
        if (widget.keyboardType == TextInputType.number)
          FilteringTextInputFormatter.digitsOnly,
        if (widget.keyboardType.index == 2)
          FilteringTextInputFormatter.deny(RegExp(r','),
              replacementString: '.'),
      ],
      validator: widget.validator ?? Validators.positiveNumberValidator,
      onChanged: widget.onEdit,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
