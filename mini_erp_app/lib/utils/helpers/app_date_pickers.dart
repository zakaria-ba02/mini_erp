import 'package:flutter/material.dart';

/// Date pickers always use Arabic locale (RTL calendar labels).
class AppDatePickers {
  AppDatePickers._();

  static Future<DateTime?> pick(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      locale: const Locale('ar'),
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2100),
    );
  }
}
