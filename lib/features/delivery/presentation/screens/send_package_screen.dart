import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/location_cascade_field.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/phone_input_field.dart';
import '../../../cities/presentation/providers/city_dependencies.dart';
import '../../../governments/presentation/providers/government_dependencies.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../providers/delivery_requests_provider.dart';

/// Optional prefill passed via `go_router`'s `extra` when this screen is
/// opened from a specific context: a vendor requesting custom delivery for
/// an order ([orderId] + [initialDropoff] from the order's buyer address),
/// or "Request again" on a cancelled request ([initialPickup]/
/// [initialDropoff]/[initialNote] copied from it, plus its [orderId] if it
/// was order-linked).
class SendPackageArgs {
  const SendPackageArgs({
    this.orderId,
    this.initialPickup,
    this.initialDropoff,
    this.initialNote,
  });

  final String? orderId;
  final OrderAddress? initialPickup;
  final OrderAddress? initialDropoff;
  final String? initialNote;
}

/// Request form (consumer or vendor): request a courier to move a package
/// from a pickup address to a drop-off address. COD-at-pickup — the admin
/// prices the request and the sender pays the courier in cash when the
/// package is collected; the app never holds money.
class SendPackageScreen extends ConsumerStatefulWidget {
  const SendPackageScreen({super.key, this.args});

  final SendPackageArgs? args;

  @override
  ConsumerState<SendPackageScreen> createState() => _SendPackageScreenState();
}

class _SendPackageScreenState extends ConsumerState<SendPackageScreen> {
  final _formKey = GlobalKey<FormState>();

  final _senderNameCtrl = TextEditingController();
  final _senderPhoneCtrl = TextEditingController();
  final _pickupStreetCtrl = TextEditingController();
  final _recipientNameCtrl = TextEditingController();
  final _recipientPhoneCtrl = TextEditingController();
  final _dropoffStreetCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  // Governorate/city picked via the same API-backed cascade used at
  // checkout — OrderAddress only carries resolved names on the wire, so a
  // prefilled pickup/dropoff (see below) is shown as a hint, not mapped
  // back to ids; the sender re-picks it to submit, same tradeoff already
  // accepted for the checkout address book.
  int? _pickupCityId;
  int? _pickupGovernorateId;
  int? _dropoffCityId;
  int? _dropoffGovernorateId;
  String? _pickupLocationHint;
  String? _dropoffLocationHint;

  // PhoneInputField reports errors via `errorText` instead of a Form
  // validator, so phone validation is applied on submit.
  String? _senderPhoneError;
  String? _recipientPhoneError;
  String? _pickupLocationError;
  String? _dropoffLocationError;

  @override
  void initState() {
    super.initState();
    // Sender defaults to the signed-in requester, consumer or vendor (route
    // is login-gated, but valueOrNull keeps this null-safe if auth is
    // mid-refresh). A prefilled pickup (from "Request again") overrides it.
    final user = ref.read(authProvider).valueOrNull;
    if (user != null) {
      _senderNameCtrl.text = user.name;
      _senderPhoneCtrl.text = AppValidators.toLocalEgypt(user.phoneNumber);
    }
    final pickup = widget.args?.initialPickup;
    if (pickup != null) {
      _senderNameCtrl.text = pickup.fullName;
      _senderPhoneCtrl.text = AppValidators.toLocalEgypt(pickup.phone);
      _pickupStreetCtrl.text = pickup.street;
      if (pickup.wilaya.isNotEmpty || pickup.city.isNotEmpty) {
        _pickupLocationHint = '${pickup.wilaya} - ${pickup.city}';
      }
    }
    final dropoff = widget.args?.initialDropoff;
    if (dropoff != null) {
      _recipientNameCtrl.text = dropoff.fullName;
      _recipientPhoneCtrl.text = AppValidators.toLocalEgypt(dropoff.phone);
      _dropoffStreetCtrl.text = dropoff.street;
      if (dropoff.wilaya.isNotEmpty || dropoff.city.isNotEmpty) {
        _dropoffLocationHint = '${dropoff.wilaya} - ${dropoff.city}';
      }
    }
    final note = widget.args?.initialNote;
    if (note != null) _noteCtrl.text = note;
  }

