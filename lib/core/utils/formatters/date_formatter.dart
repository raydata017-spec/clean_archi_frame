import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatToDMY(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}
