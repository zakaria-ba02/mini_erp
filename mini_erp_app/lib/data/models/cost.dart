class AdditionalCost {
  const AdditionalCost({
    required this.name,
    required this.price,
  });

  final String name;
  final num price;

  factory AdditionalCost.fromJson(Map<String, dynamic> json) {
    return AdditionalCost(
      name: json['name']?.toString() ?? '',
      price: json['price'] as num? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
      };
}

/// Cost catalog entry — fields from live NestJS responses + OpenAPI CreateCostDto.
class Cost {
  const Cost({
    required this.id,
    required this.name,
    required this.runtime,
    required this.hourlyRate,
    required this.boardPrice,
    required this.quantity,
    required this.wastePercentage,
    required this.profitPercentage,
    required this.additionalCosts,
    this.operatingCost,
    this.additionalCostsTotal,
    this.wasteCost,
    this.totalCost,
    this.costPerUnit,
    this.profit,
    this.sellingPrice,
    this.sellingPricePerUnit,
    this.woodCostPerUnit,
    this.laserCostPerUnit,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final num runtime;
  final num hourlyRate;
  final num boardPrice;
  final num quantity;
  final num wastePercentage;
  final num profitPercentage;
  final List<AdditionalCost> additionalCosts;

  // Calculated (server-side)
  final num? operatingCost;
  final num? additionalCostsTotal;
  final num? wasteCost;
  final num? totalCost;
  final num? costPerUnit;
  final num? profit;
  final num? sellingPrice;
  final num? sellingPricePerUnit;
  final num? woodCostPerUnit;
  final num? laserCostPerUnit;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Cost.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'])?.toString();
    if (id == null || id.isEmpty) {
      throw const FormatException('Cost missing _id');
    }

    final extras = <AdditionalCost>[];
    final rawExtras = json['additionalCosts'];
    if (rawExtras is List) {
      for (final item in rawExtras) {
        if (item is Map) {
          extras.add(AdditionalCost.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return Cost(
      id: id,
      name: json['name']?.toString() ?? '',
      runtime: json['runtime'] as num? ?? 0,
      hourlyRate: json['hourlyRate'] as num? ?? 0,
      boardPrice: json['boardPrice'] as num? ?? 0,
      quantity: json['quantity'] as num? ?? 0,
      wastePercentage: json['wastePercentage'] as num? ?? 0,
      profitPercentage: json['profitPercentage'] as num? ?? 0,
      additionalCosts: extras,
      operatingCost: json['operatingCost'] as num?,
      additionalCostsTotal: json['additionalCostsTotal'] as num?,
      wasteCost: json['wasteCost'] as num?,
      totalCost: json['totalCost'] as num?,
      costPerUnit: json['costPerUnit'] as num?,
      profit: json['profit'] as num?,
      sellingPrice: json['sellingPrice'] as num?,
      sellingPricePerUnit: json['sellingPricePerUnit'] as num?,
      woodCostPerUnit: json['woodCostPerUnit'] as num?,
      laserCostPerUnit: json['laserCostPerUnit'] as num?,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

/// OpenAPI: CreateCostDto / UpdateCostDto body.
class UpsertCostRequest {
  const UpsertCostRequest({
    required this.name,
    required this.runtime,
    required this.hourlyRate,
    required this.boardPrice,
    required this.quantity,
    required this.wastePercentage,
    required this.profitPercentage,
    this.additionalCosts = const [],
  });

  final String name;
  final num runtime;
  final num hourlyRate;
  final num boardPrice;
  final num quantity;
  final num wastePercentage;
  final num profitPercentage;
  final List<AdditionalCost> additionalCosts;

  Map<String, dynamic> toJson() => {
        'name': name,
        'runtime': runtime,
        'hourlyRate': hourlyRate,
        'boardPrice': boardPrice,
        'quantity': quantity,
        'wastePercentage': wastePercentage,
        'profitPercentage': profitPercentage,
        'additionalCosts':
            additionalCosts.map((e) => e.toJson()).toList(growable: false),
      };
}
