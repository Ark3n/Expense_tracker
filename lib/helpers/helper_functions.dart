/*
there are some helpful functions across the app
*/

// convert string to double
import 'package:intl/intl.dart';

double convertStringToDouble(String string) {
  double? amount = double.tryParse(string);
  return amount ?? 0;
}

// format double amount into dollars and cents
String formatAmount(double amount) {
  final format =
      NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);
  return format.format(amount);
}
