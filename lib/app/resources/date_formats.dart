import 'package:intl/intl.dart';

abstract class DateFormats {
  DateFormats._();

  static final dateFormat = DateFormat('dd-MM-yyyy');
  static final timeFormat = DateFormat('HH-mm');
}
