abstract class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const adminHome = '/admin';
  static const customerHome = '/customer';
  static const customerInvoiceDetails = '/customer/invoices/details';
  static const customerPaymentDetails = '/customer/payments/details';
  static const customerChangePassword = '/customer/change-password';

  // Admin — Customers (Phase 3)
  static const customers = '/admin/customers';
  static const customerForm = '/admin/customers/form';
  static const customerDetails = '/admin/customers/details';
  static const customerResetPassword = '/admin/customers/reset-password';
  static const customerAccount = '/admin/customers/account';
  static const customerSettlements = '/admin/customers/settlements';

  // Admin — Costing (Phase 4)
  static const costing = '/admin/costing';
  static const costForm = '/admin/costing/form';
  static const costDetails = '/admin/costing/details';

  // Admin — Invoices (Phase 5)
  static const invoices = '/admin/invoices';
  static const invoiceForm = '/admin/invoices/form';
  static const invoiceDetails = '/admin/invoices/details';

  // Admin — Payments (Phase 6)
  static const payments = '/admin/payments';
  static const paymentForm = '/admin/payments/form';
  static const paymentDetails = '/admin/payments/details';

  // Admin — Audit Logs (Phase 7)
  static const auditLogs = '/admin/audit-logs';
}
