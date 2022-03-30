import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_car/models/settings.dart';

const kSettings = 'settings';
const kLastFuelLvl = 'lastFuelLvl';

@immutable
abstract class Storage {
  static Future updateSettings(String settings) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(kSettings, settings);
  }

  static Future updateFuelPrice(double price) async {
    final settingsJson = await getSettingsJson();

    final settings = settingsJson != null
        ? Settings.fromJson(jsonDecode(settingsJson))
        : Settings();
    final newSettings = settings.copyWith(fuelPrice: price);
    await updateSettings(jsonEncode(newSettings));
  }

  static Future<String?> getSettingsJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kSettings);
  }

  static Future<void> updateLastFuelLvl(double value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(kLastFuelLvl, value);
  }

  static Future<double?> getLastFuelLvl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(kLastFuelLvl);
  }
}
