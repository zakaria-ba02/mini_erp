import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controller/invoices_controller.dart';
import '../../../data/models/cost.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/helpers/format_helpers.dart';
import '../../widgets/catalog_name_field.dart';
import '../../widgets/currency_dropdown.dart';
import '../../widgets/fx/app_fx_background.dart';
import '../../widgets/fx/fx_app_bar.dart';

class InvoiceFormScreen extends GetView<InvoiceFormController> {
  const InvoiceFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppFxBackground(
        child: SafeArea(
          child: Column(
            children: [
              FxAppBar(
                title: controller.isEdit ? 'تعديل فاتورة' : 'إنشاء فاتورة',
              ),
              Expanded(
                // Track loading only — avoid nested Obx rebuild storms.
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return const _InvoiceFormBody();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvoiceFormBody extends GetView<InvoiceFormController> {
  const _InvoiceFormBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                'بيانات الفاتورة',
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
                  title: const Text('تاريخ الفاتورة'),
                  subtitle: Text(FormatHelpers.date(controller.date.value)),
                  onTap: () => controller.pickDate(context),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Obx(
                () => CurrencyDropdown(
                  value: controller.currency.value,
                  onChanged: (v) => controller.currency.value = v,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  Text(
                    'البنود',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.gold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: controller.addManualLine,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('يدوي'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'اكتب الاسم للبحث في الكتالوج. الاختيار يعبّئ الاسم فقط، وسعر الوحدة يبقى فارغًا.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Obx(() {
                final lines = controller.lines;
                return Column(
                  children: [
                    for (var i = 0; i < lines.length; i++)
                      _LineCard(
                        key: ValueKey('line-$i-${lines[i].costId ?? 'manual'}'),
                        index: i,
                        draft: lines[i],
                        onChanged: controller.notifyLineChanged,
                        onRemove: () => controller.removeLine(i),
                        onPicked: (cost) =>
                            controller.applyCatalogToLine(i, cost),
                        onClearCatalog: () =>
                            controller.clearCatalogLink(i),
                      ),
                  ],
                );
              }),
              Obx(() {
                final error = controller.errorMessage.value;
                if (error == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Text(
                    error,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                );
              }),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(top: BorderSide(color: theme.dividerColor)),
            boxShadow: AppShadows.soft(theme.brightness),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(() {
                final total = controller.estimatedTotal;
                final currency = controller.currency.value;
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        'معاينة تقديرية للإجمالي',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        FormatHelpers.moneyWithCurrency(total, currency),
                        key: ValueKey('$total-${currency.apiValue}'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 4),
              Text(
                'القيمة الرسمية تُحسب من الخادم بعد الحفظ.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
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
                          controller.isEdit
                              ? 'حفظ التعديلات'
                              : 'إنشاء الفاتورة',
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LineCard extends StatelessWidget {
  const _LineCard({
    super.key,
    required this.index,
    required this.draft,
    required this.onChanged,
    required this.onRemove,
    required this.onPicked,
    required this.onClearCatalog,
  });

  final int index;
  final InvoiceLineDraft draft;
  final VoidCallback onChanged;
  final VoidCallback onRemove;
  final ValueChanged<Cost> onPicked;
  final VoidCallback onClearCatalog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: draft.isFromCatalog
              ? AppColors.gold.withValues(alpha: 0.45)
              : theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'بند ${index + 1}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (draft.isFromCatalog)
                TextButton(
                  onPressed: onClearCatalog,
                  child: const Text('فك الربط'),
                ),
              IconButton(
                onPressed: onRemove,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          if (draft.isFromCatalog)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                'مرتبط بالكتالوج',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          CatalogNameField(
            draft: draft,
            onChanged: onChanged,
            onPicked: onPicked,
          ),
          if (draft.isFromCatalog) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Text(
                'مرجعي — تكلفة القطعة: ${FormatHelpers.money(draft.refCostPerUnit)} · السعر المقترح: ${FormatHelpers.money(draft.refSellingPricePerUnit)}\n'
                'أدخل سعر الوحدة النهائي يدويًا في الحقل أدناه (لن يُعبَّأ تلقائيًا).',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: draft.quantityController,
                  textDirection: TextDirection.ltr,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  onChanged: (_) => onChanged(),
                  decoration: const InputDecoration(labelText: 'الكمية'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: draft.unitPriceController,
                  textDirection: TextDirection.ltr,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  onChanged: (_) => onChanged(),
                  decoration: const InputDecoration(
                    labelText: 'سعر الوحدة',
                    hintText: 'أدخله يدويًا',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'تقديري للسطر: ${FormatHelpers.money(draft.estimatedLineTotal)}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

