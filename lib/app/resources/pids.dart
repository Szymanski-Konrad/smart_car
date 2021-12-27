// ignore_for_file: constant_identifier_names

abstract class Pids {
  // Unsupported pids
  static const String fuelPressure = '0A';
  static const String intakeManifoldAbsolutePressure = '0B';
  static const String timingAdvance = '0E';
  static const String commandedSecondaryAirStatus = '12';
  static const String oxygenSensorsPresents2B = '13';
  static const String oxygenSensor3A = '16';
  static const String oxygenSensor4A = '17';
  static const String oxygenSensor7A = '1A';
  static const String oxygenSensor8A = '1B';
  static const String obdStandards = '1C';
  static const String oxygenSensorsPresents4B = '1D';
  static const String auxiliaryInputStatus = '1E';
  static const String runTimeSinceStart = '1F';
  static const String distanceTraveledMIL = '21';
  static const String fuelRailPressure = '22';
  static const String fuelRailGaugePressure = '23';
  static const String oxygenSensor1B = '24';
  static const String oxygenSensor2B = '25';
  static const String oxygenSensor3B = '26';
  static const String oxygenSensor4B = '27';
  static const String oxygenSensor5B = '28';
  static const String oxygenSensor6B = '29';
  static const String oxygenSensor7B = '2A';
  static const String oxygenSensor8B = '2B';
  static const String commandedEGR = '2C';
  static const String egrError = '2D';
  static const String commandedEvaporativePurge = '2E';
  static const String warmUpsSinceCodeCleared = '30';
  static const String distanceTraveledSinceCodesCleared = '31';
  static const String evapSystemVaporPressure = '32';
  static const String absoluteBarometricPressure = '33';
  static const String oxygenSensor1C = '34';
  static const String oxygenSensor2C = '35';
  static const String oxygenSensor3C = '36';
  static const String oxygenSensor4C = '37';
  static const String oxygenSensor5C = '38';
  static const String oxygenSensor6C = '39';
  static const String oxygenSensor7C = '3A';
  static const String oxygenSensor8C = '3B';
  static const String catalystTemperatureB1S1 = '3C';
  static const String catalystTemperatureB2S1 = '3D';
  static const String catalystTemperatureB1S2 = '3E';
  static const String catalystTemperatureB2S2 = '3F';
  static const String monitorStatusDriveCycle = '41';
  static const String controlModuleVoltage = '42';
  static const String absoluteLoadValue = '43';
  static const String relativeThrottlePosition = '45';
  static const String ambientAirTemperature = '46';
  static const String absoluteThrottlePositionB = '47';
  static const String absoluteThrottlePositionC = '48';
  static const String acceleratorPedalPositionD = '49';
  static const String acceleratorPedalPositionE = '4A';
  static const String acceleratorPedalPositionF = '4B';
  static const String commanededThrottleAcutator = '4C';
  static const String timeRunWithMIL = '4D';
  static const String timeSinceTroubleCodesCleared = '4E';
  static const String fuelType = '51';
  static const String hybridBatteryPackRemainingLife = '5B';
  static const String fuelInjectionTiming = '5D';
  static const String engineFuelRate = '5E';
  static const String engineReferenceTorque = '63';
  static const String odometer = 'A6';

  // Supported pids
  static const String shortTermFTB1 = '06';
  static const String longTermFTB1 = '07';
  static const String shortTermFTB2 = '08';
  static const String longTermFTB2 = '09';
  static const String fuelSystemStatus = '03';
  static const String engineLoad = '04';
  static const String engineCoolant = '05';
  static const String rpm = '0C';
  static const String speed = '0D';
  static const String intakeAirTemp = '0F';
  static const String maf = '10';
  static const String throttlePosition = '11';
  static const String fuelLevel = '2F';
  static const String oilTemp = '5C';
  static const String commandedAirFuelRatio = '44';
  static const String oxygenSensor1A = '14';
  static const String oxygenSensor2A = '15';
  static const String oxygenSensor5A = '18';
  static const String oxygenSensor6A = '19';

  static const String pidsList1 = '00';
  static const String pidsList2 = '20';
  static const String pidsList3 = '40';
  static const String pidsList4 = '60';
  static const String pidsList5 = '80';
  static const String pidsList6 = 'A0';
  static const String pidsList7 = 'C0';
}

