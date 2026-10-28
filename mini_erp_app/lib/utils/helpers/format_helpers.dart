import 'package:intl/intl.dart';

import '../../data/models/app_currency.dart';

class FormatHelpers {
  FormatHelpers._();

  /// Arabic locale for display (Eastern Arabic numerals + RTL-friendly grouping).
  static final _money = NumberFormat('#,##0.##', 'ar');
  static final _date = DateFormat('yyyy/MM/dd', 'ar');
  static final _dateTime = DateFormat('yyyy/MM/dd HH:mm', 'ar');

  /// ASCII digits for TextField / API payloads (LTR-friendly).
  static final _moneyAscii = NumberFormat('#,##0.##', 'en');

  static String money(num? value) => _money.format(value ?? 0);

  static String moneyWithCurrency(num? value, AppCurrency currency) =>
      '${money(value)} ${currency.labelAr}';

  static String moneyAscii(num? value) => _moneyAscii.format(value ?? 0);

  static String date(DateTime? value) {
    if (value == null) return '—';
    return _date.format(value.toLocal());
  }

  static String dateTime(DateTime? value) {
    if (value == null) return '—';
    return _dateTime.format(value.toLocal());
  }
}

