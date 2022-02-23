import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_car/pages/fuel_logs/bloc/fuel_logs_cubit.dart';
import 'package:smart_car/pages/settings/bloc/settings_cubit.dart';

class GlobalBlocs {
  static final fuelLogs = FuelLogsCubit();
  static final settings = SettingsCubit();

  static final List<BlocProvider> blocs = [
    BlocProvider(
      create: (_) => settings..loadSettings(),
      lazy: false,
    ),
    BlocProvider(
      create: (_) => fuelLogs,
      lazy: false,
    ),
  ];
}
