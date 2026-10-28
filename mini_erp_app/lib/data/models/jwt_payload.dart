import 'user_role.dart';

/// JWT payload shape confirmed from backend testing:
/// `{ uid, role: "admin"|"customer", customerId? }`
class JwtPayload {
  const JwtPayload({
    required this.uid,
    required this.role,
    this.customerId,
  });

  final String uid;
  final UserRole role;
  final String? customerId;

  factory JwtPayload.fromMap(Map<String, dynamic> map) {
    final role = UserRole.fromString(map['role']?.toString());
    if (role == null) {
      throw FormatException('Unknown role in JWT: ${map['role']}');
    }
    final uid = (map['uid'] ?? map['userId'])?.toString();
    if (uid == null || uid.isEmpty) {
      throw const FormatException('Missing uid in JWT');
    }
    return JwtPayload(
      uid: uid,
      role: role,
      customerId: map['customerId']?.toString(),
    );
  }
}
