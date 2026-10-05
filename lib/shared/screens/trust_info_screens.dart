import 'package:flutter/material.dart';

import '../../core/utils/extensions/context_extensions.dart';
import '../legal/xstore_legal_documents.dart';
import 'legal_document_screen.dart';

class TermsInfoScreen extends StatelessWidget {
  const TermsInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return LegalDocumentScreen(
      title: context.l10n.menuTerms,
      sections: isAr ? xstoreTermsAr : xstoreTermsEn,
    );
  }
}

class PrivacyInfoScreen extends StatelessWidget {
  const PrivacyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return LegalDocumentScreen(
      title: context.l10n.menuPrivacy,
      sections: isAr ? xstorePrivacyAr : xstorePrivacyEn,
    );
  }
}
