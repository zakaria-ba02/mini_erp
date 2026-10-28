class PageMeta {
  const PageMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory PageMeta.fromJson(Map<String, dynamic> json) {
    return PageMeta(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
    );
  }
}

class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.data,
    required this.meta,
  });

  final List<T> data;
  final PageMeta meta;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) mapper,
  ) {
    final raw = json['data'];
    final items = <T>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          items.add(mapper(item));
        } else if (item is Map) {
          items.add(mapper(Map<String, dynamic>.from(item)));
        }
      }
    }
    final metaRaw = json['meta'];
    final meta = metaRaw is Map
        ? PageMeta.fromJson(Map<String, dynamic>.from(metaRaw))
        : const PageMeta(page: 1, limit: 20, total: 0, totalPages: 0);
    return PaginatedResponse(data: items, meta: meta);
  }
}
