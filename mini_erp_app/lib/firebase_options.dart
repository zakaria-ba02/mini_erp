// File generated for Mini ERP FCM.
// Values taken from android/app/google-services.json (Firebase Console).
// See docs/FIREBASE_SETUP.md

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  /// Set to `true` after replacing values via `flutterfire configure`.
  static const bool isConfigured = true;

  static FirebaseOptions get currentPlatform {
    if (!isConfigured) {
      throw UnsupportedError(
        'Firebase is not configured. Run `flutterfire configure` and set '
        'DefaultFirebaseOptions.isConfigured = true.',
      );
    }
    if (kIsWeb) {
      throw UnsupportedError('Web is not configured for Mini ERP FCM.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBS_S5KxGTbOizuCHeJEtpk8eF0EAPWvto',
    appId: '1:804088689471:android:e3e9d428a2ad949b91598a',
    messagingSenderId: '804088689471',
    projectId: 'mini-erp-d31bd',
    storageBucket: 'mini-erp-d31bd.firebasestorage.app',
  );

  // No iOS target in this project — placeholders keep the file compiling.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBS_S5KxGTbOizuCHeJEtpk8eF0EAPWvto',
    appId: '1:804088689471:ios:0000000000000000000000',
    messagingSenderId: '804088689471',
    projectId: 'mini-erp-d31bd',
    storageBucket: 'mini-erp-d31bd.firebasestorage.app',
    iosBundleId: 'com.example.miniErpApp',
  );
}
