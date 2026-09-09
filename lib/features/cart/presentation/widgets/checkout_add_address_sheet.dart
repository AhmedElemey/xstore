import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/phone_input_field.dart';
import '../../../cities/presentation/providers/city_dependencies.dart';
import '../../../governments/presentation/providers/government_dependencies.dart';
import '../providers/checkout_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/location_cascade_field.dart';

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
  late final TextEditingController _postalCtrl;

  // The governorate/city picker works in ids (backed by the same live
  // /api/governorates + /api/cities reference data used at register and
  // edit-profile), not free text — this keeps checkout consistent with the
  // rest of the app instead of a second, disagreeing location system.
  int? _cityId;
  int? _governorateId;
  late bool _isDefault;
  var _fieldErrors = <String, String>{};

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.prefillName);
    _phoneCtrl = TextEditingController(text: widget.prefillPhone);
    _streetCtrl = TextEditingController(text: widget.existing?.street ?? '');
    _postalCtrl = TextEditingController(
      text: widget.existing?.postalCode ?? '',
    );
    // The saved address only carries the resolved names (city/wilaya), not
    // the ids that produced them — an editor re-picks governorate/city to
    // change it; until then the field shows the saved names as a hint.
    // The very first saved address defaults to the delivery default so
    // selection logic never has to special-case a single-address list.
    _isDefault = widget.existing?.isDefault ?? widget.noSavedAddressesYet;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
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
    if (_governorateId == null || _cityId == null) {
      errors['location'] = l10n.checkoutErrorAddressCity;
    }
    if (errors.isNotEmpty) {
      setState(() => _fieldErrors = errors);
      return;
    }
    // OrderAddress only carries resolved names on the wire (matching the
    // existing entity shape) — resolve them from the same cached reference
    // lists the picker sheets themselves just read from.
    final isArabic = ref.read(appIsArabicProvider);
    final governorateName = ref
        .read(allGovernmentsProvider)
        .valueOrNull
        ?.where((g) => g.id == _governorateId)
        .firstOrNull
        ?.name
        .resolve(isArabic);
    final cityName = ref
        .read(allCitiesProvider)
        .valueOrNull
        ?.where((c) => c.id == _cityId)
        .firstOrNull
        ?.name
        .resolve(isArabic);
    final address = OrderAddress(
      fullName: _nameCtrl.text.trim(),
      phone: normalizedPhone,
      street: _streetCtrl.text.trim(),
      city: cityName ?? '',
      wilaya: governorateName ?? '',
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
            LocationCascadeField(
              cityId: _cityId,
              governorateId: _governorateId,
              hint: widget.existing == null
                  ? null
                  : '${widget.existing!.wilaya} - ${widget.existing!.city}',
              errorText: _fieldErrors['location'],
              onChanged: (cityId, governorateId) {
                setState(() {
                  _cityId = cityId;
                  _governorateId = governorateId;
                });
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
