import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mini_erp_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  testWidgets('Mini ERP app boots to Splash', (WidgetTester tester) async {
    await tester.pumpWidget(const MiniErpApp());
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
    expect(find.textContaining('جاري'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });
}
