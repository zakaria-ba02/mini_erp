enum AppCurrency {
  syp,
  usd;

  String get apiValue => switch (this) {
        AppCurrency.syp => 'SYP',
        AppCurrency.usd => 'USD',
      };

  String get labelAr => switch (this) {
        AppCurrency.syp => 'ل.س',
        AppCurrency.usd => 'دولار',
      };

  /// Short spoken name used on buttons and titles.
  String get spokenAr => switch (this) {
        AppCurrency.syp => 'السوري',
        AppCurrency.usd => 'الدولار',
      };

  String get withPrefixAr => switch (this) {
        AppCurrency.syp => 'بالسوري',
        AppCurrency.usd => 'بالدولار',
      };

  String get fullLabelAr => spokenAr;

  String get accountAction => 'سجل حسابه $spokenAr';
  String get invoicesAction => 'فواتيره';
  String get paymentsAction => 'دفعاته';
  String get invoicesListTitle => 'فواتيره $withPrefixAr';
  String get paymentsListTitle => 'دفعاته $withPrefixAr';
  String get settleAction => 'تسوية حسابه $withPrefixAr';

  static AppCurrency fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'USD':
        return AppCurrency.usd;
      default:
        return AppCurrency.syp;
    }
  }
}
