import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../controller/auth_controller.dart';
import '../data/models/user_role.dart';
import 'app_routes.dart';

/// Blocks routes that don't match the signed-in role.
class RoleMiddleware extends GetMiddleware {
  RoleMiddleware(this.requiredRole);

  final UserRole requiredRole;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) {
      return const RouteSettings(name: AppRoutes.login);
    }

    final auth = Get.find<AuthController>();
    final role = auth.role;
    if (role == null) {
      return const RouteSettings(name: AppRoutes.login);
    }
    if (role != requiredRole) {
      return RouteSettings(name: auth.homeRouteForRole(role));
    }
    return null;
  }
}
