import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../controller/costing_controller.dart';
import '../../../utils/constants/app_colors.dart';
import '../../widgets/cost_results_card.dart';
import '../../widgets/fx/app_fx_background.dart';
import '../../widgets/fx/fx_app_bar.dart';

class CostFormScreen extends GetView<CostFormController> {
  const CostFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AppFxBackground(
        child: SafeArea(
          child: Column(
            children: [
              FxAppBar(
                title: controller.isEdit ? 'تعديل تكليف' : 'حساب تكليف',
              ),
              Expanded(child: _buildBody(theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return Obx(() {
          if (controller.isLoading.value &&
              controller.isEdit &&
              controller.savedResult.value == null &&
              controller.nameController.text.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'مدخلات الحساب',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: controller.nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم اللوح / المنتج',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _NumField(
                        controller: controller.runtimeController,
                        label: 'عدد الدقائق',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _NumField(
                        controller: controller.hourlyRateController,
                        label: 'سعر الدقيقة',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _NumField(
                        controller: controller.boardPriceController,
                        label: 'سعر اللوح',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _NumField(
                        controller: controller.quantityController,
                        label: 'الكمية',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _NumField(
                        controller: controller.wasteController,
                        label: 'نسبة الهدر %',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _NumField(
                        controller: controller.profitController,
                        label: 'نسبة الربح %',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'تكاليف إضافية',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: controller.addAdditionalCost,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('إضافة'),
                    ),
                  ],
                ),
                Obx(() {
                  if (controller.additionalCosts.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Text(
                        'لا توجد تكاليف إضافية',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (var i = 0;
                          i < controller.additionalCosts.length;
                          i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: controller
                                      .additionalCosts[i].nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'الاسم',
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _NumField(
                                  controller: controller
                                      .additionalCosts[i].priceController,
                                  label: 'السعر',
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    controller.removeAdditionalCost(i),
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                }),
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
                        controller.isLoading.value ? null : controller.submit,
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            controller.isEdit
                                ? 'حفظ وإعادة الحساب'
                                : 'حساب وحفظ',
                          ),
                  ),
                ),
                Obx(() {
                  final result = controller.savedResult.value;
                  if (result == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CostResultsCard(cost: result),
                        const SizedBox(height: AppSpacing.md),
                        OutlinedButton.icon(
                          onPressed: controller.viewDetails,
                          icon: const Icon(Icons.visibility_outlined),
                          label: const Text('عرض التفاصيل'),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
    });
  }
}

class _NumField extends StatelessWidget {
  const _NumField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textDirection: TextDirection.ltr,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      decoration: InputDecoration(labelText: label),
    );
  }
}
