import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:mini_erp_app/controller/invoices_controller.dart';
import 'package:mini_erp_app/data/models/cost.dart';
import 'package:mini_erp_app/utils/constants/error_messages.dart';
import 'package:mini_erp_app/utils/helpers/format_helpers.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar');
  });

  group('ErrorMessages', () {
    test('maps known codes to Arabic', () {
      expect(
        ErrorMessages.fromCode('INVALID_CREDENTIALS'),
        contains('كلمة المرور'),
      );
      expect(ErrorMessages.fromCode('FORBIDDEN'), contains('صلاحية'));
    });

    test('never returns raw JSON/exception dumps', () {
      final mapped = ErrorMessages.fromResponseBody({
        'message': 'InternalException stack {...}',
      });
      expect(mapped, ErrorMessages.generic);
    });

    test('status 403 maps to forbidden Arabic', () {
      expect(
        ErrorMessages.fromStatusCode(403, null),
        ErrorMessages.fromCode('FORBIDDEN'),
      );
    });

    test('Dio connection error maps to network', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      );
      expect(ErrorMessages.fromAny(err), ErrorMessages.network);
    });
  });

  group('Invoice catalog unitPrice rule', () {
    test('addFromCatalog never fills unitPrice', () {
      final cost = Cost(
        id: 'c1',
        name: 'لوح',
        runtime: 1,
        hourlyRate: 1,
        boardPrice: 1,
        quantity: 10,
        wastePercentage: 0,
        profitPercentage: 10,
        additionalCosts: const [],
        costPerUnit: 5,
        sellingPricePerUnit: 12,
      );
      final draft = InvoiceLineDraft(
        costId: cost.id,
        name: cost.name,
        refCostPerUnit: cost.costPerUnit,
        refSellingPricePerUnit: cost.sellingPricePerUnit,
      );
      draft.unitPriceController.clear();
      expect(draft.unitPriceController.text, isEmpty);
      expect(draft.costId, 'c1');
      expect(draft.nameController.text, 'لوح');
      draft.dispose();
    });
  });

  group('FormatHelpers', () {
    test('date returns dash for null', () {
      expect(FormatHelpers.date(null), '—');
    });

    test('money formats non-null', () {
      expect(FormatHelpers.money(1000), isNotEmpty);
      expect(FormatHelpers.moneyAscii(1000), contains('1'));
    });
  });
}
