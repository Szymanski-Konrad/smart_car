import 'package:smart_car/pages/live_data/model/abstract_commands/obd_command.dart';

enum CarFuelType {
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

extension CarFuelTypeExtension on CarFuelType {
  String get description {
    switch (this) {
      case CarFuelType.notAvaiable:
        return 'Not avaliable';
      case CarFuelType.gasoline:
        return 'Gasoline';
      case CarFuelType.methanol:
        return 'Methanol';
      case CarFuelType.ethanol:
        return 'Ethanol';
      case CarFuelType.diesel:
        return 'Diesel';
      case CarFuelType.lpg:
        return 'LPG';
      case CarFuelType.cng:
        return 'CNG';
      case CarFuelType.propane:
        return 'Propane';
      case CarFuelType.electric:
        return 'Electric';
      case CarFuelType.bifuelGasoline:
        return 'Bifuel running Gasoline';
      case CarFuelType.bifuelMethanol:
        return 'Bifuel running Methanol';
      case CarFuelType.bifuelEthanol:
        return 'Bifuel running Ethanol';
      case CarFuelType.bifuelLpg:
        return 'Bifuel running LPG';
      case CarFuelType.bifuelCng:
        return 'Bifuel running CNG';
      case CarFuelType.bifuelPropane:
        return 'Bifuel running Propane';
      case CarFuelType.bifuelElectricity:
        return 'Bifuel running Electricity';
      case CarFuelType.bifuelElectricCombustion:
        return 'Bifuel running electric and combustion engine';
      case CarFuelType.hybridGasoline:
        return 'Hybrid gasoline';
      case CarFuelType.hybridEthanol:
        return 'Hybrid Ethanol';
      case CarFuelType.hybridDiesel:
        return 'Hybrid Diesel';
      case CarFuelType.hybridElectric:
        return 'Hybrid Electric';
      case CarFuelType.hybridElectricCombustion:
        return 'Hybrid running electric and combustion engine';
      case CarFuelType.hybridRegenerative:
        return 'Hybrid Regenerative';
      case CarFuelType.bifuelDiesel:
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

  CarFuelType get type {
    switch (result) {
      case 0:
        return CarFuelType.notAvaiable;
      case 1:
        return CarFuelType.gasoline;
      case 2:
        return CarFuelType.methanol;
      case 3:
        return CarFuelType.ethanol;
      case 4:
        return CarFuelType.diesel;
      case 5:
        return CarFuelType.lpg;
      case 6:
        return CarFuelType.cng;
      case 7:
        return CarFuelType.propane;
      case 8:
        return CarFuelType.electric;
      case 9:
        return CarFuelType.bifuelGasoline;
      case 10:
        return CarFuelType.bifuelMethanol;
      case 11:
        return CarFuelType.bifuelEthanol;
      case 12:
        return CarFuelType.bifuelLpg;
      case 13:
        return CarFuelType.bifuelCng;
      case 14:
        return CarFuelType.bifuelPropane;
      case 15:
        return CarFuelType.bifuelElectricity;
      case 16:
        return CarFuelType.bifuelElectricCombustion;
      case 17:
        return CarFuelType.hybridGasoline;
      case 18:
        return CarFuelType.hybridEthanol;
      case 19:
        return CarFuelType.hybridDiesel;
      case 20:
        return CarFuelType.hybridElectric;
      case 21:
        return CarFuelType.hybridElectricCombustion;
      case 22:
        return CarFuelType.hybridRegenerative;
      case 23:
        return CarFuelType.bifuelDiesel;
      default:
        return CarFuelType.notAvaiable;
    }
  }
}
