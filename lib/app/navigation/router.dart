import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_car/app/navigation/routes.dart';
import 'package:smart_car/app.dart';
import 'package:smart_car/pages/device_search/ui/bonded_devices_page.dart';
import 'package:smart_car/pages/live_data/ui/live_data_page.dart';
import 'package:smart_car/pages/settings/ui/settings_page.dart';

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
      default:
        return const App();
    }
  }
}
