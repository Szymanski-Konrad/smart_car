import 'package:flutter/material.dart';
import 'package:smart_car/pages/live_data/model/abstract_commands/visible_obd_command.dart';
import 'package:smart_car/utils/fuel_helper.dart';

class MapCommand extends VisibleObdCommand {
  MapCommand() : super('010B', min: 0, max: 255, prio: 0, enableHistory: true);

  @override
  Color get color {
    if (max * 0.9 < result) return dangerColor;
    if (max * 0.8 < result) return warningColor;
    return normalColor;
  }

  @override
  String get description => 'Current MAP (Manifold Absolute pressure)';

  @override
  String get name => 'MAP';

  @override
  void performCalculations(List<int> data) {
    if (data.isNotEmpty) {
      result = data[0];
      super.performCalculations(data);
    }
  }

  @override
  String get unit => 'kPa';

  @override
  IconData get icon => Icons.air;

  @override
  String get formattedResult =>
      result.isFinite ? '$result $unit' : super.formattedResult;

  double _fuelFlow = 0;

  /// Oblicz estymowany MAF z MAP używając równania gazu idealnego
  /// [rpm] - obroty silnika
  /// [intakeAirTemp] - temperatura powietrza w °C (domyślnie 25°C)
  /// [engineDisplacementCc] - pojemność silnika w cm³
  /// [volumetricEfficiency] - sprawność wolumetryczna (domyślnie 0.85)
  ///
  /// Wzór: MAF = (MAP * RPM * VE * displacement) / (R * T * 120)
  /// Gdzie:
  /// - MAP w kPa
  /// - displacement w litrach
  /// - T w Kelvinach
  /// - R = 8.314 J/(mol·K)
  /// - 28.97 g/mol to masa molowa powietrza
  double estimateMAF({
    required double rpm,
    double intakeAirTemp = 25.0,
    required int engineDisplacementCc,
    double volumetricEfficiency = 0.85,
  }) {
    if (result <= 0 || rpm <= 0 || engineDisplacementCc <= 0) {
      return 0;
    }

    final map = result.toDouble(); // kPa
    final tempKelvin = intakeAirTemp + 273.15; // Konwersja na Kelvin
    final displacementLiters = engineDisplacementCc / 1000.0; // cm³ -> L

    // Stała dla powietrza: (masa molowa powietrza) / (R * 120 dla 4-suw)
    // 28.97 / (8.314 * 120) ≈ 0.02904
    // Dodatkowo mnożymy przez 1000 bo MAP jest w kPa a nie Pa
    const airConstant = 28.97 / (8.314 * 120);

    // MAF w g/s
    final maf =
        (map * rpm * volumetricEfficiency * displacementLiters * airConstant) /
        tempKelvin;

    return maf;
  }

  /// Oblicz przepływ paliwa w [l/h] używając estymowanego MAF z MAP
  /// [rpm] - obroty silnika
  /// [intakeAirTemp] - temperatura powietrza w °C
  /// [engineDisplacementCc] - pojemność silnika w cm³
  /// [ratio] - współczynnik korekcji stosunku powietrza do paliwa
  /// [trimTerm] - współczynnik korekcji paliwa (fuel trim)
  /// [volumetricEfficiency] - sprawność wolumetryczna
  void calculateFuelFlowFromMAP({
    required double rpm,
    double intakeAirTemp = 25.0,
    required int engineDisplacementCc,
    double ratio = 1.0,
    double trimTerm = 1.0,
    double volumetricEfficiency = 0.85,
  }) {
    final estimatedMaf = estimateMAF(
      rpm: rpm,
      intakeAirTemp: intakeAirTemp,
      engineDisplacementCc: engineDisplacementCc,
      volumetricEfficiency: volumetricEfficiency,
    );

    final airFuelRatio = FuelHelper.airFuelAspectRatio() * ratio;
    final fuelDensity = FuelHelper.density();

    if (estimatedMaf > 0) {
      // Przepływ paliwa w l/h
      // MAF (g/s) * 3600 (s/h) / AFR / density (g/l)
      _fuelFlow = (estimatedMaf * trimTerm * 3600) / airFuelRatio / fuelDensity;
    } else {
      _fuelFlow = 0;
    }
  }

  /// Oblicz zużycie paliwa na 100 km używając MAP
  /// [speed] - prędkość pojazdu w km/h
  /// [rpm] - obroty silnika
  /// [intakeAirTemp] - temperatura powietrza w °C
  /// [engineDisplacementCc] - pojemność silnika w cm³
  /// [longTerm] - długoterminowa korekcja paliwa
  /// [shortTerm] - krótkoterminowa korekcja paliwa
  /// [ratio] - współczynnik korekcji stosunku powietrza do paliwa
  /// [volumetricEfficiency] - sprawność wolumetryczna
  double fuel100kmFromMAP({
    required int speed,
    required double rpm,
    double intakeAirTemp = 25.0,
    required int engineDisplacementCc,
    double longTerm = 0.0,
    double shortTerm = 0.0,
    double ratio = 1.0,
    double volumetricEfficiency = 0.85,
  }) {
    final trimTerm = 1 + longTerm + shortTerm;
    calculateFuelFlowFromMAP(
      rpm: rpm,
      intakeAirTemp: intakeAirTemp,
      engineDisplacementCc: engineDisplacementCc,
      ratio: ratio,
      trimTerm: trimTerm,
      volumetricEfficiency: volumetricEfficiency,
    );

    if (speed > 0) {
      return (_fuelFlow / speed) * 100;
    }
    return _fuelFlow; // l/h gdy stoimy
  }

  /// Pobierz ilość zużytego paliwa między wywołaniami komendy (w litrach)
  double fuelUsed() {
    if (_fuelFlow > 0) {
      return differenceMiliseconds * _fuelFlow / 3600000;
    }
    return 0;
  }

  /// Pobierz aktualny przepływ paliwa w l/h
  double get fuelFlow => _fuelFlow;
}
