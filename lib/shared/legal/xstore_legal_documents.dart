/// Operational in-app Terms / Privacy. Counsel still has to fill company
/// registration, return window, and an official Arabic legal translation.
class LegalSection {
  const LegalSection(this.title, this.body);

  final String title;
  final String body;
}

const xstoreTermsEn = <LegalSection>[
  LegalSection(
    '1. Marketplace',
    'xStore is a marketplace in Egypt. We connect buyers and vendors. '
        'We are not the seller of vendor listings. The sale contract is '
        'between the buyer and the vendor. Prices are in Egyptian pounds (EGP).',
  ),
  LegalSection(
    '2. Eligibility',
    'You must be at least 18 and able to enter a contract under Egyptian law. '
        'The app is intended for use in the Arab Republic of Egypt.',
  ),
  LegalSection(
    '3. Accounts',
    'Most features need an account (phone OTP, email/password, or a supported '
        'social sign-in). Keep your details accurate. You are responsible for '
        'activity on your account. You can request deletion from Profile.',
  ),
  LegalSection(
    '4. Vendors',
    'Listings are reviewed by xStore before they go live. Describe products '
        'truthfully (price in EGP, condition, stock, photos). Honor confirmed '
        'orders. Fees, if any, are shown in the vendor tools — they are never '
        'added on top of the buyer price.',
  ),
  LegalSection(
    '5. Orders and payment',
    'Placing an order is an offer to buy from the vendor. Launch payment is '
        'cash on delivery (COD) only. Pay the courier or vendor when the order '
        'arrives. Do not send card numbers, CVV, or bank details through xStore.',
  ),
  LegalSection(
    '6. Cancellations and returns',
    'You may cancel an order in the app before it ships, where that action is '
        'available. Statutory consumer rights under Egyptian Consumer Protection '
        'Law No. 181 of 2018 are not waived. In-app return requests will follow '
        'once that flow ships; until then contact the vendor via WhatsApp on '
        'the order or store page.',
  ),
  LegalSection(
    '7. Prohibited use',
    'Do not list or buy illegal goods, counterfeits, weapons, drugs, or other '
        'items forbidden under Egyptian law. Do not harass users, scrape the '
        'app, or circumvent fees or listing approval.',
  ),
  LegalSection(
    '8. Liability',
    'xStore provides the platform as available. Vendors are responsible for '
        'their products and fulfillment. Nothing here limits rights that '
        'Egyptian law does not allow us to exclude.',
  ),
  LegalSection(
    '9. Governing law',
    'These terms are governed by the laws of the Arab Republic of Egypt. '
        'Company registration, support email, and a counsel-finalized version '
        'will replace this operational draft before store release.',
  ),
];

const xstoreTermsAr = <LegalSection>[
  LegalSection(
    '١. طبيعة المنصة',
    'xStore سوق إلكتروني في مصر يربط المشتري بالبائع. إحنا مش البائع للمنتجات '
        'المعروضة. عقد البيع بين المشتري والبائع. الأسعار بالجنيه المصري.',
  ),
  LegalSection(
    '٢. الأهلية',
    'لازم يكون عمرك ١٨ سنة على الأقل وتكون مؤهل تتعاقد حسب القانون المصري. '
        'التطبيق مخصص للاستخدام في جمهورية مصر العربية.',
  ),
  LegalSection(
    '٣. الحسابات',
    'معظم المميزات محتاجة حساب (OTP موبايل، إيميل/باسورد، أو تسجيل اجتماعي '
        'مدعوم). حافظ على بياناتك صحيحة. تقدر تطلب حذف الحساب من الملف الشخصي.',
  ),
  LegalSection(
    '٤. البائعون',
    'الإعلانات بتتعرض للمراجعة قبل النشر. وصف المنتج لازم يكون صادق (السعر '
        'بالجنيه، الحالة، المخزون، الصور). العمولة — لو موجودة — بتتحسب على '
        'البائع ومش بتتنزل زيادة على سعر المشتري.',
  ),
  LegalSection(
    '٥. الطلبات والدفع',
    'تأكيد الطلب عرض شراء من البائع. الدفع عند الإطلاق كاش عند الاستلام فقط. '
        'متبعتش رقم بطاقة أو CVV أو بيانات بنك من خلال التطبيق.',
  ),
  LegalSection(
    '٦. الإلغاء والإرجاع',
    'تقدر تلغي الطلب من التطبيق قبل الشحن لو الإجراء متاح. حقوقك حسب قانون '
        'حماية المستهلك رقم ١٨١ لسنة ٢٠١٨ مش هتتنازل عنها. طلب الإرجاع من جوه '
        'التطبيق لسه هيتعمل؛ دلوقتي تواصل مع البائع واتساب من صفحة الطلب أو المتجر.',
  ),
  LegalSection(
    '٧. الاستخدام الممنوع',
    'ممنوع عرض أو شراء سلع غير قانونية أو مقلدة أو أسلحة أو مخدرات أو أي بند '
        'محظور في القانون المصري.',
  ),
  LegalSection(
    '٨. المسؤولية',
    'المنصة بتتعمل "كما هي". البائع مسؤول عن منتجاته وتنفيذ الطلب. مفيش هنا '
        'ما يحد حقوق مش مسموح استبعادها في القانون المصري.',
  ),
  LegalSection(
    '٩. القانون الواجب التطبيق',
    'البنود دي خاضعة لقوانين جمهورية مصر العربية. بيانات الشركة والسجل '
        'التجاري والنسخة القانونية النهائية هتتضاف قبل نشر المتاجر.',
  ),
];

