import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String formatMMK(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: 'MMK ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
