import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:smart_car/app/navigation/navigation.dart';
import 'package:smart_car/app/navigation/routes.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/models/settings.dart';
import 'package:smart_car/pages/settings/bloc/settings_cubit.dart';
import 'package:smart_car/pages/settings/bloc/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ustawienia zapisane'),
        ));
        context.read<SettingsCubit>().changeSaved(false);
      },
      listenWhen: (prev, current) {
        return !prev.isSaved && current.isSaved;
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SettingsState state) {
    final cubit = context.read<SettingsCubit>();
    return ListView(
      children: [
        ListTile(
          title: ElevatedButton(
            child: const Text('Select default OBDII device'),
            onPressed: () async {
              final BluetoothDevice device = await Navigation.instance
                  .push(SharedRoutes.selectBoundedDevice);
              cubit.updateDevice(device);
            },
          ),
        ),
        ListTile(
          title: Text(state.settings.deviceDescription),
          subtitle: const Text('Selected device'),
        ),
        if (kDebugMode)
          ListTile(
            leading: const Text('Select file: '),
            title: DropdownButton(
              value: state.settings.selectedJson,
              onChanged: cubit.updateJson,
              items: Constants.localFiles
                  .map((e) => DropdownMenuItem(
                        child: Text(e),
                        value: e,
                      ))
                  .toList(),
            ),
          ),
        _buildSettingsTile(
          value: state.settings.engineCapacity.toString(),
          leading: 'Pojemność silnika',
          suffix: 'cm3',
          onEdit: cubit.updateEngineCapacity,
        ),
        _buildSettingsTile(
          value: state.settings.fuelPrice.toString(),
          leading: 'Cena paliwa',
          suffix: 'zł',
          onEdit: cubit.updateFuelPrice,
          keyboardType: const TextInputType.numberWithOptions(
              decimal: true, signed: true),
        ),
        _buildSettingsTile(
            value: state.settings.horsepower.toString(),
            leading: 'Moc silnika',
            suffix: 'KM',
            onEdit: cubit.updateHorsepower),
        _buildSettingsTile(
          value: state.settings.tankSize.toString(),
          leading: 'Pojemność baku',
          suffix: 'l',
          onEdit: cubit.updateTankSize,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text('Rodzaj paliwa: '),
              const SizedBox(width: 32),
              Expanded(
                child: DropdownButton<FuelType>(
                  value: state.settings.fuelType,
                  isExpanded: true,
                  itemHeight: 60,
                  items: FuelType.values
                      .map((e) => DropdownMenuItem<FuelType>(
                            child: Text(e.name),
                            value: e,
                          ))
                      .toList(),
                  onChanged: cubit.updateFuelType,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required String value,
    required String suffix,
    required String leading,
    Function(String)? onEdit,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return ListTile(
      leading: SizedBox(
        width: 120,
        child: Text(leading),
      ),
      title: onEdit == null
          ? Text(value)
          : SettingsTextField(
              initalValue: value,
              onEdit: onEdit,
              keyboardType: keyboardType,
            ),
      trailing: Text(suffix),
    );
  }
}

class SettingsTextField extends StatefulWidget {
  const SettingsTextField({
    Key? key,
    required this.initalValue,
    required this.onEdit,
    this.validator,
    this.keyboardType = TextInputType.number,
  }) : super(key: key);

  final String initalValue;
  final Function(String) onEdit;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  @override
  State<SettingsTextField> createState() => _SettingsTextFieldState();
}

class _SettingsTextFieldState extends State<SettingsTextField> {
  bool validated = false;

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
      validator: widget.validator ?? _defaultValidator,
      onChanged: widget.onEdit,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  String? _defaultValidator(String? input) {
    validated = false;
    if (input == null || input.isEmpty) return 'Wartość nie może być pusta';
    final value = double.tryParse(input);
    if (value == null) return 'Wartość nie jest liczbą';
    validated = true;
    return null;
  }
}
