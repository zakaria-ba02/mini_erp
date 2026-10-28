import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../controller/costing_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/helpers/format_helpers.dart';
import '../../widgets/app_error_state.dart';
import '../../widgets/fx/app_fx_background.dart';
import '../../widgets/fx/fx_app_bar.dart';
import '../../widgets/fx/fx_icon_button.dart';
import '../../widgets/cost_results_card.dart';

class CostDetailsScreen extends GetView<CostDetailsController> {
  const CostDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AppFxBackground(
        child: SafeArea(
          child: Column(
            children: [
              FxAppBar(
                title: 'تفاصيل التكليف',
                showThemeToggle: false,
                actions: [
                  Obx(() {
                    final c = controller.cost.value;
                    if (c == null) return const SizedBox.shrink();
                    return FxIconButton(
                      tooltip: 'تعديل',
                      icon: Icons.edit_outlined,
                      onTap: () async {
                        await Get.toNamed(AppRoutes.costForm, arguments: c.id);
                        controller.load();
                      },
                    );
                  }),
                  FxIconButton(
                    tooltip: 'حذف',
                    onTap: controller.confirmDelete,
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
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
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final error = controller.errorMessage.value;
        if (error != null) {
          return AppErrorState(message: error, onRetry: controller.load);
        }
        final c = controller.cost.value;
        if (c == null) {
          return const AppErrorState(message: 'عنصر التكليف غير موجود');
        }

        return RefreshIndicator(
          color: AppColors.gold,
          onRefresh: controller.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                c.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ).animate().fadeIn(),
              const SizedBox(height: AppSpacing.lg),
              CostResultsCard(cost: c),
              const SizedBox(height: AppSpacing.lg),
              _SectionCard(
                title: 'المدخلات',
                children: [
                  _Row('عدد الدقائق', FormatHelpers.money(c.runtime)),
                  _Row('سعر الدقيقة', FormatHelpers.money(c.hourlyRate)),
                  _Row('سعر اللوح', FormatHelpers.money(c.boardPrice)),
                  _Row('الكمية', FormatHelpers.money(c.quantity)),
                  _Row('نسبة الهدر', '${FormatHelpers.money(c.wastePercentage)}%'),
                  _Row(
                    'نسبة الربح',
                    '${FormatHelpers.money(c.profitPercentage)}%',
                  ),
                ],
              ).animate().fadeIn(delay: 60.ms),
              const SizedBox(height: AppSpacing.md),
              _SectionCard(
                title: 'تفصيل التكاليف (للقطعة)',
                children: [
                  _Row(
                    'تكلفة الليزر',
                    FormatHelpers.money(c.laserCostPerUnit),
                  ),
                  _Row(
                    'مجموع الإضافات',
                    FormatHelpers.money(c.additionalCostsTotal),
                  ),
                  _Row(
                    'تكلفة الهدر',
                    FormatHelpers.money(_perUnit(c.wasteCost, c.quantity)),
                  ),
                  _Row(
                    'الربح',
                    FormatHelpers.money(_perUnit(c.profit, c.quantity)),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms),
              if (c.additionalCosts.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _SectionCard(
                  title: 'تكاليف إضافية',
                  children: [
                    for (final extra in c.additionalCosts)
                      _Row(extra.name, FormatHelpers.money(extra.price)),
                  ],
                ).animate().fadeIn(delay: 140.ms),
              ],
              const SizedBox(height: AppSpacing.md),
              Text(
                'آخر تحديث: ${FormatHelpers.dateTime(c.updatedAt)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
    });
  }

  /// Backend stores these as batch values (per-unit × quantity).
  num? _perUnit(num? batchValue, num quantity) {
    if (batchValue == null) return null;
    if (quantity <= 0) return batchValue;
    return batchValue / quantity;
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
