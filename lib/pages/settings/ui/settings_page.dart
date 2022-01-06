import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            title: Text('Settings'),
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
        _buildSettingsTile(
          value: state.settings.engineCapacity.toString(),
          suffix: 'cm3',
          onEdit: cubit.updateEngineCapacity,
        ),
        _buildSettingsTile(
          value: state.settings.fuelPrice.toString(),
          suffix: 'zł',
          onEdit: cubit.updateFuelPrice,
          keyboardType: const TextInputType.numberWithOptions(
              decimal: true, signed: true),
        ),
        _buildSettingsTile(
            value: state.settings.horsepower.toString(),
            suffix: 'KM',
            onEdit: cubit.updateHorsepower),
        _buildSettingsTile(
          value: state.settings.tankSize.toString(),
          suffix: 'l',
          onEdit: cubit.updateTankSize,
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required String value,
    required String suffix,
    Function(String)? onEdit,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return ListTile(
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
    print(widget.keyboardType ==
        const TextInputType.numberWithOptions(decimal: true));
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
