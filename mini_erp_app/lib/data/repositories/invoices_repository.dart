import '../models/app_currency.dart';
import '../models/invoice.dart';
import '../models/paginated_response.dart';
import '../providers/invoices_provider.dart';

class InvoicesRepository {
  InvoicesRepository(this._provider);

  final InvoicesProvider _provider;

  Future<PaginatedResponse<Invoice>> list({
    int page = 1,
    int limit = 20,
    String? customerId,
    InvoiceStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? search,
    AppCurrency? currency,
    String? settlementId,
  }) {
    return _provider.list(
      page: page,
      limit: limit,
      customerId: customerId,
      status: status,
      fromDate: fromDate,
      toDate: toDate,
      search: search,
      currency: currency,
      settlementId: settlementId,
    );
  }

  Future<Invoice> getById(String id) => _provider.getById(id);

  Future<Invoice> create(CreateInvoiceRequest request) =>
      _provider.create(request);

  Future<Invoice> update(String id, UpdateInvoiceRequest request) =>
      _provider.update(id, request);

  Future<void> delete(String id) => _provider.delete(id);
}
