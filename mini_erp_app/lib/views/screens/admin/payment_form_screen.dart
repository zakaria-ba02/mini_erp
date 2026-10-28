import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controller/payments_controller.dart';
import '../../../data/models/payment.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/helpers/format_helpers.dart';
import '../../widgets/currency_dropdown.dart';
import '../../widgets/fx/app_fx_background.dart';
import '../../widgets/fx/fx_app_bar.dart';

class PaymentFormScreen extends GetView<PaymentFormController> {
  const PaymentFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppFxBackground(
        child: SafeArea(
          child: Column(
            children: [
              FxAppBar(
                title: controller.isEdit ? 'تعديل دفعة' : 'تسجيل دفعة',
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return const _PaymentFormBody();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentFormBody extends GetView<PaymentFormController> {
  const _PaymentFormBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'بيانات الدفعة',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Obx(
            () => DropdownButtonFormField<String>(
              value: controller.selectedCustomerId.value,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'الزبون',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              items: controller.customers
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    ),
                  )
                  .toList(),
              onChanged: (v) => controller.selectedCustomerId.value = v,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Obx(
            () => CurrencyDropdown(
              value: controller.currency.value,
              onChanged: (v) => controller.currency.value = v,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: controller.amountController,
            textDirection: TextDirection.ltr,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: const InputDecoration(
              labelText: 'المبلغ',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Obx(
            () => ListTile(
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
                side: BorderSide(color: theme.dividerColor),
              ),
              leading: const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.gold,
              ),
              title: const Text('تاريخ الدفعة'),
              subtitle: Text(FormatHelpers.date(controller.date.value)),
              onTap: () => controller.pickDate(context),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Obx(
            () => DropdownButtonFormField<String>(
              value: controller.method.value,
              decoration: const InputDecoration(
                labelText: 'طريقة الدفع',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
              items: PaymentMethods.all
                  .map(
                    (m) => DropdownMenuItem(
                      value: m,
                      child: Text(PaymentMethods.labelAr(m)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) controller.method.value = v;
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: controller.notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'ملاحظات (اختياري)',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Obx(() {
            final error = controller.errorMessage.value;
            if (error == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                error,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            );
          }),
          Obx(
            () => ElevatedButton(
              onPressed:
                  controller.isSaving.value ? null : controller.submit,
              child: controller.isSaving.value
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      controller.isEdit ? 'حفظ التعديلات' : 'تسجيل الدفعة',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
