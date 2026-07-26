import 'package:flutter/material.dart';

import '../../core/utils/validators.dart';

/// Birth-date picker — today and past dates only; future dates are not selectable.
Future<DateTime?> pickBirthDate(
  BuildContext context, {
  DateTime? selected,
  required DateTime fallback,
  required DateTime firstDate,
}) async {
  final now = DateTime.now();
  final initialDate = Validators.clampBirthDatePickerInitial(
    selected,
    fallback: fallback,
    firstDate: firstDate,
    now: now,
  );
  final picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: Validators.latestBirthDate(now),
    selectableDayPredicate: (day) =>
        Validators.isSelectableBirthDate(day, now),
  );
  if (picked == null) return null;
  return Validators.calendarDate(picked);
}
