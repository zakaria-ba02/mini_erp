import 'package:flutter/material.dart';

import '../../data/models/app_currency.dart';

class CurrencyDropdown extends StatelessWidget {
  const CurrencyDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AppCurrency value;
  final ValueChanged<AppCurrency> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<AppCurrency>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'العملة',
        prefixIcon: Icon(Icons.payments_outlined),
      ),
      items: AppCurrency.values
          .map(
            (c) => DropdownMenuItem(
              value: c,
              child: Text(c.spokenAr),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
