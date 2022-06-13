import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_car/app/navigation/routes.dart';
import 'package:smart_car/app.dart';
import 'package:smart_car/pages/create_fuel_log/ui/create_fuel_log_page.dart';
import 'package:smart_car/pages/device_search/ui/bonded_devices_page.dart';
import 'package:smart_car/pages/fuel_logs/ui/fuel_logs_page.dart';
import 'package:smart_car/pages/fuel_stations/ui/fuel_stations_page.dart';
import 'package:smart_car/pages/learning/ui/learning_page.dart';
import 'package:smart_car/pages/live_data/ui/live_data_page.dart';
import 'package:smart_car/pages/machine_learning/ui/dataset_page.dart';
import 'package:smart_car/pages/settings/ui/settings_page.dart';
import 'package:smart_car/pages/station_details/ui/station_details_page.dart';
import 'package:smart_car/pages/trip_summary/ui/trip_summary_page.dart';

abstract class AppRouter {
  const AppRouter._();

  static Route<Object>? generate(RouteSettings settings) {
    return Platform.isIOS
        ? CupertinoPageRoute(
            builder: (_) => settings.page,
            settings: settings,
          )
        : MaterialPageRoute(
            builder: (_) => settings.page,
            settings: settings,
          );
  }
}

extension on RouteSettings {
  Widget get page {
    switch (name) {
      case SharedRoutes.liveData:
        return const LiveDataPage();
      case SharedRoutes.selectBoundedDevice:
        return const SelectBondedDevicePage();
      case SharedRoutes.settings:
        return const SettingsPage();
      case SharedRoutes.fuelLogs:
        return const FuelLogsPage();
      case SharedRoutes.createFuelLog:
        return const CreateFuelLogPage();
      case SharedRoutes.fuelStations:
        return const FuelStationsPage();
      case SharedRoutes.stationDetails:
        return const StationDetailsPage();
      case SharedRoutes.tripSummary:
        return const TripSummaryPage();
      case SharedRoutes.machineLearning:
        return const DatasetPage();
      case SharedRoutes.learning:
        return const LearningPage();
      default:
        return const App();
    }
  }
}