const List<String> initializeCommands = [
  'AT Z',
  'AT E0',
  'AT L0',
  'AT S0',
  'AT SP 0',
  'AT E0',
];

const List<String> checkPidsCommands = [
  '0100',
  '0120',
  '0140',
  '0160',
  '0180',
  '01A0',
  '01C0',
];

enum PID {
  engineCoolant,
  engineLoad,
  fuelLevel,
  intakeAirTemp,
  maf,
  oilTemp,
  rpm,
  speed,
  throttlePosition,
  fuelSystemStatus,
  commandedAirFuelRatio,
  oxygenSensor1A,
  oxygenSensor2A,
  oxygenSensor5A,
  oxygenSensor6A,
  STFTB1,
  LTFTB1,
  STFTB2,
  LTFTB2,
  unknown,
}

extension PIDExtension on PID {
  static PID code(String value) {
    switch (value) {
      case Pids.oxygenSensor1A:
        return PID.oxygenSensor1A;
      case Pids.oxygenSensor2A:
        return PID.oxygenSensor2A;
      case Pids.oxygenSensor5A:
        return PID.oxygenSensor5A;
      case Pids.oxygenSensor6A:
        return PID.oxygenSensor6A;
      case Pids.commandedAirFuelRatio:
        return PID.commandedAirFuelRatio;
      case Pids.shortTermFTB1:
        return PID.STFTB1;
      case Pids.longTermFTB1:
        return PID.LTFTB1;
      case Pids.shortTermFTB2:
        return PID.STFTB2;
      case Pids.longTermFTB2:
        return PID.LTFTB2;
      case Pids.engineCoolant:
        return PID.engineCoolant;
      case Pids.engineLoad:
        return PID.engineLoad;
      case Pids.fuelLevel:
        return PID.fuelLevel;
      case Pids.intakeAirTemp:
        return PID.intakeAirTemp;
      case Pids.maf:
        return PID.maf;
      case Pids.oilTemp:
        return PID.oilTemp;
      case Pids.rpm:
        return PID.rpm;
      case Pids.speed:
        return PID.speed;
      case Pids.throttlePosition:
        return PID.throttlePosition;
      case Pids.fuelSystemStatus:
        return PID.fuelSystemStatus;
      default:
        return PID.unknown;
    }
  }
}

enum SpecialPID {
  pidsList1,
  pidsList2,
  pidsList3,
  pidsList4,
  pidsList5,
  pidsList6,
  pidsList7,
  unknown,
}

extension SpecialPIDExtension on SpecialPID {
  static SpecialPID code(String value) {
    switch (value) {
      case Pids.pidsList1:
        return SpecialPID.pidsList1;
      case Pids.pidsList2:
        return SpecialPID.pidsList2;
      case Pids.pidsList3:
        return SpecialPID.pidsList3;
      case Pids.pidsList4:
        return SpecialPID.pidsList4;
      case Pids.pidsList5:
        return SpecialPID.pidsList5;
      case Pids.pidsList6:
        return SpecialPID.pidsList6;
      case Pids.pidsList7:
        return SpecialPID.pidsList7;
      default:
        return SpecialPID.unknown;
    }
  }
}

