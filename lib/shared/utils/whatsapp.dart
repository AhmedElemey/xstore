import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/validators.dart';

/// Digits for `wa.me` from an Egyptian phone (local `01…` or `+20…`).
String? whatsAppDigits(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final digits = AppValidators.toE164Egypt(raw).replaceAll(RegExp(r'\D'), '');
  if (digits.length < 11) return null;
  return digits;
}

Future<bool> launchWhatsApp({
  required String phone,
  String? prefilledText,
}) async {
  final digits = whatsAppDigits(phone);
  if (digits == null) return false;
  final uri = Uri.parse(
    prefilledText == null || prefilledText.trim().isEmpty
        ? 'https://wa.me/$digits'
        : 'https://wa.me/$digits?text=${Uri.encodeComponent(prefilledText)}',
  );
  if (!await canLaunchUrl(uri)) return false;
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
