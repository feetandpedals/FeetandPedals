import 'package:intl/intl.dart';

/// Feet and Pedals MVP1 targets the India market: INR pricing throughout.
/// Swap the locale/symbol here once the real feetandpedals.com market
/// configuration is confirmed via its API.
final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

String formatCurrency(num amount) => _currencyFormat.format(amount);

String formatCurrencyOrFree(num amount) => amount <= 0 ? 'Free' : formatCurrency(amount);

final DateFormat _dayMonth = DateFormat('d MMM yyyy');
final DateFormat _dayMonthShort = DateFormat('EEE, d MMM');
final DateFormat _time = DateFormat('h:mm a');

String formatEventDate(DateTime? date) => date == null ? '' : _dayMonth.format(date);
String formatEventDateShort(DateTime? date) => date == null ? '' : _dayMonthShort.format(date);
String formatEventTime(DateTime? date) => date == null ? '' : _time.format(date);
