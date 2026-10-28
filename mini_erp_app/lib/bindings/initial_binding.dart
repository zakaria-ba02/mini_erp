import 'package:get/get.dart';

import '../controller/auth_controller.dart';
import '../controller/theme_controller.dart';
import '../data/providers/auth_provider.dart';
import '../data/providers/users_provider.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/users_repository.dart';
import '../utils/notifications/notification_service.dart';
import '../utils/storage/secure_storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SecureStorageService>(SecureStorageService(), permanent: true);
    Get.put<ThemeController>(ThemeController(), permanent: true);

    Get.put<AuthProvider>(AuthProvider(), permanent: true);
    Get.put<AuthRepository>(
      AuthRepository(
        provider: Get.find<AuthProvider>(),
        storage: Get.find<SecureStorageService>(),
      ),
      permanent: true,
    );
    Get.put<UsersProvider>(UsersProvider(), permanent: true);
    Get.put<UsersRepository>(
      UsersRepository(Get.find<UsersProvider>()),
      permanent: true,
    );
    Get.put<AuthController>(
      AuthController(Get.find<AuthRepository>()),
      permanent: true,
    );

    if (Get.isRegistered<NotificationService>()) {
      Get.find<NotificationService>()
          .attachUsersRepository(Get.find<UsersRepository>());
    }
  }
}
