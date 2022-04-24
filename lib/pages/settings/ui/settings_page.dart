import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:smart_car/app/navigation/navigation.dart';
import 'package:smart_car/app/navigation/routes.dart';
import 'package:smart_car/app/resources/constants.dart';
import 'package:smart_car/app/resources/strings.dart';
import 'package:smart_car/models/settings.dart';
import 'package:smart_car/pages/settings/bloc/settings_cubit.dart';
import 'package:smart_car/pages/settings/bloc/settings_state.dart';
import 'package:smart_car/utils/validators.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(Strings.settingsSaved),
        ));
        context.read<SettingsCubit>().changeSaved(false);
      },
      listenWhen: (prev, current) {
        return !prev.isSaved && current.isSaved;
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(Strings.settings),
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
            child: const Text(Strings.selectDefaultDevice),
            onPressed: () async {
              final BluetoothDevice device = await Navigation.instance
                  .push(SharedRoutes.selectBoundedDevice);
              cubit.updateDevice(device);
            },
          ),
        ),
        ListTile(
          title: Text(state.settings.deviceDescription),
          subtitle: const Text(Strings.selectedDevice),
        ),
        ListTile(
          leading: const Text(Strings.selectFile),
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
          leading: Strings.engineCapacity,
          suffix: 'cm3',
          onEdit: cubit.updateEngineCapacity,
        ),
        _buildSettingsTile(
          value: state.settings.fuelPrice.toString(),
          leading: Strings.fuelPrice,
          suffix: 'zł',
          onEdit: cubit.updateFuelPrice,
          keyboardType: const TextInputType.numberWithOptions(
              decimal: true, signed: true),
        ),
        _buildSettingsTile(
            value: state.settings.horsepower.toString(),
            leading: Strings.enginePower,
            suffix: 'KM',
            onEdit: cubit.updateHorsepower),
        _buildSettingsTile(
          value: state.settings.tankSize.toString(),
          leading: Strings.tankCapacity,
          suffix: 'l',
          onEdit: cubit.updateTankSize,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text(Strings.fuelType),
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
    String? Function(String?)? validator,
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
              validator: validator,
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
