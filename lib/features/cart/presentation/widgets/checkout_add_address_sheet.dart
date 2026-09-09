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

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.surfaceColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.lg),
      ),
    ),
    builder: (ctx) => _CheckoutAddAddressSheet(
      existing: existing,
      editIndex: editIndex,
      prefillName: existing?.fullName ?? me?.name ?? '',
      prefillPhone: existing?.phone ?? me?.phoneNumber ?? '',
      noSavedAddressesYet: noSavedAddressesYet,
    ),
  );
}

class _CheckoutAddAddressSheet extends ConsumerStatefulWidget {
  const _CheckoutAddAddressSheet({
    required this.existing,
    required this.editIndex,
    required this.prefillName,
    required this.prefillPhone,
    required this.noSavedAddressesYet,
  });

  final OrderAddress? existing;
  final int? editIndex;
  final String prefillName;
  final String prefillPhone;
  final bool noSavedAddressesYet;

  bool get isEditing => existing != null && editIndex != null;

  @override
  ConsumerState<_CheckoutAddAddressSheet> createState() =>
      _CheckoutAddAddressSheetState();
}

class _CheckoutAddAddressSheetState
    extends ConsumerState<_CheckoutAddAddressSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _postalCtrl;

  late String _wilaya;
  late bool _isDefault;
  var _fieldErrors = <String, String>{};

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.prefillName);
    _phoneCtrl = TextEditingController(text: widget.prefillPhone);
    _streetCtrl = TextEditingController(text: widget.existing?.street ?? '');
    _cityCtrl = TextEditingController(text: widget.existing?.city ?? '');
    _postalCtrl = TextEditingController(
      text: widget.existing?.postalCode ?? '',
    );
    _wilaya = widget.existing?.wilaya ?? EgyptWilayas.names.first;
    // The very first saved address defaults to the delivery default so
    // selection logic never has to special-case a single-address list.
    _isDefault = widget.existing?.isDefault ?? widget.noSavedAddressesYet;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = context.l10n;
    final normalizedPhone = AppValidators.normalizeEgyptLocal(_phoneCtrl.text);
    final errors = <String, String>{};
    final nameErr = Validators.nonEmptyLine(
      l10n,
      _nameCtrl.text,
      (l10n) => l10n.checkoutErrorAddressName,
    );
    if (nameErr != null) errors['fullName'] = nameErr;
    final phoneErr = Validators.egyptPhone(l10n, _phoneCtrl.text);
    if (phoneErr != null) errors['phone'] = phoneErr;
    final streetErr = Validators.nonEmptyLine(
      l10n,
      _streetCtrl.text,
      (l10n) => l10n.checkoutErrorAddressStreet,
    );
    if (streetErr != null) errors['street'] = streetErr;
    final cityErr = Validators.nonEmptyLine(
      l10n,
      _cityCtrl.text,
      (l10n) => l10n.checkoutErrorAddressCity,
    );
    if (cityErr != null) errors['city'] = cityErr;
    if (errors.isNotEmpty) {
      setState(() => _fieldErrors = errors);
      return;
    }
    final address = OrderAddress(
      fullName: _nameCtrl.text.trim(),
      phone: normalizedPhone,
      street: _streetCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      wilaya: _wilaya,
      postalCode: _postalCtrl.text.trim().isEmpty
          ? null
          : _postalCtrl.text.trim(),
      isDefault: _isDefault,
    );
    if (widget.isEditing) {
      ref
          .read(checkoutProvider.notifier)
          .updateAddress(widget.editIndex!, address);
    } else {
      ref.read(checkoutProvider.notifier).addAddress(address);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.isEditing
                  ? l10n.checkoutEditAddress
                  : l10n.checkoutAddAddress,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: l10n.checkoutFullName,
                border: const OutlineInputBorder(),
                errorText: _fieldErrors['fullName'],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            PhoneInputField(
              controller: _phoneCtrl,
              onChanged: (_) {},
              errorText: _fieldErrors['phone'],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _streetCtrl,
              decoration: InputDecoration(
                labelText: l10n.checkoutStreet,
                border: const OutlineInputBorder(),
                errorText: _fieldErrors['street'],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _cityCtrl,
              decoration: InputDecoration(
                labelText: l10n.checkoutCity,
                border: const OutlineInputBorder(),
                errorText: _fieldErrors['city'],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _wilaya,
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
                if (v != null) setState(() => _wilaya = v);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _postalCtrl,
              decoration: InputDecoration(
                labelText: l10n.checkoutPostalCode,
                border: const OutlineInputBorder(),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.checkoutSetDefault),
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
            ),
            Text(
              l10n.checkoutAddressesDeviceOnly,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              onPressed: _save,
              child: Text(l10n.checkoutSaveAddress),
            ),
          ],
        ),
      ),
    );
  }
}
