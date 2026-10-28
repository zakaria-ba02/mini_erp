import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'bindings/initial_binding.dart';
import 'controller/theme_controller.dart';
import 'routes/app_pages.dart';
import 'utils/constants/app_theme.dart';
import 'utils/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar');

  await Get.putAsync(() => NotificationService().init(), permanent: true);

  runApp(const MiniErpApp());
}

class MiniErpApp extends StatelessWidget {
  const MiniErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mini ERP',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialBinding: InitialBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      onInit: () {
        if (Get.isRegistered<ThemeController>()) {
          final mode = Get.find<ThemeController>().themeMode.value;
          Get.changeThemeMode(mode);
        }
      },
    );
  }
}
