import 'package:url_launcher/url_launcher.dart';

const String xstoreWebsiteOrigin = 'https://xstore-website.vercel.app';
const String xstoreTermsUrl = '$xstoreWebsiteOrigin/en/terms';
const String xstorePrivacyUrl = '$xstoreWebsiteOrigin/en/privacy';

/// Public marketing URL to put in share sheets. The website has no
/// `/wishlist` page, and `xstore.app` is a parked lander — download is
/// the live page a recipient can actually open.
String xstoreDownloadUrl({required bool isArabic}) =>
    '$xstoreWebsiteOrigin/${isArabic ? 'ar' : 'en'}/download';

Future<bool> launchLegalUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await canLaunchUrl(uri)) return false;
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
