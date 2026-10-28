import 'app_currency.dart';

class CustomerBalances {
  const CustomerBalances({this.syp = 0, this.usd = 0});

  final num syp;
  final num usd;

  factory CustomerBalances.fromJson(Map<String, dynamic>? json, {num legacy = 0}) {
    if (json == null) {
      return CustomerBalances(syp: legacy, usd: 0);
    }
    return CustomerBalances(
      syp: json['SYP'] as num? ?? json['syp'] as num? ?? legacy,
      usd: json['USD'] as num? ?? json['usd'] as num? ?? 0,
    );
  }

  num forCurrency(AppCurrency currency) => switch (currency) {
        AppCurrency.syp => syp,
        AppCurrency.usd => usd,
      };
}

/// Customer entity as returned by NestJS (list / get / nested create).
class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.notes,
    this.balances = const CustomerBalances(),
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String phone;
  final String? notes;
  final CustomerBalances balances;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Customer.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'])?.toString();
    if (id == null || id.isEmpty) {
      throw const FormatException('Customer missing _id');
    }
    final balancesRaw = json['balances'];
    return Customer(
      id: id,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      notes: json['notes']?.toString(),
      balances: CustomerBalances.fromJson(
        balancesRaw is Map ? Map<String, dynamic>.from(balancesRaw) : null,
        legacy: json['balance'] as num? ?? 0,
      ),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  Customer copyWith({
    String? name,
    String? phone,
    String? notes,
    CustomerBalances? balances,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      balances: balances ?? this.balances,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
