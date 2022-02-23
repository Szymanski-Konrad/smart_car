import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_car/pages/create_fuel_log/bloc/create_fuel_log_cubit.dart';
import 'package:smart_car/pages/create_fuel_log/bloc/create_fuel_log_state.dart';
import 'package:smart_car/utils/scoped_bloc_builder.dart';
import 'package:smart_car/utils/ui/standart_text_field.dart';
import 'package:smart_car/utils/validators.dart';

class CreateFuelLogPage extends StatelessWidget {
  const CreateFuelLogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedBlocBuilder<CreateFuelLogCubit, CreateFuelLogState>(
      create: (_) => CreateFuelLogCubit(),
      builder: (context, state, cubit) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Nowy wpis'),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  cubit.saveLog();
                },
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
      children: [
        _buildRow('Licznik (km)', state.odometer.toString(), cubit.tempEdit),
        _buildRow('Ilość paliwa', state.fuelAmount.toString(), cubit.tempEdit),
        _buildRow('Cena paliwa', state.fuelPrice.toString(), cubit.tempEdit),
        _buildRow(
            'Całkowity koszt', state.totalPrice.toString(), cubit.tempEdit),
        _buildDateRow(context, 'Data', state.dateTime, cubit.dateUpdate),
      ],
    );
  }

  Widget _buildRow(
    String label,
    String? initialValue,
    Function(String?) onEdit,
  ) {
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
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow(
    BuildContext context,
    String label,
    DateTime initialDate,
    Function(DateTime?) onEdit,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(label),
        ),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: initialDate.subtract(Duration(days: 30)),
              lastDate: initialDate.add(Duration(days: 30)),
            );
            onEdit(date);
          },
          child: Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(initialDate.toIso8601String()),
            ),
          ),
        ),
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
