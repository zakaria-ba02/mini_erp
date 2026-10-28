/// Flexible audit log entry — fields vary; parse what's present from API.
class AuditLog {
  const AuditLog({
    required this.id,
    this.action,
    this.entity,
    this.entityId,
    this.userId,
    this.username,
    this.details,
    this.createdAt,
    this.raw,
  });

  final String id;
  final String? action;
  final String? entity;
  final String? entityId;
  final String? userId;
  final String? username;
  final String? details;
  final DateTime? createdAt;
  final Map<String, dynamic>? raw;

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'])?.toString() ?? '';

    String? username;
    String? userId;
    final rawUser = json['user'] ?? json['userId'];
    if (rawUser is String) {
      userId = rawUser;
    } else if (rawUser is Map) {
      final map = Map<String, dynamic>.from(rawUser);
      userId = (map['_id'] ?? map['id'] ?? map['uid'])?.toString();
      username = map['username']?.toString() ?? map['name']?.toString();
    }
    username ??= json['username']?.toString();
    userId ??= json['userId']?.toString();

    final entity = (json['entity'] ?? json['entityType'] ?? json['resource'])
        ?.toString();
    final entityId =
        (json['entityId'] ?? json['resourceId'] ?? json['targetId'])
            ?.toString();
    final action =
        (json['action'] ?? json['operation'] ?? json['type'])?.toString();

    String? details;
    final meta = json['details'] ??
        json['changes'] ??
        json['metadata'] ??
        json['diff'] ??
        json['payload'];
    if (meta is String) {
      details = meta;
    } else if (meta != null) {
      details = meta.toString();
    }

    return AuditLog(
      id: id.isEmpty ? UniqueKeyFallback.from(json) : id,
      action: action,
      entity: entity,
      entityId: entityId,
      userId: userId,
      username: username,
      details: details,
      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? json['timestamp'] ?? json['date'])?.toString() ??
            '',
      ),
      raw: json,
    );
  }

  String get actionLabelAr {
    switch (action?.toLowerCase()) {
      case 'create':
      case 'created':
        return 'إنشاء';
      case 'update':
      case 'updated':
      case 'patch':
        return 'تعديل';
      case 'delete':
      case 'deleted':
      case 'remove':
        return 'حذف';
      case 'login':
        return 'تسجيل دخول';
      case 'logout':
        return 'تسجيل خروج';
      case 'reset_password':
      case 'reset-password':
        return 'إعادة تعيين كلمة السر';
      default:
        return action ?? 'عملية';
    }
  }

  String get entityLabelAr {
    switch (entity) {
      case 'Customer':
      case 'customer':
        return 'زبون';
      case 'Invoice':
      case 'invoice':
        return 'فاتورة';
      case 'Payment':
      case 'payment':
        return 'دفعة';
      case 'Cost':
      case 'cost':
      case 'Costing':
        return 'تكليف';
      case 'User':
      case 'user':
        return 'مستخدم';
      default:
        return entity ?? '—';
    }
  }
}

/// Fallback id when backend omits `_id` (should be rare).
class UniqueKeyFallback {
  UniqueKeyFallback._();

  static String from(Map<String, dynamic> json) {
    return 'anon-${json.hashCode}-${DateTime.now().microsecondsSinceEpoch}';
  }
}

/// Common entity filter values matching Postman example (`Invoice`).
class AuditEntities {
  AuditEntities._();

  static const values = <String>[
    'Customer',
    'Cost',
    'Invoice',
    'Payment',
    'User',
  ];
}
