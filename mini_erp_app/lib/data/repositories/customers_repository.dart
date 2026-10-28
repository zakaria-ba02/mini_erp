import '../models/app_currency.dart';
import '../models/customer.dart';
import '../models/customer_requests.dart';
import '../models/paginated_response.dart';
import '../models/settlement.dart';
import '../providers/customers_provider.dart';

class CustomersRepository {
  CustomersRepository(this._provider);

  final CustomersProvider _provider;

  Future<PaginatedResponse<Customer>> list({
    int page = 1,
    int limit = 20,
    String? search,
  }) {
    return _provider.list(page: page, limit: limit, search: search);
  }

  Future<Customer> getById(String id) => _provider.getById(id);

  Future<Customer> getMe() => _provider.getMe();

  Future<Customer> create(CreateCustomerRequest request) =>
      _provider.create(request);

  Future<Customer> update(String id, UpdateCustomerRequest request) =>
      _provider.update(id, request);

  Future<void> resetPassword(String id, String newPassword) {
    return _provider.resetPassword(
      id,
      ResetCustomerPasswordRequest(newPassword: newPassword),
    );
  }

  Future<void> delete(String id) => _provider.delete(id);

  Future<void> settle(String id, AppCurrency currency) =>
      _provider.settle(id, currency);

  Future<PaginatedResponse<Settlement>> listSettlements(
    String id, {
    int page = 1,
    int limit = 20,
  }) {
    return _provider.listSettlements(id, page: page, limit: limit);
  }
}
