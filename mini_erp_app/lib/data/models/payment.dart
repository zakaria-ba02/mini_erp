import 'app_currency.dart';

class Payment {
  const Payment({
    required this.id,
    required this.customerId,
    this.customerName,
    this.customerPhone,
    required this.amount,
    required this.date,
    required this.method,
    this.currency = AppCurrency.syp,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String customerId;
  final String? customerName;
  final String? customerPhone;
  final num amount;
  final DateTime date;
  final String method;
  final AppCurrency currency;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Payment.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'])?.toString();
    if (id == null || id.isEmpty) {
      throw const FormatException('Payment missing _id');
    }

    String customerId = '';
    String? customerName;
    String? customerPhone;
    final rawCustomer = json['customerId'];
    if (rawCustomer is String) {
      customerId = rawCustomer;
    } else if (rawCustomer is Map) {
      final map = Map<String, dynamic>.from(rawCustomer);
      customerId = (map['_id'] ?? map['id'])?.toString() ?? '';
      customerName = map['name']?.toString();
      customerPhone = map['phone']?.toString();
    }

    return Payment(
      id: id,
      customerId: customerId,
      customerName: customerName ?? json['customerName']?.toString(),
      customerPhone: customerPhone,
      amount: json['amount'] as num? ?? 0,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      method: json['method']?.toString() ?? '',
      currency: AppCurrency.fromString(json['currency']?.toString()),
      notes: json['notes']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}

class UpsertPaymentRequest {
  const UpsertPaymentRequest({
    required this.customerId,
    required this.amount,
    required this.date,
    required this.method,
    required this.currency,
    this.notes,
  });

  final String customerId;
  final num amount;
  final DateTime date;
  final String method;
  final AppCurrency currency;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'amount': amount,
        'date': date.toUtc().toIso8601String(),
        'method': method,
        'currency': currency.apiValue,
        if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
      };
}

/// Common payment methods used in UI (free-text API field).
class PaymentMethods {
  PaymentMethods._();

  static const cash = 'cash';
  static const bankTransfer = 'bank_transfer';
  static const card = 'card';
  static const other = 'other';

  static const List<String> all = [cash, bankTransfer, card, other];

  static String labelAr(String method) => switch (method) {
        cash => 'نقدي',
        bankTransfer => 'تحويل بنكي',
        card => 'بطاقة',
        other => 'أخرى',
        _ => method,
      };
}
