import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String toShortDate() {
    return DateFormat('yyyy-MM-dd').format(this);
  }
}
