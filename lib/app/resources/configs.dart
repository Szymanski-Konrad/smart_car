import 'package:flutter_background/flutter_background.dart';

abstract class Configs {
  static const backgroundConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: 'Jestem połączony :)',
    notificationText: 'Jedź, a ja się wszystkim zajmę :)',
    notificationIcon: AndroidResource(name: 'background_icon'),
    notificationImportance: AndroidNotificationImportance.Default,
    enableWifiLock: false,
  );
}
