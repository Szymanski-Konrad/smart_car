abstract class Strings {
  /// General
  static const String promptCharacter = '>';

  /// Main page
  static const String bluetooth = 'Bluetooth';
  static const String enableBluetooth = 'Włącz Bluetooth';
  static const String obdSection = 'OBD II';
  static const String fuelSection = 'Paliwo';
  static const String connectToObd = 'Połącz z OBD II';
  static const String firstlyChooseDevice =
      'Najpierw przejdź do ustawień, aby wybrać urządzenia do połączenia';
  static const String localMode = 'Tryb lokalny';
  static const String settings = 'Ustawienia';
  static String sendSavedTrips(int count) =>
      'Wyślij $count zapisanych przejazdów';
  static const String fuelLogs = 'Dziennik tankowań';
  static const String fuelStations = 'Stacje paliw';

  /// Live data
  static const String cannotConnect =
      'Nie można połączyć. Urządzenie jest zajęte lub nie odpowiada';
  static String progress(double percent) =>
      'Progres: ${percent.toStringAsFixed(2)} %';
  static const String connecting = 'Trwa łączenie...';
  static const String connected = 'Połączono! :D';
  static String filesInDirectory(int count) => 'Zapisane przejazdy: $count';
  static const String sendFiles = 'Wyślij pliki';
  static const String liveData = 'Dane z czujników';
  static const String tripStats = 'Statystki przejazdu';
  static String pedalPressed(bool isPressed) =>
      isPressed ? 'Gaz wciśnięty' : 'Gaz puszczony';
  static String avgResponse(int time) => 'Śr. czas: $time ms';
  static String totalResponse(int time) => 'Łączny czas: $time ms';
  static const String loadingPids = 'Wyszukiwanie dostępnych czujników...';
  static const String indoorTemp = 'Temperatura wewnątrz';
  static String supportedCommandsCount(int selected, int total) =>
      'Dostępne czujniki: $selected/$total';
  static const String noDescription = 'brak opisu';
  static const String roadTilt = 'Nachylenie';
  static const String gForce = 'Przeciążenie';
  static const String fuelSystemStatus = 'Układ paliwowy';

  /// Settings
  static const String noSelectedDevice = 'Nie wybranego urządzenia';
  static const String noName = 'Brak nazwy';
  static const String settingsSaved = 'Ustawenia zapisane';
  static const String selectDefaultDevice =
      'Wybierz domyślne urządzenie OBD II';
  static const String selectedDevice = 'Wybrane urządzenie';
  static const String selectFile = 'Wybierz plik';
  static const String engineCapacity = 'Pojemność silnika';
  static const String fuelPrice = 'Cena paliwa';
  static const String enginePower = 'Moc silnika';
  static const String tankCapacity = 'Pojemność baku';
  static const String fuelType = 'Rodzaj paliwa';

  /// Fuel system status
  static const String fuelSystemMotofOff = 'Silnik jest wyłączony';
  static const String fuelSystemInsufficientEngineTemp =
      'Silnik ma niską temperaturę. Jedź delikatnie';
  static const String fuelSystemGood =
      'Silnik ma optymalną temperaturę. Możesz jechać dynamicznie';
  static const String fuelSystemCut =
      'Silnik nie pobiera paliwa. Oszczędzasz paliwo i środowisko :) ';
  static const String fuelSystemFailure =
      'Coś jest nie tak z samochodem. Jedź ostrożnie i zgłoś się do mechanika';
  static const String fuelSystemOxygenSensorFailure =
      'Problem z sondą lambda. Skontaktuj się z mechanikiem';
  static const String fuelSystemUnknown = 'Nieznany stan systemu paliwowego';

  static const String fuelSystemMotofOffShort = 'Silnik wyłączony';
  static const String fuelSystemInsufficientEngineTempShort = 'Zimny';
  static const String fuelSystemGoodShort = 'Rozgrzany';
  static const String fuelSystemCutShort = 'Oszczędzanie';
  static const String fuelSystemFailureShort = 'Nieznany problem';
  static const String fuelSystemOxygenSensorFailureShort =
      'Problem z sondą lambda';
  static const String fuelSystemUnknownShort = 'Nieznany stan';

  /// Trip record
  static const String fuelCosts = 'Cena paliwa';
  static const String savedFuel = 'Zaoszczędzone paliwo';
  static const String usedFuel = 'Zużyte paliwo';
  static const String idleUsedFuel = 'Postojowe paliwo';
  static const String distance = 'Dystans';
  static const String instantFuelConsumption = 'Chwilowe spalanie';
  static const String averageFuelConsumption = 'Śr. spalanie';
  static const String range = 'Zasięg';
  static const String gpsSpeed = 'Prędkość GPS';
  static const String gpsDistance = 'Dystans GPS';
  static const String totalDuration = 'Czas';
  static const String driveDuration = 'Czas jazdy';
  static const String idleDuration = 'Czas postoju';
  static const String averageSpeed = 'Śr. prędkość';
  static const String rapidAcceleration = 'Przysp.';
  static const String rapidBraking = 'Hamowania';
  static const String burntCO2 = 'Wyemitowane CO2';
  static const String savedCO2 = 'Uratowane CO2';
  static const String averageCO2 = 'Śr. CO2';

  // Fuel logs
  static const String addYourFirstLog = 'Dodaj swój pierwszy wpis';
  static String fuelLogsCounter(int number) {
    if (number == 1) return '$number tankowanie';
    if (number < 5) return '$number tankowania';
    return '$number tankowań';
  }

  // Fuel stations
  static const String gasStation = 'Stacja paliw';
}
