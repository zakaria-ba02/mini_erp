import 'package:get/get.dart';

import '../bindings/audit_logs_binding.dart';
import '../bindings/costing_binding.dart';
import '../bindings/customer_portal_binding.dart';
import '../bindings/customers_binding.dart';
import '../bindings/invoices_binding.dart';
import '../bindings/payments_binding.dart';
import '../data/models/user_role.dart';
import '../views/screens/admin/admin_home_screen.dart';
import '../views/screens/admin/audit_logs_screen.dart';
import '../views/screens/admin/cost_catalog_screen.dart';
import '../views/screens/admin/cost_details_screen.dart';
import '../views/screens/admin/cost_form_screen.dart';
import '../views/screens/admin/customer_account_screen.dart';
import '../views/screens/admin/customer_details_screen.dart';
import '../views/screens/admin/customer_form_screen.dart';
import '../views/screens/admin/customer_settlements_screen.dart';
import '../views/screens/admin/customers_list_screen.dart';
import '../views/screens/admin/invoice_details_screen.dart';
import '../views/screens/admin/invoice_form_screen.dart';
import '../views/screens/admin/invoices_list_screen.dart';
import '../views/screens/admin/payment_details_screen.dart';
import '../views/screens/admin/payment_form_screen.dart';
import '../views/screens/admin/payments_list_screen.dart';
import '../views/screens/admin/reset_password_screen.dart';
import '../views/screens/auth/login_screen.dart';
import '../views/screens/customer/customer_change_password_screen.dart';
import '../views/screens/customer/customer_home_screen.dart';
import '../views/screens/customer/customer_invoice_details_screen.dart';
import '../views/screens/customer/customer_payment_details_screen.dart';
import '../views/screens/splash/splash_screen.dart';
import 'app_routes.dart';
import 'role_middleware.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final _adminOnly = [RoleMiddleware(UserRole.admin)];
  static final _customerOnly = [RoleMiddleware(UserRole.customer)];

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.adminHome,
      page: () => const AdminHomeScreen(),
      middlewares: _adminOnly,
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 320),
    ),
    // Customers
    GetPage(
      name: AppRoutes.customers,
      page: () => const CustomersListScreen(),
      binding: CustomersBinding(),
      middlewares: _adminOnly,
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.customerForm,
      page: () => const CustomerFormScreen(),
      binding: CustomerFormBinding(),
      middlewares: _adminOnly,
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 280),
    ),
    GetPage(
      name: AppRoutes.customerDetails,
      page: () => const CustomerDetailsScreen(),
      binding: CustomerDetailsBinding(),
      middlewares: _adminOnly,
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.customerResetPassword,
      page: () => const ResetPasswordScreen(),
      binding: ResetPasswordBinding(),
      middlewares: _adminOnly,
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: AppRoutes.customerAccount,
      page: () => const CustomerAccountScreen(),
      binding: CustomerAccountBinding(),
      middlewares: _adminOnly,
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.customerSettlements,
      page: () => const CustomerSettlementsScreen(),
      binding: CustomerSettlementsBinding(),
      middlewares: _adminOnly,
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // Costing
    GetPage(
      name: AppRoutes.costing,
      page: () => const CostCatalogScreen(),
      binding: CostingListBinding(),
      middlewares: _adminOnly,
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.costForm,
      page: () => const CostFormScreen(),
      binding: CostFormBinding(),
      middlewares: _adminOnly,
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 280),
    ),
    GetPage(
      name: AppRoutes.costDetails,
      page: () => const CostDetailsScreen(),
      binding: CostDetailsBinding(),
      middlewares: _adminOnly,
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // Invoices
    GetPage(
      name: AppRoutes.invoices,
      page: () => const InvoicesListScreen(),
      binding: InvoicesListBinding(),
      middlewares: _adminOnly,
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.invoiceForm,
      page: () => const InvoiceFormScreen(),
      binding: InvoiceFormBinding(),
      middlewares: _adminOnly,
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 280),
    ),
    GetPage(
      name: AppRoutes.invoiceDetails,
      page: () => const InvoiceDetailsScreen(),
      binding: InvoiceDetailsBinding(),
      middlewares: _adminOnly,
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // Payments
    GetPage(
      name: AppRoutes.payments,
      page: () => const PaymentsListScreen(),
      binding: PaymentsListBinding(),
      middlewares: _adminOnly,
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.paymentForm,
      page: () => const PaymentFormScreen(),
      binding: PaymentFormBinding(),
      middlewares: _adminOnly,
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 280),
    ),
    GetPage(
      name: AppRoutes.paymentDetails,
      page: () => const PaymentDetailsScreen(),
      binding: PaymentDetailsBinding(),
      middlewares: _adminOnly,
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // Audit Logs (read-only)
    GetPage(
      name: AppRoutes.auditLogs,
      page: () => const AuditLogsScreen(),
      binding: AuditLogsBinding(),
      middlewares: _adminOnly,
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.customerHome,
      page: () => const CustomerHomeScreen(),
      binding: CustomerPortalBinding(),
      middlewares: _customerOnly,
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 320),
    ),
    GetPage(
      name: AppRoutes.customerInvoiceDetails,
      page: () => const CustomerInvoiceDetailsScreen(),
      binding: CustomerInvoiceDetailsBinding(),
      middlewares: _customerOnly,
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.customerPaymentDetails,
      page: () => const CustomerPaymentDetailsScreen(),
      binding: CustomerPaymentDetailsBinding(),
      middlewares: _customerOnly,
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.customerChangePassword,
      page: () => const CustomerChangePasswordScreen(),
      middlewares: _customerOnly,
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 280),
    ),
  ];
}