  @override
  void dispose() {
    _senderNameCtrl.dispose();
    _senderPhoneCtrl.dispose();
    _pickupStreetCtrl.dispose();
    _recipientNameCtrl.dispose();
    _recipientPhoneCtrl.dispose();
    _dropoffStreetCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final senderPhoneError = Validators.egyptPhone(l10n, _senderPhoneCtrl.text);
    final recipientPhoneError =
        Validators.egyptPhone(l10n, _recipientPhoneCtrl.text);
    final pickupLocationError =
        (_pickupGovernorateId == null || _pickupCityId == null)
            ? l10n.checkoutErrorAddressCity
            : null;
    final dropoffLocationError =
        (_dropoffGovernorateId == null || _dropoffCityId == null)
            ? l10n.checkoutErrorAddressCity
            : null;
    final formOk = _formKey.currentState?.validate() ?? false;
    setState(() {
      _senderPhoneError = senderPhoneError;
      _recipientPhoneError = recipientPhoneError;
      _pickupLocationError = pickupLocationError;
      _dropoffLocationError = dropoffLocationError;
    });
    if (!formOk ||
        senderPhoneError != null ||
        recipientPhoneError != null ||
        pickupLocationError != null ||
        dropoffLocationError != null) {
      return;
    }

    final isArabic = ref.read(appIsArabicProvider);
    final governments = ref.read(allGovernmentsProvider).valueOrNull;
    final cities = ref.read(allCitiesProvider).valueOrNull;
    String? governorateNameOf(int? id) => governments
        ?.where((g) => g.id == id)
        .firstOrNull
        ?.name
        .resolve(isArabic);
    String? cityNameOf(int? id) =>
        cities?.where((c) => c.id == id).firstOrNull?.name.resolve(isArabic);

    final pickup = OrderAddress(
      fullName: _senderNameCtrl.text.trim(),
      phone: AppValidators.normalizeEgyptLocal(_senderPhoneCtrl.text),
      street: _pickupStreetCtrl.text.trim(),
      city: cityNameOf(_pickupCityId) ?? '',
      wilaya: governorateNameOf(_pickupGovernorateId) ?? '',
    );
    final dropoff = OrderAddress(
      fullName: _recipientNameCtrl.text.trim(),
      phone: AppValidators.normalizeEgyptLocal(_recipientPhoneCtrl.text),
      street: _dropoffStreetCtrl.text.trim(),
      city: cityNameOf(_dropoffCityId) ?? '',
      wilaya: governorateNameOf(_dropoffGovernorateId) ?? '',
    );

    final ok = await ref.read(deliveryRequestsProvider.notifier).createRequest(
          pickup: pickup,
          dropoff: dropoff,
          packageNote: _noteCtrl.text.trim(),
          orderId: widget.args?.orderId,
        );
    if (!mounted) return;
    if (ok) {
      AppSnackbar.success(context, context.l10n.sendPackageSubmitted);
      // Replace the form with the requests list so back returns to profile.
      context.pushReplacement(AppRoutes.myPackages);
    } else {
      final error = ref.read(deliveryRequestsProvider).error;
      AppSnackbar.error(context, error ?? context.l10n.errorGeneric);
    }
  }

  String? _requiredLine(String? value) =>
      (value == null || value.trim().isEmpty)
          ? context.l10n.sendPackageFieldRequired
          : null;

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      );

  @override
  Widget build(BuildContext context) {
    final isSubmitting =
        ref.watch(deliveryRequestsProvider.select((s) => s.isSubmitting));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.sendPackageTitle)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _CashAtPickupNote(),
                const SizedBox(height: AppSpacing.lg),
                _sectionTitle(context, context.l10n.sendPackagePickupSection),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _senderNameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration:
                      _decoration(context.l10n.sendPackageSenderName),
                  validator: _requiredLine,
                ),
                const SizedBox(height: AppSpacing.md),
                PhoneInputField(
                  controller: _senderPhoneCtrl,
                  errorText: _senderPhoneError,
                  onChanged: (_) {
                    if (_senderPhoneError != null) {
                      setState(() => _senderPhoneError = null);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _pickupStreetCtrl,
                  decoration: _decoration(context.l10n.checkoutStreet),
                  validator: _requiredLine,
                ),
                const SizedBox(height: AppSpacing.md),
                LocationCascadeField(
                  cityId: _pickupCityId,
                  governorateId: _pickupGovernorateId,
                  hint: _pickupLocationHint,
                  errorText: _pickupLocationError,
                  onChanged: (cityId, governorateId) {
                    setState(() {
                      _pickupCityId = cityId;
                      _pickupGovernorateId = governorateId;
                      _pickupLocationError = null;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                _sectionTitle(context, context.l10n.sendPackageDropoffSection),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _recipientNameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration:
                      _decoration(context.l10n.sendPackageRecipientName),
                  validator: _requiredLine,
                ),
                const SizedBox(height: AppSpacing.md),
                PhoneInputField(
                  controller: _recipientPhoneCtrl,
                  errorText: _recipientPhoneError,
                  onChanged: (_) {
                    if (_recipientPhoneError != null) {
                      setState(() => _recipientPhoneError = null);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _dropoffStreetCtrl,
                  decoration: _decoration(context.l10n.checkoutStreet),
                  validator: _requiredLine,
                ),
                const SizedBox(height: AppSpacing.md),
                LocationCascadeField(
                  cityId: _dropoffCityId,
                  governorateId: _dropoffGovernorateId,
                  hint: _dropoffLocationHint,
                  errorText: _dropoffLocationError,
                  onChanged: (cityId, governorateId) {
                    setState(() {
                      _dropoffCityId = cityId;
                      _dropoffGovernorateId = governorateId;
                      _dropoffLocationError = null;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                _sectionTitle(context, context.l10n.sendPackageNoteLabel),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  maxLength: 300,
                  decoration: InputDecoration(
                    hintText: context.l10n.sendPackageNoteHint,
                    border: const OutlineInputBorder(),
                  ),
                  validator: _requiredLine,
                ),
                const SizedBox(height: AppSpacing.lg),
                XstoreButton(
                  label: context.l10n.sendPackageSubmit,
                  isLoading: isSubmitting,
                  onPressed: isSubmitting ? null : _submit,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: AppTypography.titleMedium.copyWith(
        color: context.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// "Pay the courier in cash at pickup" — the COD payment model, stated up
/// front so the sender knows what confirming later commits them to.
class _CashAtPickupNote extends StatelessWidget {
  const _CashAtPickupNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.banknote,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              context.l10n.sendPackagePricingNote,
              style: AppTypography.bodySmall.copyWith(
                color: context.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
