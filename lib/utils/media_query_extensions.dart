import 'package:flutter/cupertino.dart';
import 'package:smart_car/app/resources/constants.dart';

extension MediaQueryDataExtensions on MediaQueryData {
  bool get isLarge => size.width > Constants.largeScreenWidth;
}