const Map<String, String> pidsDescription = {
  '00': 'Pids supported 01-20',
  '01':
      'Monitor status since DTCs cleared. (Includes malfunction indicator lamp (MIL) status and number of DTCs.)',
  '02': 'Freeze DTC',
  '03': 'Fuel system status',
  '04': 'Calculated engine load',
  '05': 'Engine coolant temperature',
  '06': 'Short term fuel trim—Bank 1',
  '07': 'Long term fuel trim—Bank 1',
  '08': 'Short term fuel trim—Bank 2',
  '09': 'Long term fuel trim—Bank 2',
  '0A': 'Fuel pressure (gauge pressure)',
  '0B': 'Intake manifold absolute pressure',
  '0C': 'Engine speed',
  '0D': 'Vehicle speed',
  '0E': 'Timing advance',
  '0F': 'Intake air temperature',
  '10': 'Mass air flow sensor (MAF) air flow rate',
  '11': 'Throttle position',
  '12': 'Commanded secondary air status',
  '13': 'Oxygen sensors present (in 2 banks)',
  '14': 'Oxygen Sensor 1',
  '15': 'Oxygen Sensor 2',
  '16': 'Oxygen Sensor 3',
  '17': 'Oxygen Sensor 4',
  '18': 'Oxygen Sensor 5',
  '19': 'Oxygen Sensor 6',
  '1A': 'Oxygen Sensor 7',
  '1B': 'Oxygen Sensor 8',
  '1C': 'OBD standards this vehicle conforms to',
  '1D': 'Oxygen sensors present (in 4 banks)',
  '1E': 'Auxiliary input status',
  '1F': 'Run time since engine start',
  '20': 'PIDs supported [21 - 40]',
  '21': 'Distance traveled with malfunction indicator lamp (MIL) on',
  '22': 'Fuel Rail Pressure (relative to manifold vacuum)',
  '23': 'Fuel Rail Gauge Pressure (diesel, or gasoline direct injection)',
  '24': 'Oxygen Sensor 1',
  '25': 'Oxygen Sensor 2',
  '26': 'Oxygen Sensor 3',
  '27': 'Oxygen Sensor 4',
  '28': 'Oxygen Sensor 5',
  '29': 'Oxygen Sensor 6',
  '2A': 'Oxygen Sensor 7',
  '2B': 'Oxygen Sensor 8',
  '2C': 'Commanded EGR',
  '2D': 'EGR Error',
  '2E': 'Commanded evaporative purge',
  '2F': 'Fuel Tank Level Input',
  '30': 'Warm-ups since codes cleared',
  '31': 'Distance traveled since codes cleared',
  '32': 'Evap. System Vapor Pressure',
  '33': 'Absolute Barometric Pressure',
  '34': 'Oxygen Sensor 1',
  '35': 'Oxygen Sensor 2',
  '36': 'Oxygen Sensor 3',
  '37': 'Oxygen Sensor 4',
  '38': 'Oxygen Sensor 5',
  '39': 'Oxygen Sensor 6',
  '3A': 'Oxygen Sensor 7',
  '3B': 'Oxygen Sensor 8',
  '3C': 'Catalyst Temperature: Bank 1, Sensor 1',
  '3D': 'Catalyst Temperature: Bank 2, Sensor 1',
  '3E': 'Catalyst Temperature: Bank 1, Sensor 2',
  '3F': 'Catalyst Temperature: Bank 2, Sensor 2',
  '40': 'PIDs supported [41 - 60]',
  '41': 'Monitor status this drive cycle',
  '42': 'Control module voltage',
  '43': 'Absolute load value',
  '44': 'Commanded Air-Fuel Equivalence Ratio (lambda,λ)',
  '45': 'Relative throttle position',
  '46': 'Ambient air temperature',
  '47': 'Absolute throttle position B',
  '48': 'Absolute throttle position C',
  '49': 'Accelerator pedal position D',
  '4A': 'Accelerator pedal position E',
  '4B': 'Accelerator pedal position F',
  '4C': 'Commanded throttle actuator',
  '4D': 'Time run with MIL on',
  '4E': 'Time since trouble codes cleared',
  '4F':
      'Maximum value for Fuel–Air equivalence ratio, oxygen sensor voltage, oxygen sensor current, and intake manifold absolute pressure',
  '50': 'Maximum value for air flow rate from mass air flow sensor',
  '51': 'Fuel Type',
  '52': 'Ethanol fuel %',
  '53': 'Absolute Evap system Vapor Pressure',
  '54': 'Evap system vapor pressure',
  '55': 'Short term secondary oxygen sensor trim, A: bank 1, B: bank 3',
  '56': 'Long term secondary oxygen sensor trim, A: bank 1, B: bank 3',
  '57': 'Short term secondary oxygen sensor trim, A: bank 2, B: bank 4',
  '58': 'Long term secondary oxygen sensor trim, A: bank 2, B: bank 4',
  '59': 'Fuel rail absolute pressure',
  '5A': 'Relative accelerator pedal position',
  '5B': 'Hybrid battery pack remaining life',
  '5C': 'Engine oil temperature',
  '5D': 'Fuel injection timing',
  '5E': 'Engine fuel rate',
  '5F': 'Emission requirements to which vehicle is designed',
  '60': 'PIDs supported [61 - 80]',
  '61': "Driver's demand engine - percent torque",
  '62': 'Actual engine - percent torque',
  '63': 'Engine reference torque',
  '64': 'Engine percent torque data',
  '65': 'Auxiliary input / output supported',
  '66': 'Mass air flow sensor',
  '67': 'Engine coolant temperature',
  '68': 'Intake air temperature sensor',
  '69': 'Actual EGR, Commanded EGR, and EGR Error',
  '6A':
      'Commanded Diesel intake air flow control and relative intake air flow position',
  '6B': 'Exhaust gas recirculation temperature',
  '6C': 'Commanded throttle actuator control and relative throttle position',
  '6D': 'Fuel pressure control system',
  '6E': 'Injection pressure control system',
  '6F': 'Turbocharger compressor inlet pressure',
  '70': 'Boost pressure control',
  '71': 'Variable Geometry turbo (VGT) control',
  '72': 'Wastegate control',
  '73': 'Exhaust pressure',
  '74': 'Turbocharger RPM',
  '75': 'Turbocharger temperature',
  '76': 'Turbocharger temperature',
  '77': 'Charge air cooler temperature (CACT)',
  '78': 'Exhaust Gas temperature (EGT) Bank 1',
  '79': 'Exhaust Gas temperature (EGT) Bank 2',
  '7A': 'Diesel particulate filter (DPF)',
  '7B': 'Diesel particulate filter (DPF)',
  '7C': 'Diesel Particulate filter (DPF) temperature',
  '7D': 'NOx NTE (Not-To-Exceed) control area status',
  '7E': 'PM NTE (Not-To-Exceed) control area status',
  '7F': 'Engine run time [b]',
  '80': 'PIDs supported [81 - A0]',
  '81': 'Engine run time for Auxiliary Emissions Control Device(AECD)',
  '82': 'Engine run time for Auxiliary Emissions Control Device(AECD)',
  '83': 'NOx sensor',
  '84': 'Manifold surface temperature',
  '85': 'NOx reagent system',
  '86': 'Particulate matter (PM) sensor',
  '87': 'Intake manifold absolute pressure',
  '88': 'SCR Induce System',
  '89': 'Run Time for AECD #11-#15',
  '8A': 'Run Time for AECD #16-#20',
  '8B': 'Diesel Aftertreatment',
  '8C': 'O2 Sensor (Wide Range)',
  '8D': 'Throttle Position G',
  '8E': 'Engine Friction - Percent Torque',
  '8F': 'PM Sensor Bank 1 & 2',
  '90': 'WWH-OBD Vehicle OBD System Information',
  '91': 'WWH-OBD Vehicle OBD System Information',
  '92': 'Fuel System Control',
  '93': 'WWH-OBD Vehicle OBD Counters support',
  '94': 'NOx Warning And Inducement System',
  '98': 'Exhaust Gas Temperature Sensor',
  '99': 'Exhaust Gas Temperature Sensor',
  '9A': 'Hybrid/EV Vehicle System Data, Battery, Voltage',
  '9B': 'Diesel Exhaust Fluid Sensor Data',
  '9C': 'O2 Sensor Data',
  '9D': 'Engine Fuel Rate',
  '9E': 'Engine Exhaust Flow Rate',
  '9F': 'Fuel System Percentage Use',
  'A0': 'PIDs supported [A1 - C0]',
  'A1': 'NOx Sensor Corrected Data',
  'A2': 'Cylinder Fuel Rate',
  'A3': 'Evap System Vapor Pressure',
  'A4': 'Transmission Actual Gear',
  'A5': 'Commanded Diesel Exhaust Fluid Dosing',
  'A6': 'Odometer [c]',
  'A7': 'NOx Sensor Concentration Sensors 3 and 4',
  'A8': 'NOx Sensor Corrected Concentration Sensors 3 and 4',
  'A9': 'ABS Disable Switch State',
  'C0': 'PIDs supported [C1 - E0]',
};
