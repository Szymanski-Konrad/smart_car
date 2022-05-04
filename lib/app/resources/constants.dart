abstract class Constants {
  static const minGpsDistance = 50; // m
  static const historyDataLength = 20; // number of history data to show
  static const tileHeight = 100.0;
  static const infoTileHeight = 80.0;
  static const infoTileWidthFactor = 0.48;
  static const largeInfoTileWidthFactor = 0.31;
  static const rapidBreaking = -11; // braking in km/h
  static const rapidAcceleration = 11; // acceleration in km/h
  static const minRapidSpeedTimeThreshold = 30; // s
  static const minModuleVoltage = 13.3;
  static const idleSpeedLimit = 0;
  static const defaultLocalFile = 'work';
  static const largeScreenWidth = 400.0;
  static const autoAssignStationMaxDistanceKM = 0.1;
  static const radToDegree = 57.2957795;
  static const showChangeSeconds = 5;
  static const upperRPMLimit = 3000;
  static const lowerRPMLimit = 1000;

  static const localFiles = [
    'work',
    'long-drive',
    'gizycko-kolno',
    'nowiak-mikolajki',
    'nowiak-lomza',
    'lomza-kolno',
    'passat1',
    'passat2',
    'passat3',
    'passat4',
    'passat5',
    'toyota1',
    'toyota2',
    'toyota3',
  ];
}

abstract class Durations {
  static const maxNoDataReciveSeconds = 3;
  static const closingTripDuration = Duration(seconds: 5);
}
