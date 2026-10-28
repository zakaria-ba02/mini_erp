import 'package:get/get.dart';

import '../data/models/app_currency.dart';
import '../data/models/customer.dart';
import '../data/repositories/customers_repository.dart';
import '../data/repositories/invoices_repository.dart';
import '../data/repositories/payments_repository.dart';
import '../routes/app_routes.dart';
import '../utils/dio/dio_client.dart';

enum AccountEntryKind { invoice, payment }

class AccountLedgerEntry {
  const AccountLedgerEntry({
    required this.kind,
    required this.id,
    required this.date,
    required this.amount,
  });

  final AccountEntryKind kind;
  final String id;
  final DateTime date;
  final num amount;
}

class CustomerAccountController extends GetxController {
  CustomerAccountController(
    this._customersRepository,
    this._invoicesRepository,
    this._paymentsRepository,
  );

  final CustomersRepository _customersRepository;
  final InvoicesRepository _invoicesRepository;
  final PaymentsRepository _paymentsRepository;

  late final String customerId;
  late final AppCurrency currency;
  String? settlementId;
  num? archivedBalance;
  DateTime? settledAt;

  final customer = Rxn<Customer>();
  final entries = <AccountLedgerEntry>[].obs;
  final isLoading = true.obs;
  final errorMessage = RxnString();

  bool get isArchived => settlementId != null && settlementId!.isNotEmpty;

  num get balance => isArchived
      ? (archivedBalance ?? 0)
      : (customer.value?.balances.forCurrency(currency) ?? 0);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      customerId = args['customerId']?.toString() ?? '';
      currency = AppCurrency.fromString(args['currency']?.toString());
      final sid = args['settlementId']?.toString();
      settlementId = (sid == null || sid.isEmpty) ? null : sid;
      archivedBalance = args['balanceAtSettlement'] as num?;
      settledAt = DateTime.tryParse(args['settledAt']?.toString() ?? '');
    } else {
      customerId = '';
      currency = AppCurrency.syp;
    }
    if (customerId.isEmpty) {
      errorMessage.value = 'معرّف الزبون غير موجود.';
      isLoading.value = false;
    } else {
      load();
    }
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final profile = await _customersRepository.getById(customerId);
      final invoices = await _invoicesRepository.list(
        page: 1,
        limit: 100,
        customerId: customerId,
        currency: currency,
        settlementId: settlementId,
      );
      final payments = await _paymentsRepository.list(
        page: 1,
        limit: 100,
        customerId: customerId,
        currency: currency,
        settlementId: settlementId,
      );

      customer.value = profile;
      final merged = <AccountLedgerEntry>[
        for (final invoice in invoices.data)
          AccountLedgerEntry(
            kind: AccountEntryKind.invoice,
            id: invoice.id,
            date: invoice.date,
            amount: invoice.total,
          ),
        for (final payment in payments.data)
          AccountLedgerEntry(
            kind: AccountEntryKind.payment,
            id: payment.id,
            date: payment.date,
            amount: payment.amount,
          ),
      ]..sort((a, b) => b.date.compareTo(a.date));
      entries.assignAll(merged);
    } catch (e) {
      errorMessage.value = DioClient.mapError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void openEntry(AccountLedgerEntry entry) {
    if (entry.kind == AccountEntryKind.invoice) {
      Get.toNamed(AppRoutes.invoiceDetails, arguments: entry.id);
    } else {
      Get.toNamed(AppRoutes.paymentDetails, arguments: entry.id);
    }
  }

  Map<String, dynamic> get _listArgs => {
        'customerId': customerId,
        'currency': currency.apiValue,
        if (isArchived) 'settlementId': settlementId,
      };

  void openInvoices() {
    Get.toNamed(AppRoutes.invoices, arguments: _listArgs);
  }

  void openPayments() {
    Get.toNamed(AppRoutes.payments, arguments: _listArgs);
  }

  void openNewInvoice() {
    if (isArchived) return;
    Get.toNamed(
      AppRoutes.invoiceForm,
      arguments: {
        'customerId': customerId,
        'currency': currency.apiValue,
      },
    );
  }

  void openNewPayment() {
    if (isArchived) return;
    Get.toNamed(
      AppRoutes.paymentForm,
      arguments: {
        'customerId': customerId,
        'currency': currency.apiValue,
      },
    );
  }
}
