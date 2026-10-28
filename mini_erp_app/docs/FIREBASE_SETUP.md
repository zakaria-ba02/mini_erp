# إعداد Firebase / FCM لـ Mini ERP

الإشعارات مُجهَّزة في الكود، لكنها **معطّلة** حتى تُكمل إعداد Firebase.

## الخطوات

1. أنشئ مشروعًا في [Firebase Console](https://console.firebase.google.com/).
2. أضف تطبيق Android بالحزمة: `com.example.mini_erp_app`.
3. نزّل `google-services.json` وضعه في:
   `android/app/google-services.json`
4. من جذر المشروع نفّذ:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

5. في الملف المُولَّد `lib/firebase_options.dart` تأكد من وجود القيم الحقيقية، ثم عيّن:

```dart
static const bool isConfigured = true;
```

6. في `android/settings.gradle.kts` أضف (إن لم يُضف تلقائيًا):

```kotlin
id("com.google.gms.google-services") version "4.4.2" apply false
```

وفي `android/app/build.gradle.kts`:

```kotlin
plugins {
    // ...
    id("com.google.gms.google-services")
}
```

7. أعد تشغيل التطبيق (`flutter run`) وسجّل الدخول كزبون — يجب إرسال التوكن عبر `PATCH /users/me/fcm-token`.

## بيانات الإشعار المتوقعة للتنقل

```json
{
  "type": "invoice",
  "id": "<invoiceId>"
}
```

أو:

```json
{
  "type": "payment",
  "id": "<paymentId>"
}
```

مفاتيح بديلة مدعومة: `entity`, `invoiceId`, `paymentId`, `entityId`.
