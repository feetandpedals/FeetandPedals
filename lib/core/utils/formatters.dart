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

/// Live-verified against `GET https://feetandpedals.com/api/events`:
/// `start_date`/`end_date` come back as `"Sep 30, 2026"` (`MMM d, yyyy`),
/// not ISO 8601 — while the mock catalog (and possibly other endpoints,
/// unconfirmed) use ISO 8601. Tries both rather than assuming one.
final List<DateFormat> _apiDateFormats = [
  DateFormat('MMM d, yyyy'),
  DateFormat('MMM d, yyyy HH:mm'),
];

DateTime? parseApiDate(String? value) {
  if (value == null || value.isEmpty) return null;
  final iso = DateTime.tryParse(value);
  if (iso != null) return iso;
  for (final format in _apiDateFormats) {
    try {
      return format.parseStrict(value);
    } on FormatException {
      continue;
    }
  }
  return null;
}
