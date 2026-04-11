import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/algeria_wilayas.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../auth/presentation/widgets/phone_input_field.dart';
import '../providers/checkout_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

Future<void> showCheckoutAddAddressSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final streetCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final postalCtrl = TextEditingController();
  var wilaya = AlgeriaWilayas.names.first;
  var isDefault = false;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.lg),
      ),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + AppSpacing.lg,
        ),
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.checkoutAddAddress,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: context.l10n.checkoutFullName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  PhoneInputField(
                    controller: phoneCtrl,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: streetCtrl,
                    decoration: InputDecoration(
                      labelText: context.l10n.checkoutStreet,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: cityCtrl,
                    decoration: InputDecoration(
                      labelText: context.l10n.checkoutCity,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: wilaya,
                    decoration: InputDecoration(
                      labelText: context.l10n.checkoutWilaya,
                      border: const OutlineInputBorder(),
                    ),
                    items: AlgeriaWilayas.names
                        .map(
                          (w) => DropdownMenuItem(value: w, child: Text(w)),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setSheetState(() => wilaya = v);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: postalCtrl,
                    decoration: InputDecoration(
                      labelText: context.l10n.checkoutPostalCode,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.checkoutSetDefault),
                    value: isDefault,
                    onChanged: (v) => setSheetState(() => isDefault = v),
                  ),
                  FilledButton(
                    onPressed: () {
                      ref.read(checkoutProvider.notifier).addAddress(
                            OrderAddress(
                              fullName: nameCtrl.text.trim(),
                              phone: phoneCtrl.text.trim(),
                              street: streetCtrl.text.trim(),
                              city: cityCtrl.text.trim(),
                              wilaya: wilaya,
                              postalCode: postalCtrl.text.trim().isEmpty
                                  ? null
                                  : postalCtrl.text.trim(),
                              isDefault: isDefault,
                            ),
                          );
                      Navigator.pop(ctx);
                    },
                    child: Text(context.l10n.checkoutSaveAddress),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
