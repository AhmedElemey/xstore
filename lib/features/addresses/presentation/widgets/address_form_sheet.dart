import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../auth/presentation/widgets/phone_input_field.dart';
import '../../../cities/presentation/providers/city_dependencies.dart';
import '../../../governments/presentation/providers/government_dependencies.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/utils/address_location_display.dart';
import '../../../../shared/widgets/location_cascade_field.dart';
import '../../../../shared/widgets/xstore_button.dart';

/// Opens the add/edit address sheet, shared by checkout's address step and
/// the Profile "My Addresses" screen — the two only places a saved address
/// is created or edited. Pass [existing] and [editIndex] together to edit
/// an address in place; omit both to add a new one. [onSave] is called
/// with the built [OrderAddress] once validation passes; the caller owns
/// where that address is written (checkout's per-checkout-session copy or
/// the shared address book) so this widget stays agnostic of which.
Future<void> showAddressFormSheet(
  BuildContext context,
  WidgetRef ref, {
  OrderAddress? existing,
  int? editIndex,
  required bool noSavedAddressesYet,
  required void Function(OrderAddress address) onSave,
}) async {
  final isEditing = existing != null && editIndex != null;
  // First address ever added: prefill from the signed-in user's real name
  // and phone instead of leaving the recipient fields blank.
  final me = !isEditing && noSavedAddressesYet
      ? ref.read(authProvider).valueOrNull
      : null;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _AddressFormSheet(
      existing: existing,
      editIndex: editIndex,
      prefillName: existing?.fullName ?? me?.name ?? '',
      prefillPhone: existing?.phone ?? me?.phoneNumber ?? '',
      noSavedAddressesYet: noSavedAddressesYet,
      onSave: onSave,
    ),
  );
}

class _AddressFormSheet extends ConsumerStatefulWidget {
  const _AddressFormSheet({
    required this.existing,
    required this.editIndex,
    required this.prefillName,
    required this.prefillPhone,
    required this.noSavedAddressesYet,
    required this.onSave,
  });

  final OrderAddress? existing;
  final int? editIndex;
  final String prefillName;
  final String prefillPhone;
  final bool noSavedAddressesYet;
  final void Function(OrderAddress address) onSave;

  bool get isEditing => existing != null && editIndex != null;

  @override
  ConsumerState<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends ConsumerState<_AddressFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _postalCtrl;

  // The governorate/city picker works in ids (backed by the same live
  // /api/governorates + /api/cities reference data used at register and
  // edit-profile), not free text — this keeps the form consistent with the
  // rest of the app instead of a second, disagreeing location system.
  int? _cityId;
  int? _governorateId;
  // An address pinned on the map before the picker was hidden keeps its
  // spot on save, so checkout still sends those coordinates instead of the
  // device's last-known GPS fix.
  double? _pickedLat;
  double? _pickedLng;
  late bool _isDefault;
  late final Listenable _fields;
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
    _pickedLat = widget.existing?.latitude;
    _pickedLng = widget.existing?.longitude;
    // Location (_cityId/_governorateId) isn't a TextEditingController, so it
    // isn't part of this Listenable — the picker's onChanged already calls
    // setState, which rebuilds the ListenableBuilder below along with the
    // rest of the sheet, so its selection is still reflected immediately.
    _fields = Listenable.merge([
      _nameCtrl,
      _phoneCtrl,
      _streetCtrl,
      _postalCtrl,
    ]);
    // The saved address only carries the resolved names (city/wilaya), not
    // the ids that produced them — an editor re-picks governorate/city to
    // change it; until then the field shows the saved names as a hint.
    // The very first saved address defaults to main so selection logic
    // never has to special-case a single-address list.
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
      latitude: _pickedLat,
      longitude: _pickedLng,
      // Guaranteed non-null here: the errors check above blocks save until
      // both are picked.
      cityId: _cityId,
      governorateId: _governorateId,
    );
    widget.onSave(address);
    Navigator.pop(context);
  }

  bool get _phoneValid =>
      Validators.egyptPhone(context.l10n, _phoneCtrl.text) == null;

  bool get _hasChanged {
    if (!widget.isEditing) return true;
    final e = widget.existing!;
    final postal = _postalCtrl.text.trim();
    // _cityId/_governorateId always start null on edit (the picker only
    // shows the saved wilaya/city as a hint, per the comment above) — any
    // pick counts as a change, and _save() already blocks until both are
    // set, so this can never be a false positive.
    return _nameCtrl.text.trim() != e.fullName.trim() ||
        AppValidators.normalizeEgyptLocal(_phoneCtrl.text) !=
            AppValidators.normalizeEgyptLocal(e.phone) ||
        _streetCtrl.text.trim() != e.street.trim() ||
        _cityId != null ||
        _governorateId != null ||
        (postal.isEmpty ? null : postal) != e.postalCode ||
        _isDefault != e.isDefault ||
        _pickedLat != e.latitude ||
        _pickedLng != e.longitude;
  }

  bool get _canSave => _phoneValid && _hasChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Resolved in the CURRENT locale (not the frozen wilaya/city strings)
    // so the hint doesn't show stale English inside an otherwise-Arabic
    // sheet (or vice versa) when editing an address saved in another
    // language.
    final existingLocationHint = widget.existing == null
        ? null
        : () {
            final location = resolveAddressLocation(ref, widget.existing!);
            return '${location.wilaya} - ${location.city}';
          }();
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
            AuthTextField(
              label: l10n.checkoutFullName,
              controller: _nameCtrl,
              errorText: _fieldErrors['fullName'],
            ),
            const SizedBox(height: AppSpacing.md),
            PhoneInputField(
              controller: _phoneCtrl,
              onChanged: (_) {},
              errorText: _fieldErrors['phone'],
            ),
            const SizedBox(height: AppSpacing.md),
            AuthTextField(
              label: l10n.checkoutStreet,
              controller: _streetCtrl,
              errorText: _fieldErrors['street'],
            ),
            const SizedBox(height: AppSpacing.md),
            LocationCascadeField(
              cityId: _cityId,
              governorateId: _governorateId,
              hint: existingLocationHint,
              errorText: _fieldErrors['location'],
              onChanged: (cityId, governorateId) {
                setState(() {
                  _cityId = cityId;
                  _governorateId = governorateId;
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AuthTextField(
              label: l10n.checkoutPostalCode,
              controller: _postalCtrl,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.checkoutSetDefault,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
            ListenableBuilder(
              listenable: _fields,
              builder: (context, _) => XstoreButton(
                label: l10n.checkoutSaveAddress,
                onPressed: _canSave ? _save : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
