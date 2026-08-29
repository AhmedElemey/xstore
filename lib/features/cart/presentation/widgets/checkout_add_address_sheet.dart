import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/egypt_wilayas.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/phone_input_field.dart';
import '../providers/checkout_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Opens the add/edit address sheet. Pass [existing] and [editIndex]
/// together to edit a saved address in place; omit both to add a new one.
Future<void> showCheckoutAddAddressSheet(
  BuildContext context,
  WidgetRef ref, {
  OrderAddress? existing,
  int? editIndex,
}) async {
  final isEditing = existing != null && editIndex != null;
  final noSavedAddressesYet = ref.read(checkoutProvider).savedAddresses.isEmpty;
  // First address ever added: prefill from the signed-in user's real name
  // and phone instead of leaving the recipient fields blank — there is no
  // hardcoded stand-in left to fall back to.
  final me = !isEditing && noSavedAddressesYet
      ? ref.read(authProvider).valueOrNull
      : null;

  final nameCtrl = TextEditingController(text: existing?.fullName ?? me?.name ?? '');
  final phoneCtrl = TextEditingController(
    text: existing?.phone ?? me?.phoneNumber ?? '',
  );
  final streetCtrl = TextEditingController(text: existing?.street ?? '');
  final cityCtrl = TextEditingController(text: existing?.city ?? '');
  final postalCtrl = TextEditingController(text: existing?.postalCode ?? '');
  var wilaya = existing?.wilaya ?? EgyptWilayas.names.first;
  // The very first saved address defaults to the delivery default so
  // selection logic never has to special-case a single-address list.
  var isDefault = existing?.isDefault ?? noSavedAddressesYet;
  var fieldErrors = <String, String>{};

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
            final l10n = context.l10n;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEditing ? l10n.checkoutEditAddress : l10n.checkoutAddAddress,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.checkoutFullName,
                      border: const OutlineInputBorder(),
                      errorText: fieldErrors['fullName'],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  PhoneInputField(
                    controller: phoneCtrl,
                    onChanged: (_) {},
                    errorText: fieldErrors['phone'],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: streetCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.checkoutStreet,
                      border: const OutlineInputBorder(),
                      errorText: fieldErrors['street'],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: cityCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.checkoutCity,
                      border: const OutlineInputBorder(),
                      errorText: fieldErrors['city'],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: wilaya,
                    decoration: InputDecoration(
                      labelText: l10n.checkoutWilaya,
                      border: const OutlineInputBorder(),
                    ),
                    items: EgyptWilayas.names
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
                      labelText: l10n.checkoutPostalCode,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.checkoutSetDefault),
                    value: isDefault,
                    onChanged: (v) => setSheetState(() => isDefault = v),
                  ),
                  Text(
                    l10n.checkoutAddressesDeviceOnly,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton(
                    onPressed: () {
                      final normalizedPhone =
                          AppValidators.normalizeEgyptLocal(phoneCtrl.text);
                      final errors = <String, String>{};
                      final nameErr = Validators.nonEmptyLine(
                        l10n,
                        nameCtrl.text,
                        (l10n) => l10n.checkoutErrorAddressName,
                      );
                      if (nameErr != null) errors['fullName'] = nameErr;
                      final phoneErr = Validators.egyptPhone(l10n, phoneCtrl.text);
                      if (phoneErr != null) errors['phone'] = phoneErr;
                      final streetErr = Validators.nonEmptyLine(
                        l10n,
                        streetCtrl.text,
                        (l10n) => l10n.checkoutErrorAddressStreet,
                      );
                      if (streetErr != null) errors['street'] = streetErr;
                      final cityErr = Validators.nonEmptyLine(
                        l10n,
                        cityCtrl.text,
                        (l10n) => l10n.checkoutErrorAddressCity,
                      );
                      if (cityErr != null) errors['city'] = cityErr;
                      if (errors.isNotEmpty) {
                        setSheetState(() => fieldErrors = errors);
                        return;
                      }
                      final address = OrderAddress(
                        fullName: nameCtrl.text.trim(),
                        phone: normalizedPhone,
                        street: streetCtrl.text.trim(),
                        city: cityCtrl.text.trim(),
                        wilaya: wilaya,
                        postalCode: postalCtrl.text.trim().isEmpty
                            ? null
                            : postalCtrl.text.trim(),
                        isDefault: isDefault,
                      );
                      if (isEditing) {
                        ref
                            .read(checkoutProvider.notifier)
                            .updateAddress(editIndex, address);
                      } else {
                        ref.read(checkoutProvider.notifier).addAddress(address);
                      }
                      Navigator.pop(ctx);
                    },
                    child: Text(l10n.checkoutSaveAddress),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
  nameCtrl.dispose();
  phoneCtrl.dispose();
  streetCtrl.dispose();
  cityCtrl.dispose();
  postalCtrl.dispose();
}
