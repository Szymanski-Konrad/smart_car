import 'package:smart_car/pages/live_data/model/abstract_commands/obd_command.dart';

enum FuelType {
  notAvaiable,
  gasoline,
  methanol,
  ethanol,
  diesel,
  lpg,
  cng,
  propane,
  electric,
  bifuelGasoline,
  bifuelMethanol,
  bifuelEthanol,
  bifuelLpg,
  bifuelCng,
  bifuelPropane,
  bifuelElectricity,
  bifuelElectricCombustion,
  hybridGasoline,
  hybridEthanol,
  hybridDiesel,
  hybridElectric,
  hybridElectricCombustion,
  hybridRegenerative,
  bifuelDiesel,
}

extension FuelTypeExtension on FuelType {
  String get description {
    switch (this) {
      case FuelType.notAvaiable:
        return 'Not avaliable';
      case FuelType.gasoline:
        return 'Gasoline';
      case FuelType.methanol:
        return 'Methanol';
      case FuelType.ethanol:
        return 'Ethanol';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.lpg:
        return 'LPG';
      case FuelType.cng:
        return 'CNG';
      case FuelType.propane:
        return 'Propane';
      case FuelType.electric:
        return 'Electric';
      case FuelType.bifuelGasoline:
        return 'Bifuel running Gasoline';
      case FuelType.bifuelMethanol:
        return 'Bifuel running Methanol';
      case FuelType.bifuelEthanol:
        return 'Bifuel running Ethanol';
      case FuelType.bifuelLpg:
        return 'Bifuel running LPG';
      case FuelType.bifuelCng:
        return 'Bifuel running CNG';
      case FuelType.bifuelPropane:
        return 'Bifuel running Propane';
      case FuelType.bifuelElectricity:
        return 'Bifuel running Electricity';
      case FuelType.bifuelElectricCombustion:
        return 'Bifuel running electric and combustion engine';
      case FuelType.hybridGasoline:
        return 'Hybrid gasoline';
      case FuelType.hybridEthanol:
        return 'Hybrid Ethanol';
      case FuelType.hybridDiesel:
        return 'Hybrid Diesel';
      case FuelType.hybridElectric:
        return 'Hybrid Electric';
      case FuelType.hybridElectricCombustion:
        return 'Hybrid running electric and combustion engine';
      case FuelType.hybridRegenerative:
        return 'Hybrid Regenerative';
      case FuelType.bifuelDiesel:
        return 'Bifuel running diesel';
    }
  }
}

class FuelTypeCommand extends ObdCommand {
  FuelTypeCommand() : super('0151', prio: 1000);

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      result = data[0];
      super.performCalculations(data);
    }
  }

  FuelType get type {
    switch (result) {
      case 0:
        return FuelType.notAvaiable;
      case 1:
        return FuelType.gasoline;
      case 2:
        return FuelType.methanol;
      case 3:
        return FuelType.ethanol;
      case 4:
        return FuelType.diesel;
      case 5:
        return FuelType.lpg;
      case 6:
        return FuelType.cng;
      case 7:
        return FuelType.propane;
      case 8:
        return FuelType.electric;
      case 9:
        return FuelType.bifuelGasoline;
      case 10:
        return FuelType.bifuelMethanol;
      case 11:
        return FuelType.bifuelEthanol;
      case 12:
        return FuelType.bifuelLpg;
      case 13:
        return FuelType.bifuelCng;
      case 14:
        return FuelType.bifuelPropane;
      case 15:
        return FuelType.bifuelElectricity;
      case 16:
        return FuelType.bifuelElectricCombustion;
      case 17:
        return FuelType.hybridGasoline;
      case 18:
        return FuelType.hybridEthanol;
      case 19:
        return FuelType.hybridDiesel;
      case 20:
        return FuelType.hybridElectric;
      case 21:
        return FuelType.hybridElectricCombustion;
      case 22:
        return FuelType.hybridRegenerative;
      case 23:
        return FuelType.bifuelDiesel;
      default:
        return FuelType.notAvaiable;
    }
  }
}
