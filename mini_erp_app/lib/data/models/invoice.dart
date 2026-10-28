import 'app_currency.dart';

enum InvoiceStatus {
  unpaid,
  partial,
  paid;

  static InvoiceStatus? fromString(String? value) {
    switch (value) {
      case 'unpaid':
        return InvoiceStatus.unpaid;
      case 'partial':
        return InvoiceStatus.partial;
      case 'paid':
        return InvoiceStatus.paid;
      default:
        return null;
    }
  }

  String get apiValue => name;

  String get labelAr => switch (this) {
        InvoiceStatus.unpaid => 'غير مدفوعة',
        InvoiceStatus.partial => 'مدفوعة جزئيًا',
        InvoiceStatus.paid => 'مدفوعة',
      };
}

class InvoiceItem {
  const InvoiceItem({
    this.costId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.lineTotal,
  });

  final String? costId;
  final String name;
  final num quantity;
  final num unitPrice;
  final num? lineTotal;

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      costId: json['costId']?.toString(),
      name: json['name']?.toString() ?? '',
      quantity: json['quantity'] as num? ?? 0,
      unitPrice: json['unitPrice'] as num? ?? 0,
      lineTotal: json['lineTotal'] as num?,
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      if (costId != null && costId!.isNotEmpty) 'costId': costId,
      if (costId == null || costId!.isEmpty) 'name': name,
      // When costId is set, name is optional (resolved server-side),
      // but sending name is fine for display consistency on edit reload.
      if (costId != null && costId!.isNotEmpty && name.isNotEmpty) 'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}

class Invoice {
  const Invoice({
    required this.id,
    required this.customerId,
    this.customerName,
    this.customerPhone,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
    this.currency = AppCurrency.syp,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String customerId;
  final String? customerName;
  final String? customerPhone;
  final DateTime date;
  final List<InvoiceItem> items;
  final num total;
  final InvoiceStatus status;
  final AppCurrency currency;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'])?.toString();
    if (id == null || id.isEmpty) {
      throw const FormatException('Invoice missing _id');
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

    final items = <InvoiceItem>[];
    final rawItems = json['items'];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          items.add(InvoiceItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final status =
        InvoiceStatus.fromString(json['status']?.toString()) ??
            InvoiceStatus.unpaid;

    return Invoice(
      id: id,
      customerId: customerId,
      customerName: customerName ?? json['customerName']?.toString(),
      customerPhone: customerPhone,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      items: items,
      total: json['total'] as num? ?? 0,
      status: status,
      currency: AppCurrency.fromString(json['currency']?.toString()),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }
}

class CreateInvoiceRequest {
  const CreateInvoiceRequest({
    required this.customerId,
    required this.date,
    required this.items,
    required this.currency,
  });

  final String customerId;
  final DateTime date;
  final List<InvoiceItem> items;
  final AppCurrency currency;

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'date': date.toUtc().toIso8601String(),
        'items': items.map((e) => e.toRequestJson()).toList(growable: false),
        'currency': currency.apiValue,
      };
}

class UpdateInvoiceRequest {
  const UpdateInvoiceRequest({
    this.customerId,
    this.date,
    this.items,
    this.currency,
  });

  final String? customerId;
  final DateTime? date;
  final List<InvoiceItem>? items;
  final AppCurrency? currency;

  Map<String, dynamic> toJson() => {
        if (customerId != null) 'customerId': customerId,
        if (date != null) 'date': date!.toUtc().toIso8601String(),
        if (items != null)
          'items': items!.map((e) => e.toRequestJson()).toList(growable: false),
        if (currency != null) 'currency': currency!.apiValue,
      };
}
