import 'app_currency.dart';

class Settlement {
  const Settlement({
    required this.id,
    required this.customerId,
    required this.currency,
    required this.totalInvoices,
    required this.totalPayments,
    required this.balanceAtSettlement,
    this.settledBy,
    this.createdAt,
  });

  final String id;
  final String customerId;
  final AppCurrency currency;
  final num totalInvoices;
  final num totalPayments;
  final num balanceAtSettlement;
  final String? settledBy;
  final DateTime? createdAt;

  factory Settlement.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'])?.toString();
    if (id == null || id.isEmpty) {
      throw const FormatException('Settlement missing _id');
    }

    String customerId = '';
    final rawCustomer = json['customerId'];
    if (rawCustomer is String) {
      customerId = rawCustomer;
    } else if (rawCustomer is Map) {
      final map = Map<String, dynamic>.from(rawCustomer);
      customerId = (map['_id'] ?? map['id'])?.toString() ?? '';
    }

    return Settlement(
      id: id,
      customerId: customerId,
      currency: AppCurrency.fromString(json['currency']?.toString()),
      totalInvoices: json['totalInvoices'] as num? ?? 0,
      totalPayments: json['totalPayments'] as num? ?? 0,
      balanceAtSettlement: json['balanceAtSettlement'] as num? ?? 0,
      settledBy: json['settledBy']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
