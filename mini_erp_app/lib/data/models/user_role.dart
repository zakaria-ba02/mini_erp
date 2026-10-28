/// User role from JWT payload — matches backend: "admin" | "customer".
enum UserRole {
  admin,
  customer;

  static UserRole? fromString(String? value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'customer':
        return UserRole.customer;
      default:
        return null;
    }
  }

  String get apiValue => name;
}