const xstorePrivacyEn = <LegalSection>[
  LegalSection(
    '1. Who we are',
    'xStore operates this marketplace app. For Egypt’s Personal Data Protection '
        'Law No. 151 of 2020 we act as the data controller of account and order '
        'data you submit in the app.',
  ),
  LegalSection(
    '2. Data we collect',
    'Account: name, email, Egyptian mobile number, role (buyer/vendor), password '
        'or sign-in tokens. Profile and store details you enter. Orders: delivery '
        'address, recipient phone, items, notes. Device: app version, language, '
        'and approximate location (latitude/longitude headers used so nearby '
        'listings can load). We do not collect card PAN, CVV, or bank details.',
  ),
  LegalSection(
    '3. How we use it',
    'To run your account, verify your phone, place and fulfill COD orders, show '
        'relevant listings, send order notifications, prevent fraud, and improve '
        'the app. Approximate location is used for catalog search, not ads.',
  ),
  LegalSection(
    '4. Sharing',
    'When you order, the vendor receives what they need to deliver (name, '
        'address, phone, items). Couriers receive what they need after an order '
        'is confirmed. We use processors such as hosting, authentication, and '
        'push (e.g. Firebase). We do not sell your personal data.',
  ),
  LegalSection(
    '5. Analytics',
    'The app queues product-analytics events (views, checkout, purchase) to '
        'xStore’s own collector when that route is live. This is not advertising '
        'tracking and is not sold to ad networks.',
  ),
  LegalSection(
    '6. Retention and security',
    'We keep data while your account is open and as needed for orders, disputes, '
        'and legal obligations, then delete or anonymize it. Transport uses TLS. '
        'Auth tokens stay on device.',
  ),
  LegalSection(
    '7. Your rights',
    'You may access and correct profile data in the app, and delete your account '
        'from Profile. You may withdraw marketing consent in Notification '
        'settings (on this device until a server sync exists). You may also '
        'contact the competent Egyptian authority.',
  ),
  LegalSection(
    '8. Children',
    'The app is not for anyone under 18. We do not knowingly collect data from '
        'minors.',
  ),
];

const xstorePrivacyAr = <LegalSection>[
  LegalSection(
    '١. مين إحنا',
    'xStore تشغّل تطبيق السوق. حسب قانون حماية البيانات الشخصية رقم ١٥١ لسنة '
        '٢٠٢٠، إحنا المتحكم في بيانات الحساب والطلبات اللي بتدخلها في التطبيق.',
  ),
  LegalSection(
    '٢. البيانات اللي بنجمعها',
    'الحساب: الاسم، الإيميل، رقم موبايل مصري، الدور (مشتري/بائع)، وكلمة السر '
        'أو توكن الدخول. بيانات الملف والمتجر. الطلبات: عنوان التوصيل، موبايل '
        'المستلم، الأصناف، الملاحظات. الجهاز: إصدار التطبيق واللغة والموقع '
        'التقريبي (خطوط طول/عرض عشان الكتالوج القريب يشتغل). مش بنجمع رقم '
        'بطاقة أو CVV أو بيانات بنك.',
  ),
  LegalSection(
    '٣. الاستخدام',
    'تشغيل الحساب، تأكيد الموبايل، تنفيذ طلبات الكاش عند الاستلام، عرض الإعلانات '
        'المناسبة، إشعارات الطلب، ومنع الاحتيال. الموقع التقريبي للكتالوج مش '
        'للإعلانات.',
  ),
  LegalSection(
    '٤. المشاركة',
    'عند الطلب، البائع بياخد اللي يحتاجه للتوصيل (الاسم، العنوان، الموبايل، '
        'الأصناف). المندوب بياخد بياناته بعد تأكيد الطلب. بنستخدم خدمات استضافة '
        'وتسجيل وإشعارات (مثل Firebase). مش بنبيع بياناتك.',
  ),
  LegalSection(
    '٥. التحليلات',
    'التطبيق بيصف أحداث المنتج (مشاهدة، دفع، شراء) لمجمّع xStore لما المسار '
        'يشتغل. ده مش تتبع إعلاني ومش بيتباع لشبكات إعلانات.',
  ),
  LegalSection(
    '٦. الاحتفاظ والأمان',
    'بنحتفظ بالبيانات طول ما الحساب مفتوح وحسب الطلبات والنزاعات والالتزامات '
        'القانونية، وبعدين بنحذفها أو نجهّلها. النقل بـ TLS. توكن الدخول على الجهاز.',
  ),
  LegalSection(
    '٧. حقوقك',
    'تقدر تعرض وتعدل بيانات الملف من التطبيق، وتحذف الحساب من الملف الشخصي. '
        'تقدر توقف الرسائل التسويقية من إعدادات الإشعارات (على الجهاز ده لحد ما '
        'يحصل مزامنة مع السيرفر).',
  ),
  LegalSection(
    '٨. الأطفال',
    'التطبيق مش لمن هم دون ١٨ سنة. مش بنجمع بيانات قاصرين عن قصد.',
  ),
];
