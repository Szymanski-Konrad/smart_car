import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kSettings = 'settings';

@immutable
abstract class Storage {
  static Future updateSettings(String settings) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(kSettings, settings);
  }

  static Future<String?> getSettingsJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kSettings);
  }
}
