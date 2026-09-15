import 'package:url_launcher/url_launcher.dart';

const String xstoreTermsUrl = 'https://xstore-website.vercel.app/en/terms';
const String xstorePrivacyUrl = 'https://xstore-website.vercel.app/en/privacy';

Future<bool> launchLegalUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await canLaunchUrl(uri)) return false;
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
