import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/invoices_controller.dart';
import '../../data/models/cost.dart';
import '../../data/repositories/costing_repository.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/helpers/format_helpers.dart';

/// Inline catalog search while typing. Picking a cost fills name + costId only.
class CatalogNameField extends StatefulWidget {
  const CatalogNameField({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.onPicked,
  });

  final InvoiceLineDraft draft;
  final VoidCallback onChanged;
  final ValueChanged<Cost> onPicked;

  @override
  State<CatalogNameField> createState() => _CatalogNameFieldState();
}

class _CatalogNameFieldState extends State<CatalogNameField> {
  Timer? _debounce;
  List<Cost> _suggestions = [];
  bool _searching = false;
  int _requestId = 0;

  CostingRepository get _repo => Get.find<CostingRepository>();

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onTextChanged(String value) {
    widget.onChanged();
    _debounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _searching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 280), () {
      unawaited(_search(query));
    });
  }

  Future<void> _search(String query) async {
    final id = ++_requestId;
    setState(() => _searching = true);
    try {
      final result = await _repo.list(page: 1, limit: 8, search: query);
      if (!mounted || id != _requestId) return;
      setState(() {
        _suggestions = result.data;
        _searching = false;
      });
    } catch (_) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _suggestions = [];
        _searching = false;
      });
    }
  }

  void _pick(Cost cost) {
    widget.onPicked(cost);
    setState(() {
      _suggestions = [];
      _searching = false;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: widget.draft.nameController,
          onChanged: _onTextChanged,
          decoration: InputDecoration(
            labelText: 'الاسم',
            hintText: 'اكتب للبحث في الكتالوج…',
            suffixIcon: _searching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.search_rounded),
          ),
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: theme.dividerColor),
            ),
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final cost = _suggestions[i];
                return ListTile(
                  dense: true,
                  title: Text(cost.name),
                  subtitle: Text(
                    'تكلفة: ${FormatHelpers.money(cost.costPerUnit)} · مقترح: ${FormatHelpers.money(cost.sellingPricePerUnit)}',
                  ),
                  onTap: () => _pick(cost),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
