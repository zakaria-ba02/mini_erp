import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../data/models/user_role.dart';
import '../../data/repositories/users_repository.dart';
import '../../firebase_options.dart';
import '../../routes/app_routes.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (DefaultFirebaseOptions.isConfigured && Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

/// FCM + local foreground banners. Safe when Firebase is not configured yet.
class NotificationService extends GetxService {
  static const _androidChannelId = 'mini_erp_alerts';
  static const _androidChannelName = 'تنبيهات Mini ERP';

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  FirebaseMessaging? _messaging;
  UsersRepository? _usersRepository;
  bool _ready = false;
  Map<String, dynamic>? _pendingNavigation;

  bool get isReady => _ready;

  Future<NotificationService> init() async {
    if (!DefaultFirebaseOptions.isConfigured) {
      if (kDebugMode) {
        // ignore: avoid_print
        print(
          'FCM disabled: run `flutterfire configure`, add android/app/google-services.json, '
          'set DefaultFirebaseOptions.isConfigured = true.',
        );
      }
      return this;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      _messaging = FirebaseMessaging.instance;
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await _initLocalNotifications();
      await _requestPermission();

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

      final initial = await _messaging!.getInitialMessage();
      if (initial != null) {
        _pendingNavigation = Map<String, dynamic>.from(initial.data);
      }

      _messaging!.onTokenRefresh.listen(_syncToken);

      _ready = true;
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('FCM init failed (continuing without push): $e\n$st');
      }
      _ready = false;
    }
    return this;
  }

  void attachUsersRepository(UsersRepository repository) {
    _usersRepository = repository;
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          navigateFromData(data);
        } catch (_) {}
      },
    );

    const channel = AndroidNotificationChannel(
      _androidChannelId,
      _androidChannelName,
      description: 'إشعارات الفواتير والدفعات',
      importance: Importance.high,
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _requestPermission() async {
    await _messaging?.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Call after successful login / session restore.
  Future<void> syncTokenAfterAuth() async {
    if (!_ready || _messaging == null) return;
    try {
      final token = await _messaging!.getToken();
      if (token != null && token.isNotEmpty) {
        await _syncToken(token);
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Failed to get/sync FCM token: $e');
      }
    }
    consumePendingNavigation();
  }

  Future<void> _syncToken(String token) async {
    final repo = _usersRepository;
    if (repo == null) return;
    if (!Get.isRegistered<AuthController>()) return;
    if (!Get.find<AuthController>().isLoggedIn) return;

    try {
      await repo.updateFcmToken(token);
      if (kDebugMode) {
        // ignore: avoid_print
        print('FCM token synced to backend');
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('FCM token sync failed: $e');
      }
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'تنبيه جديد';
    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        'لديك تحديث جديد';

    await _local.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: 'إشعارات الفواتير والدفعات',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _onMessageOpened(RemoteMessage message) {
    navigateFromData(Map<String, dynamic>.from(message.data));
  }

  void consumePendingNavigation() {
    final pending = _pendingNavigation;
    if (pending == null) return;
    _pendingNavigation = null;
    Future<void>.delayed(const Duration(milliseconds: 350), () {
      navigateFromData(pending);
    });
  }

  void navigateFromData(Map<String, dynamic> data) {
    final type =
        (data['type'] ?? data['entity'] ?? data['target'] ?? '').toString();
    final id = (data['id'] ??
            data['invoiceId'] ??
            data['paymentId'] ??
            data['entityId'] ??
            '')
        .toString();

    if (id.isEmpty) return;

    final role = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>().role
        : null;

    final lower = type.toLowerCase();
    if (lower.contains('invoice') || lower.contains('فاتورة')) {
      if (role == UserRole.admin) {
        Get.toNamed(AppRoutes.invoiceDetails, arguments: id);
      } else {
        Get.toNamed(AppRoutes.customerInvoiceDetails, arguments: id);
      }
      return;
    }

    if (lower.contains('payment') || lower.contains('دفع')) {
      if (role == UserRole.admin) {
        Get.toNamed(AppRoutes.paymentDetails, arguments: id);
      } else {
        Get.toNamed(AppRoutes.customerPaymentDetails, arguments: id);
      }
    }
  }
}
