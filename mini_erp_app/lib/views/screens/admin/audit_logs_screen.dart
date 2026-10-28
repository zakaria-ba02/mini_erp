import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../controller/audit_logs_controller.dart';
import '../../../data/models/audit_log.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/helpers/format_helpers.dart';
import '../../widgets/app_paginated_list_body.dart';
import '../../widgets/fx/app_fx_background.dart';
import '../../widgets/fx/fx_app_bar.dart';
import '../../widgets/fx/fx_icon_button.dart';
import '../../widgets/fx/glass_card.dart';
import '../../widgets/fx/press_scale.dart';

/// Read-only historical log — no edit/delete actions.
class AuditLogsScreen extends GetView<AuditLogsController> {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FxAppBar(
        title: 'سجل التدقيق',
        actions: [
          FxIconButton(
            tooltip: 'مسح الفلاتر',
            icon: Icons.filter_alt_off_outlined,
            onTap: controller.clearFilters,
          ),
        ],
      ),
      body: AppFxBackground(
        child: SafeArea(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              kToolbarHeight + AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => DropdownButtonFormField<String?>(
                          value: controller.selectedEntity.value,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'الكيان',
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('الكل'),
                            ),
                            ...AuditEntities.values.map(
                              (e) => DropdownMenuItem<String?>(
                                value: e,
                                child: Text(e),
                              ),
                            ),
                          ],
                          onChanged: controller.setEntity,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextField(
                        controller: controller.userIdController,
                        decoration: InputDecoration(
                          labelText: 'معرّف المستخدم',
                          isDense: true,
                          suffixIcon: IconButton(
                            onPressed: controller.applyUserIdFilter,
                            icon: const Icon(Icons.search_rounded),
                          ),
                        ),
                        onSubmitted: (_) => controller.applyUserIdFilter(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Obx(
                  () => Row(
                    children: [
                      ActionChip(
                        label: Text(
                          controller.fromDate.value == null
                              ? 'من تاريخ'
                              : FormatHelpers.date(controller.fromDate.value),
                        ),
                        onPressed: () => controller.pickFromDate(context),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ActionChip(
                        label: Text(
                          controller.toDate.value == null
                              ? 'إلى تاريخ'
                              : FormatHelpers.date(controller.toDate.value),
                        ),
                        onPressed: () => controller.pickToDate(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'للعرض فقط — لا يمكن التعديل أو الحذف من هنا',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: Obx(
              () => AppPaginatedListBody(
                state: controller.uiState.value,
                errorMessage:
                    controller.errorMessage.value ?? 'تعذّر تحميل السجل',
                itemCount: controller.items.length,
                hasMore: controller.hasMore,
                skeletonItemHeight: 92,
                onRefresh: controller.fetchFirstPage,
                onRetry: controller.fetchFirstPage,
                onLoadMore: controller.loadMore,
                emptyIcon: Icons.history_rounded,
                emptyTitle: 'لا توجد سجلات',
                emptySubtitle: 'ستظهر هنا العمليات الحساسة بعد حدوثها.',
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                itemBuilder: (context, index) {
                  final log = controller.items[index];
                  return _AuditTile(
                    log: log,
                    onTap: () => controller.showDetails(log),
                  )
                      .animate(delay: (40 * (index % 8)).ms)
                      .fadeIn(duration: 320.ms)
                      .slideX(begin: 0.06, curve: Curves.easeOutCubic);
                },
              ),
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
}

class _AuditTile extends StatelessWidget {
  const _AuditTile({required this.log, required this.onTap});

  final AuditLog log;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressScale(
      onTap: onTap,
      child: GlassCard(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldDark],
                ),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(_iconFor(log.action), color: AppColors.navyOnGold),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${log.actionLabelAr} · ${log.entityLabelAr}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    log.username ?? log.userId ?? 'مستخدم غير معروف',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    FormatHelpers.dateTime(log.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.gold,
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String? action) {
    switch (action?.toLowerCase()) {
      case 'create':
      case 'created':
        return Icons.add_circle_outline_rounded;
      case 'update':
      case 'updated':
      case 'patch':
        return Icons.edit_outlined;
      case 'delete':
      case 'deleted':
      case 'remove':
        return Icons.delete_outline_rounded;
      case 'login':
        return Icons.login_rounded;
      case 'logout':
        return Icons.logout_rounded;
      default:
        return Icons.history_rounded;
    }
  }
}
