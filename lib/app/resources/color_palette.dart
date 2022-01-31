import 'package:flutter/cupertino.dart';

@immutable
abstract class ColorPalette {
  const ColorPalette._();

  static const normal = Color(0xFF406E8E);
  static const warning = Color(0xFFEF8354);
  static const danger = Color(0xFFDF3B57);
}
