import 'package:flutter/material.dart';

abstract class TextStyles {
  TextStyles._();

  static const valueTextStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
  );

  static const smallValueTextStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: Colors.orange,
  );

  static const descriptionTextStyle = TextStyle(
    fontSize: 16.0,
    fontStyle: FontStyle.italic,
  );
}
