import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  static const _kOrderConfirmed = 'notif_order_confirmed';
  static const _kOrderShipped = 'notif_order_shipped';
  static const _kOrderDelivered = 'notif_order_delivered';
  static const _kOrderCancelled = 'notif_order_cancelled';
  static const _kFlash = 'notif_flash_sales';
  static const _kPriceDrop = 'notif_price_drops';
  static const _kBackStock = 'notif_back_in_stock';
  static const _kPromo = 'notif_promotional';
  static const _kNewOrders = 'notif_new_orders';
  static const _kListingOk = 'notif_listing_approved';
  static const _kListingNo = 'notif_listing_rejected';
  static const _kLowStock = 'notif_low_stock';
  static const _kPayment = 'notif_payment_received';
  static const _kMessages = 'notif_new_messages';
  static const _kPush = 'notif_push';
  static const _kEmail = 'notif_email';
  static const _kSms = 'notif_sms';

  SharedPreferences? _p;
  bool _loading = true;
  final _vals = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    bool g(String k, bool d) => p.getBool(k) ?? d;
    setState(() {
      _p = p;
      _vals[_kOrderConfirmed] = g(_kOrderConfirmed, true);
      _vals[_kOrderShipped] = g(_kOrderShipped, true);
      _vals[_kOrderDelivered] = g(_kOrderDelivered, true);
      _vals[_kOrderCancelled] = g(_kOrderCancelled, true);
      _vals[_kFlash] = g(_kFlash, true);
      _vals[_kPriceDrop] = g(_kPriceDrop, true);
      _vals[_kBackStock] = g(_kBackStock, false);
      _vals[_kPromo] = g(_kPromo, false);
      _vals[_kNewOrders] = g(_kNewOrders, true);
      _vals[_kListingOk] = g(_kListingOk, true);
      _vals[_kListingNo] = g(_kListingNo, true);
      _vals[_kLowStock] = g(_kLowStock, true);
      _vals[_kPayment] = g(_kPayment, true);
      _vals[_kMessages] = g(_kMessages, true);
      _vals[_kPush] = g(_kPush, true);
      _vals[_kEmail] = g(_kEmail, false);
      _vals[_kSms] = g(_kSms, false);
      _loading = false;
    });
  }

  Future<void> _set(String k, bool v) async {
    setState(() => _vals[k] = v);
    await _p?.setBool(k, v);
  }

  Future<void> _savePressed() async {
    if (_p == null) return;
    for (final e in _vals.entries) {
      await _p!.setBool(e.key, e.value);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.notificationSettingsSaved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authProvider).valueOrNull?.role ?? UserRole.consumer;
    final isVendor = role == UserRole.vendor;
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator.adaptive()));
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.notificationSettingsTitle, style: AppTypography.titleMedium),
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (!isVendor) ...[
            _Section(title: AppStrings.notificationSettingsSectionOrders, children: [
              _Row(icon: LucideIcons.checkCircle2, label: AppStrings.notificationSettingsOrderConfirmed, value: _vals[_kOrderConfirmed]!, onChanged: (v) => _set(_kOrderConfirmed, v)),
              _Row(icon: LucideIcons.truck, label: AppStrings.notificationSettingsOrderShipped, value: _vals[_kOrderShipped]!, onChanged: (v) => _set(_kOrderShipped, v)),
              _Row(icon: LucideIcons.home, label: AppStrings.notificationSettingsOrderDelivered, value: _vals[_kOrderDelivered]!, onChanged: (v) => _set(_kOrderDelivered, v)),
              _Row(icon: LucideIcons.xCircle, label: AppStrings.notificationSettingsOrderCancelled, value: _vals[_kOrderCancelled]!, onChanged: (v) => _set(_kOrderCancelled, v)),
            ]),
            _Section(title: AppStrings.notificationSettingsSectionDeals, children: [
              _Row(icon: LucideIcons.zap, label: AppStrings.notificationSettingsFlashSales, value: _vals[_kFlash]!, onChanged: (v) => _set(_kFlash, v)),
              _Row(icon: LucideIcons.trendingDown, label: AppStrings.notificationSettingsPriceDrops, value: _vals[_kPriceDrop]!, onChanged: (v) => _set(_kPriceDrop, v)),
              _Row(icon: LucideIcons.refreshCw, label: AppStrings.notificationSettingsBackInStock, value: _vals[_kBackStock]!, onChanged: (v) => _set(_kBackStock, v)),
              _Row(icon: LucideIcons.tag, label: AppStrings.notificationSettingsPromotional, value: _vals[_kPromo]!, onChanged: (v) => _set(_kPromo, v)),
            ]),
          ],
          if (isVendor)
            _Section(title: AppStrings.notificationSettingsSectionStore, children: [
              _Row(icon: LucideIcons.shoppingBag, label: AppStrings.notificationSettingsNewOrders, value: _vals[_kNewOrders]!, onChanged: (v) => _set(_kNewOrders, v)),
              _Row(icon: LucideIcons.checkCircle2, label: AppStrings.notificationSettingsListingApproved, value: _vals[_kListingOk]!, onChanged: (v) => _set(_kListingOk, v)),
              _Row(icon: LucideIcons.xCircle, label: AppStrings.notificationSettingsListingRejected, value: _vals[_kListingNo]!, onChanged: (v) => _set(_kListingNo, v)),
              _Row(icon: LucideIcons.alertTriangle, label: AppStrings.notificationSettingsLowStock, value: _vals[_kLowStock]!, onChanged: (v) => _set(_kLowStock, v)),
              _Row(icon: LucideIcons.creditCard, label: AppStrings.notificationSettingsPaymentReceived, value: _vals[_kPayment]!, onChanged: (v) => _set(_kPayment, v)),
            ]),
          _Section(title: AppStrings.notificationSettingsSectionMessages, children: [
            _Row(icon: LucideIcons.messageCircle, label: AppStrings.notificationSettingsNewMessages, value: _vals[_kMessages]!, onChanged: (v) => _set(_kMessages, v)),
          ]),
          _Section(title: AppStrings.notificationSettingsSectionDelivery, children: [
            _Row(icon: LucideIcons.bell, label: AppStrings.notificationSettingsPush, value: _vals[_kPush]!, onChanged: (v) => _set(_kPush, v)),
            _Row(icon: LucideIcons.mail, label: AppStrings.notificationSettingsEmail, value: _vals[_kEmail]!, onChanged: (v) => _set(_kEmail, v)),
            _Row(icon: LucideIcons.smartphone, label: AppStrings.notificationSettingsSms, value: _vals[_kSms]!, onChanged: (v) => _set(_kSms, v)),
          ]),
          const SizedBox(height: AppSpacing.x2l),
          FilledButton(
            onPressed: _savePressed,
            child: const Text(AppStrings.notificationSettingsSave),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x2l),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.04),
              blurRadius: AppSpacing.sm,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xs),
              child: Text(title, style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: AppTypography.bodyMedium),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary.withValues(alpha: 0.45),
        activeThumbColor: AppColors.white,
      ),
    );
  }
}
