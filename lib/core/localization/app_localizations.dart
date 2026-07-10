import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'xStore'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Buy & Sell Anything'**
  String get tagline;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @signInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInPrompt;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @phoneInvalidLength.
  ///
  /// In en, this message translates to:
  /// **'Must be 11 digits'**
  String get phoneInvalidLength;

  /// No description provided for @phoneInvalidPrefix.
  ///
  /// In en, this message translates to:
  /// **'Must start with 010, 011, 012, or 015'**
  String get phoneInvalidPrefix;

  /// No description provided for @phoneInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get phoneInvalidNumber;

  /// No description provided for @phoneTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get phoneTooManyRequests;

  /// No description provided for @sendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get sendVerificationCode;

  /// No description provided for @verifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify & Continue'**
  String get verifyAndContinue;

  /// No description provided for @verifyYourNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get verifyYourNumber;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Code sent to'**
  String get codeSentTo;

  /// No description provided for @changeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeNumber;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in'**
  String get resendCodeIn;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @otpInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Incorrect code. Please try again.'**
  String get otpInvalidCode;

  /// No description provided for @otpSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Code expired. Request a new one.'**
  String get otpSessionExpired;

  /// No description provided for @smsRatesNote.
  ///
  /// In en, this message translates to:
  /// **'Standard SMS rates may apply'**
  String get smsRatesNote;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get noInternet;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @emailTab.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailTab;

  /// No description provided for @phoneTab.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneTab;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get continueWithFacebook;

  /// No description provided for @socialLoginDivider.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get socialLoginDivider;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @chooseYourRole.
  ///
  /// In en, this message translates to:
  /// **'How will you use xStore?'**
  String get chooseYourRole;

  /// No description provided for @socialRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One last step — choose your account type'**
  String get socialRoleSubtitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchHint;

  /// No description provided for @hotDeals.
  ///
  /// In en, this message translates to:
  /// **'🔥 Hot Deals'**
  String get hotDeals;

  /// No description provided for @newArrivals.
  ///
  /// In en, this message translates to:
  /// **'✨ New Arrivals'**
  String get newArrivals;

  /// No description provided for @flashSale.
  ///
  /// In en, this message translates to:
  /// **'⚡ Flash Sale'**
  String get flashSale;

  /// No description provided for @flashSaleBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Flash sale — limited time offers inside'**
  String get flashSaleBannerBody;

  /// No description provided for @shopByCategory.
  ///
  /// In en, this message translates to:
  /// **'Shop by Category'**
  String get shopByCategory;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'👤 Recommended for You'**
  String get recommended;

  /// No description provided for @recommendedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Based on your browsing'**
  String get recommendedSubtitle;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @seeAllReviews.
  ///
  /// In en, this message translates to:
  /// **'See All Reviews'**
  String get seeAllReviews;

  /// No description provided for @freeShippingBadge.
  ///
  /// In en, this message translates to:
  /// **'🚚 Free Shipping'**
  String get freeShippingBadge;

  /// No description provided for @securePayBadge.
  ///
  /// In en, this message translates to:
  /// **'🔒 Secure Pay'**
  String get securePayBadge;

  /// No description provided for @easyReturnsBadge.
  ///
  /// In en, this message translates to:
  /// **'↩️ Easy Returns'**
  String get easyReturnsBadge;

  /// No description provided for @shopNow.
  ///
  /// In en, this message translates to:
  /// **'Shop Now'**
  String get shopNow;

  /// No description provided for @categoryQueryMens.
  ///
  /// In en, this message translates to:
  /// **'mens_fashion'**
  String get categoryQueryMens;

  /// No description provided for @categoryQueryWomens.
  ///
  /// In en, this message translates to:
  /// **'womens_fashion'**
  String get categoryQueryWomens;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsNoMore.
  ///
  /// In en, this message translates to:
  /// **'No more notifications'**
  String get notificationsNoMore;

  /// No description provided for @notificationsShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get notificationsShowAll;

  /// No description provided for @notificationsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notificationsFilterAll;

  /// No description provided for @notificationsFilterOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get notificationsFilterOrders;

  /// No description provided for @notificationsFilterDeals.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get notificationsFilterDeals;

  /// No description provided for @notificationsFilterListings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get notificationsFilterListings;

  /// No description provided for @notificationsFilterMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get notificationsFilterMessages;

  /// No description provided for @notificationsFilterSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get notificationsFilterSystem;

  /// No description provided for @notificationsSwipeDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get notificationsSwipeDelete;

  /// No description provided for @notificationsSwipeMarkRead.
  ///
  /// In en, this message translates to:
  /// **'Mark Read'**
  String get notificationsSwipeMarkRead;

  /// No description provided for @notificationsMenuMarkRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as Read'**
  String get notificationsMenuMarkRead;

  /// No description provided for @notificationsMenuMarkUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark as Unread'**
  String get notificationsMenuMarkUnread;

  /// No description provided for @notificationsMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get notificationsMenuDelete;

  /// No description provided for @notificationsMenuCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get notificationsMenuCopy;

  /// No description provided for @notificationsCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get notificationsCopied;

  /// No description provided for @notificationsUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get notificationsUndo;

  /// No description provided for @notificationsGroupToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get notificationsGroupToday;

  /// No description provided for @notificationsGroupYesterday.
  ///
  /// In en, this message translates to:
  /// **'YESTERDAY'**
  String get notificationsGroupYesterday;

  /// No description provided for @notificationsGroupThisWeek.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK'**
  String get notificationsGroupThisWeek;

  /// No description provided for @notificationsGroupEarlier.
  ///
  /// In en, this message translates to:
  /// **'EARLIER'**
  String get notificationsGroupEarlier;

  /// No description provided for @notificationsTimeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get notificationsTimeJustNow;

  /// No description provided for @notificationsTimeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notificationsTimeYesterday;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationSettingsTitle;

  /// No description provided for @notificationSettingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save Preferences'**
  String get notificationSettingsSave;

  /// No description provided for @notificationSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Preferences saved'**
  String get notificationSettingsSaved;

  /// No description provided for @notificationSettingsSectionOrders.
  ///
  /// In en, this message translates to:
  /// **'Order updates'**
  String get notificationSettingsSectionOrders;

  /// No description provided for @notificationSettingsSectionDeals.
  ///
  /// In en, this message translates to:
  /// **'Deals & offers'**
  String get notificationSettingsSectionDeals;

  /// No description provided for @notificationSettingsSectionStore.
  ///
  /// In en, this message translates to:
  /// **'Store updates'**
  String get notificationSettingsSectionStore;

  /// No description provided for @notificationSettingsSectionMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get notificationSettingsSectionMessages;

  /// No description provided for @notificationSettingsSectionDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get notificationSettingsSectionDelivery;

  /// No description provided for @notificationSettingsOrderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed'**
  String get notificationSettingsOrderConfirmed;

  /// No description provided for @notificationSettingsOrderShipped.
  ///
  /// In en, this message translates to:
  /// **'Order shipped'**
  String get notificationSettingsOrderShipped;

  /// No description provided for @notificationSettingsOrderDelivered.
  ///
  /// In en, this message translates to:
  /// **'Order delivered'**
  String get notificationSettingsOrderDelivered;

  /// No description provided for @notificationSettingsOrderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get notificationSettingsOrderCancelled;

  /// No description provided for @notificationSettingsFlashSales.
  ///
  /// In en, this message translates to:
  /// **'Flash sales'**
  String get notificationSettingsFlashSales;

  /// No description provided for @notificationSettingsPriceDrops.
  ///
  /// In en, this message translates to:
  /// **'Price drops'**
  String get notificationSettingsPriceDrops;

  /// No description provided for @notificationSettingsBackInStock.
  ///
  /// In en, this message translates to:
  /// **'Back in stock'**
  String get notificationSettingsBackInStock;

  /// No description provided for @notificationSettingsPromotional.
  ///
  /// In en, this message translates to:
  /// **'Promotional offers'**
  String get notificationSettingsPromotional;

  /// No description provided for @notificationSettingsNewOrders.
  ///
  /// In en, this message translates to:
  /// **'New orders'**
  String get notificationSettingsNewOrders;

  /// No description provided for @notificationSettingsListingApproved.
  ///
  /// In en, this message translates to:
  /// **'Listing approved'**
  String get notificationSettingsListingApproved;

  /// No description provided for @notificationSettingsListingRejected.
  ///
  /// In en, this message translates to:
  /// **'Listing rejected'**
  String get notificationSettingsListingRejected;

  /// No description provided for @notificationSettingsLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock alerts'**
  String get notificationSettingsLowStock;

  /// No description provided for @notificationSettingsPaymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment received'**
  String get notificationSettingsPaymentReceived;

  /// No description provided for @notificationSettingsNewMessages.
  ///
  /// In en, this message translates to:
  /// **'New messages'**
  String get notificationSettingsNewMessages;

  /// No description provided for @notificationSettingsPush.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get notificationSettingsPush;

  /// No description provided for @notificationSettingsEmail.
  ///
  /// In en, this message translates to:
  /// **'Email notifications'**
  String get notificationSettingsEmail;

  /// No description provided for @notificationSettingsSms.
  ///
  /// In en, this message translates to:
  /// **'SMS notifications'**
  String get notificationSettingsSms;

  /// No description provided for @addListing.
  ///
  /// In en, this message translates to:
  /// **'Add Listing'**
  String get addListing;

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get myListings;

  /// No description provided for @publishListing.
  ///
  /// In en, this message translates to:
  /// **'🚀 Publish Listing'**
  String get publishListing;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get saveDraft;

  /// No description provided for @listingDraftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get listingDraftSaved;

  /// No description provided for @newListing.
  ///
  /// In en, this message translates to:
  /// **'New Listing'**
  String get newListing;

  /// No description provided for @listingPhotoSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Photos'**
  String get listingPhotoSectionTitle;

  /// No description provided for @listingPhotoSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add 1–5 photos (first = cover)'**
  String get listingPhotoSectionSubtitle;

  /// No description provided for @listingAddPhotoTile.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get listingAddPhotoTile;

  /// No description provided for @listingPhotoCoverBadge.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get listingPhotoCoverBadge;

  /// No description provided for @listingTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'📷 Take a Photo'**
  String get listingTakePhoto;

  /// No description provided for @listingChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'🖼️ Choose from Gallery'**
  String get listingChooseFromGallery;

  /// No description provided for @listingSectionBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get listingSectionBasicInfo;

  /// No description provided for @listingProductNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Product name *'**
  String get listingProductNameLabel;

  /// No description provided for @listingProductNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. iPhone 15 Pro Max 256GB'**
  String get listingProductNameHint;

  /// No description provided for @listingPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price *'**
  String get listingPriceLabel;

  /// No description provided for @commissionYouEarn.
  ///
  /// In en, this message translates to:
  /// **'You earn'**
  String get commissionYouEarn;

  /// No description provided for @commissionPlatformFee.
  ///
  /// In en, this message translates to:
  /// **'Platform fee'**
  String get commissionPlatformFee;

  /// No description provided for @commissionStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Commission status'**
  String get commissionStatusLabel;

  /// No description provided for @commissionStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get commissionStatusPending;

  /// No description provided for @commissionStatusDue.
  ///
  /// In en, this message translates to:
  /// **'Due on delivery'**
  String get commissionStatusDue;

  /// No description provided for @commissionStatusSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get commissionStatusSettled;

  /// No description provided for @commissionStatusVoided.
  ///
  /// In en, this message translates to:
  /// **'Voided'**
  String get commissionStatusVoided;

  /// No description provided for @commissionWalletWarnTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay your platform fees soon'**
  String get commissionWalletWarnTitle;

  /// No description provided for @commissionWalletWarnBody.
  ///
  /// In en, this message translates to:
  /// **'You owe {amount} in platform fees. Pay it off before it reaches {limit} or new listings will be paused.'**
  String commissionWalletWarnBody(String amount, String limit);

  /// No description provided for @commissionWalletPausedTitle.
  ///
  /// In en, this message translates to:
  /// **'New listings are paused'**
  String get commissionWalletPausedTitle;

  /// No description provided for @commissionWalletPausedBody.
  ///
  /// In en, this message translates to:
  /// **'You owe {amount} in platform fees, over the {limit} limit. Pay it off to publish new listings again.'**
  String commissionWalletPausedBody(String amount, String limit);

  /// No description provided for @commissionWalletBlockedSubmit.
  ///
  /// In en, this message translates to:
  /// **'New listings are paused until you pay off your platform fees.'**
  String get commissionWalletBlockedSubmit;

  /// No description provided for @listingCompareAtTitle.
  ///
  /// In en, this message translates to:
  /// **'Compare-at price (optional)'**
  String get listingCompareAtTitle;

  /// No description provided for @listingCompareAtHelper.
  ///
  /// In en, this message translates to:
  /// **'Original price for discount display'**
  String get listingCompareAtHelper;

  /// No description provided for @listingCompareAtWarning.
  ///
  /// In en, this message translates to:
  /// **'Compare-at price is lower than your selling price.'**
  String get listingCompareAtWarning;

  /// No description provided for @listingDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description *'**
  String get listingDescriptionLabel;

  /// No description provided for @listingDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your product — condition, features, what\'s included...'**
  String get listingDescriptionHint;

  /// No description provided for @listingSectionCategoryDetails.
  ///
  /// In en, this message translates to:
  /// **'Category & Details'**
  String get listingSectionCategoryDetails;

  /// No description provided for @listingFormCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category *'**
  String get listingFormCategoryLabel;

  /// No description provided for @listingFormCategoryPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get listingFormCategoryPickerTitle;

  /// No description provided for @listingFormSubcategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Subcategory *'**
  String get listingFormSubcategoryLabel;

  /// No description provided for @listingSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get listingSelectCategory;

  /// No description provided for @listingSelectSubcategory.
  ///
  /// In en, this message translates to:
  /// **'Select subcategory'**
  String get listingSelectSubcategory;

  /// No description provided for @listingConditionFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Condition *'**
  String get listingConditionFieldLabel;

  /// No description provided for @listingBrandOptional.
  ///
  /// In en, this message translates to:
  /// **'Brand (optional)'**
  String get listingBrandOptional;

  /// No description provided for @listingBrandHint.
  ///
  /// In en, this message translates to:
  /// **'Start typing…'**
  String get listingBrandHint;

  /// No description provided for @listingSectionStockShipping.
  ///
  /// In en, this message translates to:
  /// **'Stock & Shipping'**
  String get listingSectionStockShipping;

  /// No description provided for @listingFormLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location *'**
  String get listingFormLocationLabel;

  /// No description provided for @listingFormLocationHint.
  ///
  /// In en, this message translates to:
  /// **'City, Region'**
  String get listingFormLocationHint;

  /// No description provided for @listingShippingAvailable.
  ///
  /// In en, this message translates to:
  /// **'Shipping available?'**
  String get listingShippingAvailable;

  /// No description provided for @listingShippingCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping cost *'**
  String get listingShippingCostLabel;

  /// No description provided for @listingSectionProductAttributes.
  ///
  /// In en, this message translates to:
  /// **'Product Attributes'**
  String get listingSectionProductAttributes;

  /// No description provided for @listingAttributesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add specs like size, color, weight…'**
  String get listingAttributesSubtitle;

  /// No description provided for @listingAttributeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get listingAttributeNameLabel;

  /// No description provided for @listingAttributeValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get listingAttributeValueLabel;

  /// No description provided for @listingAddAttributeButton.
  ///
  /// In en, this message translates to:
  /// **'Add attribute'**
  String get listingAddAttributeButton;

  /// No description provided for @listingCondNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get listingCondNew;

  /// No description provided for @listingCondLikeNew.
  ///
  /// In en, this message translates to:
  /// **'Like New'**
  String get listingCondLikeNew;

  /// No description provided for @listingCondGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get listingCondGood;

  /// No description provided for @listingCondUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get listingCondUsed;

  /// No description provided for @listingCondForParts.
  ///
  /// In en, this message translates to:
  /// **'For Parts'**
  String get listingCondForParts;

  /// No description provided for @listingCatElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get listingCatElectronics;

  /// No description provided for @listingCatFashion.
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get listingCatFashion;

  /// No description provided for @listingCatHomeGarden.
  ///
  /// In en, this message translates to:
  /// **'Home & Garden'**
  String get listingCatHomeGarden;

  /// No description provided for @listingCatBeauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get listingCatBeauty;

  /// No description provided for @listingCatSports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get listingCatSports;

  /// No description provided for @listingCatToys.
  ///
  /// In en, this message translates to:
  /// **'Toys'**
  String get listingCatToys;

  /// No description provided for @listingCatAutomotive.
  ///
  /// In en, this message translates to:
  /// **'Automotive'**
  String get listingCatAutomotive;

  /// No description provided for @listingCatFoodDrinks.
  ///
  /// In en, this message translates to:
  /// **'Food & Drinks'**
  String get listingCatFoodDrinks;

  /// No description provided for @listingCatBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get listingCatBooks;

  /// No description provided for @listingCatOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get listingCatOther;

  /// No description provided for @listingSubElectronicsPhones.
  ///
  /// In en, this message translates to:
  /// **'Phones & tablets'**
  String get listingSubElectronicsPhones;

  /// No description provided for @listingSubElectronicsLaptops.
  ///
  /// In en, this message translates to:
  /// **'Laptops & PCs'**
  String get listingSubElectronicsLaptops;

  /// No description provided for @listingSubElectronicsAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get listingSubElectronicsAudio;

  /// No description provided for @listingSubElectronicsAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get listingSubElectronicsAccessories;

  /// No description provided for @listingSubFashionMens.
  ///
  /// In en, this message translates to:
  /// **'Men\'s'**
  String get listingSubFashionMens;

  /// No description provided for @listingSubFashionWomens.
  ///
  /// In en, this message translates to:
  /// **'Women\'s'**
  String get listingSubFashionWomens;

  /// No description provided for @listingSubFashionKids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get listingSubFashionKids;

  /// No description provided for @listingSubFashionShoes.
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get listingSubFashionShoes;

  /// No description provided for @listingSubHomeFurniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get listingSubHomeFurniture;

  /// No description provided for @listingSubHomeDecor.
  ///
  /// In en, this message translates to:
  /// **'Decor'**
  String get listingSubHomeDecor;

  /// No description provided for @listingSubHomeKitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get listingSubHomeKitchen;

  /// No description provided for @listingSubHomeGarden.
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get listingSubHomeGarden;

  /// No description provided for @listingSubBeautySkincare.
  ///
  /// In en, this message translates to:
  /// **'Skincare'**
  String get listingSubBeautySkincare;

  /// No description provided for @listingSubBeautyMakeup.
  ///
  /// In en, this message translates to:
  /// **'Makeup'**
  String get listingSubBeautyMakeup;

  /// No description provided for @listingSubBeautyHair.
  ///
  /// In en, this message translates to:
  /// **'Hair care'**
  String get listingSubBeautyHair;

  /// No description provided for @listingSubSportsFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get listingSubSportsFitness;

  /// No description provided for @listingSubSportsOutdoor.
  ///
  /// In en, this message translates to:
  /// **'Outdoor'**
  String get listingSubSportsOutdoor;

  /// No description provided for @listingSubSportsTeam.
  ///
  /// In en, this message translates to:
  /// **'Team sports'**
  String get listingSubSportsTeam;

  /// No description provided for @listingSubToysGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get listingSubToysGames;

  /// No description provided for @listingSubToysDolls.
  ///
  /// In en, this message translates to:
  /// **'Dolls & figures'**
  String get listingSubToysDolls;

  /// No description provided for @listingSubToysEducational.
  ///
  /// In en, this message translates to:
  /// **'Educational'**
  String get listingSubToysEducational;

  /// No description provided for @listingSubAutoParts.
  ///
  /// In en, this message translates to:
  /// **'Parts'**
  String get listingSubAutoParts;

  /// No description provided for @listingSubAutoAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get listingSubAutoAccessories;

  /// No description provided for @listingSubAutoCare.
  ///
  /// In en, this message translates to:
  /// **'Care products'**
  String get listingSubAutoCare;

  /// No description provided for @listingSubFoodBeverages.
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get listingSubFoodBeverages;

  /// No description provided for @listingSubFoodSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get listingSubFoodSnacks;

  /// No description provided for @listingSubFoodGrocery.
  ///
  /// In en, this message translates to:
  /// **'Grocery'**
  String get listingSubFoodGrocery;

  /// No description provided for @listingSubBooksFiction.
  ///
  /// In en, this message translates to:
  /// **'Fiction'**
  String get listingSubBooksFiction;

  /// No description provided for @listingSubBooksNonfiction.
  ///
  /// In en, this message translates to:
  /// **'Non-fiction'**
  String get listingSubBooksNonfiction;

  /// No description provided for @listingSubBooksTextbooks.
  ///
  /// In en, this message translates to:
  /// **'Textbooks'**
  String get listingSubBooksTextbooks;

  /// No description provided for @listingSubOtherMisc.
  ///
  /// In en, this message translates to:
  /// **'Miscellaneous'**
  String get listingSubOtherMisc;

  /// No description provided for @vendorAccount.
  ///
  /// In en, this message translates to:
  /// **'Vendor Account'**
  String get vendorAccount;

  /// No description provided for @customerAccount.
  ///
  /// In en, this message translates to:
  /// **'Customer account'**
  String get customerAccount;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @sectionMyActivity.
  ///
  /// In en, this message translates to:
  /// **'MY ACTIVITY'**
  String get sectionMyActivity;

  /// No description provided for @sectionAccountSettings.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT SETTINGS'**
  String get sectionAccountSettings;

  /// No description provided for @sectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get sectionPreferences;

  /// No description provided for @sectionSupport.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get sectionSupport;

  /// No description provided for @sectionDangerZone.
  ///
  /// In en, this message translates to:
  /// **'DANGER ZONE'**
  String get sectionDangerZone;

  /// No description provided for @menuMyListings.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get menuMyListings;

  /// No description provided for @menuMyOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get menuMyOrders;

  /// No description provided for @menuAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get menuAnalytics;

  /// No description provided for @menuEarnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get menuEarnings;

  /// No description provided for @menuWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get menuWishlist;

  /// No description provided for @menuRecentlyViewed.
  ///
  /// In en, this message translates to:
  /// **'Recently Viewed'**
  String get menuRecentlyViewed;

  /// No description provided for @menuMyReviews.
  ///
  /// In en, this message translates to:
  /// **'My Reviews'**
  String get menuMyReviews;

  /// No description provided for @menuPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get menuPersonalInfo;

  /// No description provided for @socialLinks.
  ///
  /// In en, this message translates to:
  /// **'Social links'**
  String get socialLinks;

  /// No description provided for @menuChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get menuChangePassword;

  /// No description provided for @menuNotificationsSettings.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get menuNotificationsSettings;

  /// No description provided for @menuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get menuLanguage;

  /// No description provided for @menuPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get menuPaymentMethods;

  /// No description provided for @menuAddresses.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get menuAddresses;

  /// No description provided for @menuDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get menuDarkMode;

  /// No description provided for @menuPushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get menuPushNotifications;

  /// No description provided for @menuEmailUpdates.
  ///
  /// In en, this message translates to:
  /// **'Email Updates'**
  String get menuEmailUpdates;

  /// No description provided for @menuHelpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get menuHelpCenter;

  /// No description provided for @menuTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get menuTerms;

  /// No description provided for @menuPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get menuPrivacy;

  /// No description provided for @menuRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate xStore'**
  String get menuRateApp;

  /// No description provided for @menuShareApp.
  ///
  /// In en, this message translates to:
  /// **'Share xStore'**
  String get menuShareApp;

  /// No description provided for @manageStore.
  ///
  /// In en, this message translates to:
  /// **'Manage Store'**
  String get manageStore;

  /// No description provided for @statSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get statSales;

  /// No description provided for @statSalesShort.
  ///
  /// In en, this message translates to:
  /// **'sales'**
  String get statSalesShort;

  /// No description provided for @statRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get statRating;

  /// No description provided for @statResponse.
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get statResponse;

  /// No description provided for @statOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get statOrders;

  /// No description provided for @statWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get statWishlist;

  /// No description provided for @statTotalSaved.
  ///
  /// In en, this message translates to:
  /// **'Total Saved'**
  String get statTotalSaved;

  /// No description provided for @currencyDzd.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get currencyDzd;

  /// No description provided for @storeInformation.
  ///
  /// In en, this message translates to:
  /// **'Store Information'**
  String get storeInformation;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @emailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddressLabel;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @dateOfBirthLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirthLabel;

  /// No description provided for @locationCityLabel.
  ///
  /// In en, this message translates to:
  /// **'Location / City'**
  String get locationCityLabel;

  /// No description provided for @bioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio / About'**
  String get bioLabel;

  /// No description provided for @bioHint.
  ///
  /// In en, this message translates to:
  /// **'Tell buyers a bit about yourself'**
  String get bioHint;

  /// No description provided for @storeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get storeNameLabel;

  /// No description provided for @storeCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Store Category'**
  String get storeCategoryLabel;

  /// No description provided for @storeDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Store Description'**
  String get storeDescriptionLabel;

  /// No description provided for @storeCityLabel.
  ///
  /// In en, this message translates to:
  /// **'Store City'**
  String get storeCityLabel;

  /// No description provided for @storeWilayaLabel.
  ///
  /// In en, this message translates to:
  /// **'Store Wilaya'**
  String get storeWilayaLabel;

  /// No description provided for @whatsappLabel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Number'**
  String get whatsappLabel;

  /// No description provided for @instagramLabel.
  ///
  /// In en, this message translates to:
  /// **'Instagram handle'**
  String get instagramLabel;

  /// No description provided for @facebookLabel.
  ///
  /// In en, this message translates to:
  /// **'Facebook page'**
  String get facebookLabel;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out of xStore?'**
  String get logoutConfirmTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account permanently'**
  String get deleteAccountDialogTitle;

  /// No description provided for @deleteAccountPermanentWarning.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent'**
  String get deleteAccountPermanentWarning;

  /// No description provided for @deleteAccountTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm'**
  String get deleteAccountTypeHint;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteMyAccount;

  /// No description provided for @deleteConfirmKeyword.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteConfirmKeyword;

  /// No description provided for @choosePhotoSource.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get choosePhotoSource;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get chooseFromGallery;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdatedSuccess;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @profileFooterLine.
  ///
  /// In en, this message translates to:
  /// **'xStore v1.0.0 · Made with ❤️ in Egypt'**
  String get profileFooterLine;

  /// No description provided for @statStoreViews.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get statStoreViews;

  /// No description provided for @statStoreSaves.
  ///
  /// In en, this message translates to:
  /// **'Saves'**
  String get statStoreSaves;

  /// No description provided for @statStoreActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statStoreActive;

  /// No description provided for @storeMetaLinePrefix.
  ///
  /// In en, this message translates to:
  /// **'Since '**
  String get storeMetaLinePrefix;

  /// No description provided for @storeJoinedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Joined '**
  String get storeJoinedPrefix;

  /// No description provided for @followStore.
  ///
  /// In en, this message translates to:
  /// **'Follow Store'**
  String get followStore;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @storeDescriptionHeading.
  ///
  /// In en, this message translates to:
  /// **'About the store'**
  String get storeDescriptionHeading;

  /// No description provided for @allCategoriesChip.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategoriesChip;

  /// No description provided for @vendorStoreStatListings.
  ///
  /// In en, this message translates to:
  /// **'Active Listings'**
  String get vendorStoreStatListings;

  /// No description provided for @vendorStoreStatSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get vendorStoreStatSales;

  /// No description provided for @vendorStoreStatResponse.
  ///
  /// In en, this message translates to:
  /// **'Response Rate'**
  String get vendorStoreStatResponse;

  /// No description provided for @placeholderScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This screen is coming soon.'**
  String get placeholderScreenSubtitle;

  /// No description provided for @trustInfoPaymentMethodsBody.
  ///
  /// In en, this message translates to:
  /// **'Saved payment methods aren\'t available yet. When you check out, you can pay securely with cash on delivery or enter card details for that order only — card details are used during checkout and are not saved here.'**
  String get trustInfoPaymentMethodsBody;

  /// No description provided for @trustInfoAddressesBody.
  ///
  /// In en, this message translates to:
  /// **'A saved address book is coming soon. For now, choose or add your delivery address during checkout before you place an order.'**
  String get trustInfoAddressesBody;

  /// No description provided for @trustInfoTermsBody.
  ///
  /// In en, this message translates to:
  /// **'Our Terms of Service are not published in the app yet. We don\'t show placeholder legal text here. Full terms will appear on this screen before launch.'**
  String get trustInfoTermsBody;

  /// No description provided for @trustInfoPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Our Privacy Policy is not published in the app yet. We don\'t show placeholder legal text here. How we collect and use your data will be documented here before launch.'**
  String get trustInfoPrivacyBody;

  /// No description provided for @trustInfoHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Help articles and live support aren\'t available in the app yet. For order questions, open My Orders. You can manage alerts under Notification settings.'**
  String get trustInfoHelpBody;

  /// No description provided for @trustInfoActionCheckout.
  ///
  /// In en, this message translates to:
  /// **'Go to checkout'**
  String get trustInfoActionCheckout;

  /// No description provided for @trustInfoHelpViewOrders.
  ///
  /// In en, this message translates to:
  /// **'Go to My Orders'**
  String get trustInfoHelpViewOrders;

  /// No description provided for @trustInfoHelpNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get trustInfoHelpNotifications;

  /// No description provided for @iosAppStoreUrl.
  ///
  /// In en, this message translates to:
  /// **'https://apps.apple.com'**
  String get iosAppStoreUrl;

  /// No description provided for @androidPlayStoreUrl.
  ///
  /// In en, this message translates to:
  /// **'https://play.google.com/store'**
  String get androidPlayStoreUrl;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get navWishlist;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navAddListing.
  ///
  /// In en, this message translates to:
  /// **'Add Listing'**
  String get navAddListing;

  /// No description provided for @exploreSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search listings…'**
  String get exploreSearchPlaceholder;

  /// No description provided for @clearAllFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAllFilters;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @addFilters.
  ///
  /// In en, this message translates to:
  /// **'+ Filters'**
  String get addFilters;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetFilters;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get sortOldest;

  /// No description provided for @sortPriceAsc.
  ///
  /// In en, this message translates to:
  /// **'Price ↑'**
  String get sortPriceAsc;

  /// No description provided for @sortPriceDesc.
  ///
  /// In en, this message translates to:
  /// **'Price ↓'**
  String get sortPriceDesc;

  /// No description provided for @sortMostViewed.
  ///
  /// In en, this message translates to:
  /// **'Most Viewed'**
  String get sortMostViewed;

  /// No description provided for @sortRelevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get sortRelevance;

  /// No description provided for @sortByRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get sortByRating;

  /// No description provided for @resultsFor.
  ///
  /// In en, this message translates to:
  /// **'Results for'**
  String get resultsFor;

  /// No description provided for @allListingsLabel.
  ///
  /// In en, this message translates to:
  /// **'All listings'**
  String get allListingsLabel;

  /// No description provided for @noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No listings found'**
  String get noResultsTitle;

  /// No description provided for @noResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try different keywords or filters.'**
  String get noResultsSubtitle;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get priceRange;

  /// No description provided for @minPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get minPriceLabel;

  /// No description provided for @maxPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get maxPriceLabel;

  /// No description provided for @minRating.
  ///
  /// In en, this message translates to:
  /// **'Minimum rating'**
  String get minRating;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @shippingOnly.
  ///
  /// In en, this message translates to:
  /// **'Shipping available'**
  String get shippingOnly;

  /// No description provided for @gridView.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get gridView;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listView;

  /// No description provided for @ratingStars4Plus.
  ///
  /// In en, this message translates to:
  /// **'⭐ 4+'**
  String get ratingStars4Plus;

  /// No description provided for @ratingStars3Plus.
  ///
  /// In en, this message translates to:
  /// **'⭐ 3+'**
  String get ratingStars3Plus;

  /// No description provided for @ratingStars2Plus.
  ///
  /// In en, this message translates to:
  /// **'⭐ 2+'**
  String get ratingStars2Plus;

  /// No description provided for @starChar.
  ///
  /// In en, this message translates to:
  /// **'★'**
  String get starChar;

  /// No description provided for @ordersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersEmptyTitle;

  /// No description provided for @ordersIncomingTitle.
  ///
  /// In en, this message translates to:
  /// **'Incoming Orders'**
  String get ordersIncomingTitle;

  /// No description provided for @ordersMyTitle.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get ordersMyTitle;

  /// No description provided for @ordersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search order or product…'**
  String get ordersSearchHint;

  /// No description provided for @ordersFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ordersFilterAll;

  /// No description provided for @ordersFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get ordersFilterPending;

  /// No description provided for @ordersFilterConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get ordersFilterConfirmed;

  /// No description provided for @ordersFilterProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get ordersFilterProcessing;

  /// No description provided for @ordersFilterShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get ordersFilterShipped;

  /// No description provided for @ordersFilterDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get ordersFilterDelivered;

  /// No description provided for @ordersFilterCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get ordersFilterCancelled;

  /// No description provided for @ordersFilterRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get ordersFilterRefunded;

  /// No description provided for @ordersSortHighestValue.
  ///
  /// In en, this message translates to:
  /// **'Highest Value'**
  String get ordersSortHighestValue;

  /// No description provided for @ordersSortNeedsAction.
  ///
  /// In en, this message translates to:
  /// **'Needs Action'**
  String get ordersSortNeedsAction;

  /// No description provided for @ordersCountLabel.
  ///
  /// In en, this message translates to:
  /// **'orders'**
  String get ordersCountLabel;

  /// No description provided for @ordersStatPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get ordersStatPendingLabel;

  /// No description provided for @ordersStatActiveLabelTitle.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get ordersStatActiveLabelTitle;

  /// No description provided for @ordersStatMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get ordersStatMonthLabel;

  /// No description provided for @ordersStatTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get ordersStatTotalLabel;

  /// No description provided for @ordersMoreItemsSuffix.
  ///
  /// In en, this message translates to:
  /// **'more item'**
  String get ordersMoreItemsSuffix;

  /// No description provided for @ordersMoreItemsSuffixPlural.
  ///
  /// In en, this message translates to:
  /// **'more items'**
  String get ordersMoreItemsSuffixPlural;

  /// No description provided for @ordersQtyTotalLinePrefix.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get ordersQtyTotalLinePrefix;

  /// No description provided for @ordersFromStorePrefix.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get ordersFromStorePrefix;

  /// No description provided for @ordersEstimatedDelivery.
  ///
  /// In en, this message translates to:
  /// **'🚚 Estimated'**
  String get ordersEstimatedDelivery;

  /// No description provided for @ordersPaymentLine.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get ordersPaymentLine;

  /// No description provided for @ordersTrackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get ordersTrackOrder;

  /// No description provided for @ordersViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get ordersViewDetails;

  /// No description provided for @ordersCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get ordersCancelOrder;

  /// No description provided for @ordersConfirmReceipt.
  ///
  /// In en, this message translates to:
  /// **'✓ Confirm Receipt'**
  String get ordersConfirmReceipt;

  /// No description provided for @ordersLeaveReview.
  ///
  /// In en, this message translates to:
  /// **'Leave Review'**
  String get ordersLeaveReview;

  /// No description provided for @ordersReorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get ordersReorder;

  /// No description provided for @ordersRejectOrder.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get ordersRejectOrder;

  /// No description provided for @ordersConfirmOrderCta.
  ///
  /// In en, this message translates to:
  /// **'✓ Confirm Order'**
  String get ordersConfirmOrderCta;

  /// No description provided for @ordersMarkProcessing.
  ///
  /// In en, this message translates to:
  /// **'Mark as Processing'**
  String get ordersMarkProcessing;

  /// No description provided for @ordersMarkShipped.
  ///
  /// In en, this message translates to:
  /// **'Mark as Shipped'**
  String get ordersMarkShipped;

  /// No description provided for @ordersViewTracking.
  ///
  /// In en, this message translates to:
  /// **'View Tracking'**
  String get ordersViewTracking;

  /// No description provided for @ordersShopAgain.
  ///
  /// In en, this message translates to:
  /// **'🛒 Shop Again'**
  String get ordersShopAgain;

  /// No description provided for @ordersEmptyFilteredTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching orders'**
  String get ordersEmptyFilteredTitle;

  /// No description provided for @ordersBrowseProducts.
  ///
  /// In en, this message translates to:
  /// **'Browse Products'**
  String get ordersBrowseProducts;

  /// No description provided for @ordersDetailTitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'Order #'**
  String get ordersDetailTitlePrefix;

  /// No description provided for @ordersShareSummary.
  ///
  /// In en, this message translates to:
  /// **'Share order'**
  String get ordersShareSummary;

  /// No description provided for @ordersSoldBy.
  ///
  /// In en, this message translates to:
  /// **'Sold by'**
  String get ordersSoldBy;

  /// No description provided for @ordersBuyerInfo.
  ///
  /// In en, this message translates to:
  /// **'Buyer Info'**
  String get ordersBuyerInfo;

  /// No description provided for @ordersMessageSeller.
  ///
  /// In en, this message translates to:
  /// **'💬 Message Seller'**
  String get ordersMessageSeller;

  /// No description provided for @ordersMessageSellerSoon.
  ///
  /// In en, this message translates to:
  /// **'Messaging — coming soon'**
  String get ordersMessageSellerSoon;

  /// No description provided for @ordersWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'💬 WhatsApp'**
  String get ordersWhatsapp;

  /// No description provided for @ordersDeliveryAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get ordersDeliveryAddressTitle;

  /// No description provided for @ordersItemsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Items Ordered'**
  String get ordersItemsSectionTitle;

  /// No description provided for @ordersTrackingSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracking Information'**
  String get ordersTrackingSectionTitle;

  /// No description provided for @ordersPaymentSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get ordersPaymentSectionTitle;

  /// No description provided for @ordersNotesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Notes'**
  String get ordersNotesSectionTitle;

  /// No description provided for @ordersSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get ordersSubtotal;

  /// No description provided for @ordersShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get ordersShipping;

  /// No description provided for @ordersDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get ordersDiscount;

  /// No description provided for @ordersTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get ordersTotal;

  /// No description provided for @ordersPaidBadge.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get ordersPaidBadge;

  /// No description provided for @ordersPaymentPendingBadge.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get ordersPaymentPendingBadge;

  /// No description provided for @ordersViewProduct.
  ///
  /// In en, this message translates to:
  /// **'View Product'**
  String get ordersViewProduct;

  /// No description provided for @ordersCopyTracking.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get ordersCopyTracking;

  /// No description provided for @ordersTrackingCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get ordersTrackingCopied;

  /// No description provided for @ordersTrackOnCourier.
  ///
  /// In en, this message translates to:
  /// **'Track on Courier Website'**
  String get ordersTrackOnCourier;

  /// No description provided for @ordersCourierWebsiteSoon.
  ///
  /// In en, this message translates to:
  /// **'Courier tracking — coming soon'**
  String get ordersCourierWebsiteSoon;

  /// No description provided for @ordersCurrentLocationMock.
  ///
  /// In en, this message translates to:
  /// **'In transit — Algiers hub'**
  String get ordersCurrentLocationMock;

  /// No description provided for @ordersExpectedPrefix.
  ///
  /// In en, this message translates to:
  /// **'📅 Expected by'**
  String get ordersExpectedPrefix;

  /// No description provided for @ordersAddTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Tracking Info'**
  String get ordersAddTrackingTitle;

  /// No description provided for @ordersTrackingNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Tracking Number (optional)'**
  String get ordersTrackingNumberLabel;

  /// No description provided for @ordersCourierNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Courier name (optional)'**
  String get ordersCourierNameLabel;

  /// No description provided for @ordersEstimatedDeliveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated delivery'**
  String get ordersEstimatedDeliveryLabel;

  /// No description provided for @ordersConfirmShipment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Shipment'**
  String get ordersConfirmShipment;

  /// No description provided for @ordersCancelDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this order?'**
  String get ordersCancelDialogTitle;

  /// No description provided for @ordersCancelReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get ordersCancelReasonLabel;

  /// No description provided for @ordersCancelReasonChangedMind.
  ///
  /// In en, this message translates to:
  /// **'Changed my mind'**
  String get ordersCancelReasonChangedMind;

  /// No description provided for @ordersCancelReasonBetterPrice.
  ///
  /// In en, this message translates to:
  /// **'Found better price'**
  String get ordersCancelReasonBetterPrice;

  /// No description provided for @ordersCancelReasonMistake.
  ///
  /// In en, this message translates to:
  /// **'Ordered by mistake'**
  String get ordersCancelReasonMistake;

  /// No description provided for @ordersCancelReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get ordersCancelReasonOther;

  /// No description provided for @ordersConfirmReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm receipt?'**
  String get ordersConfirmReceiptTitle;

  /// No description provided for @ordersConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get ordersConfirm;

  /// No description provided for @ordersRejectDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject order'**
  String get ordersRejectDialogTitle;

  /// No description provided for @ordersRejectReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason for rejection'**
  String get ordersRejectReasonHint;

  /// No description provided for @ordersSubmitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get ordersSubmitReview;

  /// No description provided for @ordersReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Tell others about your purchase'**
  String get ordersReviewHint;

  /// No description provided for @ordersReviewThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your review!'**
  String get ordersReviewThanks;

  /// No description provided for @ordersReviewSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get ordersReviewSheetTitle;

  /// No description provided for @ordersPaymentCashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get ordersPaymentCashOnDelivery;

  /// No description provided for @ordersPaymentCib.
  ///
  /// In en, this message translates to:
  /// **'CIB Card'**
  String get ordersPaymentCib;

  /// No description provided for @ordersPaymentDahabi.
  ///
  /// In en, this message translates to:
  /// **'Dahabi Card'**
  String get ordersPaymentDahabi;

  /// No description provided for @ordersPaymentBaridimob.
  ///
  /// In en, this message translates to:
  /// **'BaridiMob'**
  String get ordersPaymentBaridimob;

  /// No description provided for @ordersTimelinePlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get ordersTimelinePlaced;

  /// No description provided for @ordersTimelineConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get ordersTimelineConfirmed;

  /// No description provided for @ordersTimelineProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get ordersTimelineProcessing;

  /// No description provided for @ordersTimelineShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get ordersTimelineShipped;

  /// No description provided for @ordersTimelineDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get ordersTimelineDelivered;

  /// No description provided for @ordersTimelineHeading.
  ///
  /// In en, this message translates to:
  /// **'Order progress'**
  String get ordersTimelineHeading;

  /// No description provided for @ordersTimelinePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get ordersTimelinePending;

  /// No description provided for @ordersCancelReasonSection.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason'**
  String get ordersCancelReasonSection;

  /// No description provided for @statusSubtitlePending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for vendor confirmation'**
  String get statusSubtitlePending;

  /// No description provided for @statusSubtitleConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Vendor confirmed your order'**
  String get statusSubtitleConfirmed;

  /// No description provided for @statusSubtitleProcessing.
  ///
  /// In en, this message translates to:
  /// **'Seller is preparing your order'**
  String get statusSubtitleProcessing;

  /// No description provided for @statusSubtitleShipped.
  ///
  /// In en, this message translates to:
  /// **'Your order is on the way!'**
  String get statusSubtitleShipped;

  /// No description provided for @statusSubtitleDelivered.
  ///
  /// In en, this message translates to:
  /// **'Order delivered successfully'**
  String get statusSubtitleDelivered;

  /// No description provided for @statusSubtitleCancelled.
  ///
  /// In en, this message translates to:
  /// **'This order was cancelled'**
  String get statusSubtitleCancelled;

  /// No description provided for @statusSubtitleRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refund processed'**
  String get statusSubtitleRefunded;

  /// No description provided for @ordersFiltersMoreSoon.
  ///
  /// In en, this message translates to:
  /// **'More filters — coming soon'**
  String get ordersFiltersMoreSoon;

  /// No description provided for @orderHashPrefix.
  ///
  /// In en, this message translates to:
  /// **'Order #'**
  String get orderHashPrefix;

  /// No description provided for @vendorNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get vendorNeedsAttention;

  /// No description provided for @wishlistEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is empty'**
  String get wishlistEmptyTitle;

  /// No description provided for @wishlistDiscoverProducts.
  ///
  /// In en, this message translates to:
  /// **'Discover products'**
  String get wishlistDiscoverProducts;

  /// No description provided for @wishlistForBuyersTitle.
  ///
  /// In en, this message translates to:
  /// **'Wishlist is for Buyers'**
  String get wishlistForBuyersTitle;

  /// No description provided for @wishlistExploreAsBuyer.
  ///
  /// In en, this message translates to:
  /// **'Explore as Buyer'**
  String get wishlistExploreAsBuyer;

  /// No description provided for @wishlistSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get wishlistSelect;

  /// No description provided for @wishlistCancelSelect.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get wishlistCancelSelect;

  /// No description provided for @wishlistSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get wishlistSort;

  /// No description provided for @wishlistSortRecentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently Added'**
  String get wishlistSortRecentlyAdded;

  /// No description provided for @wishlistSortPriceLow.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get wishlistSortPriceLow;

  /// No description provided for @wishlistSortPriceHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get wishlistSortPriceHigh;

  /// No description provided for @wishlistSortPriceDrop.
  ///
  /// In en, this message translates to:
  /// **'Price Drop'**
  String get wishlistSortPriceDrop;

  /// No description provided for @wishlistSortBiggestDiscount.
  ///
  /// In en, this message translates to:
  /// **'Biggest Discount'**
  String get wishlistSortBiggestDiscount;

  /// No description provided for @wishlistSortNameAz.
  ///
  /// In en, this message translates to:
  /// **'Name A–Z'**
  String get wishlistSortNameAz;

  /// No description provided for @wishlistFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get wishlistFilterAll;

  /// No description provided for @wishlistFilterAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get wishlistFilterAvailable;

  /// No description provided for @wishlistFilterPriceDropped.
  ///
  /// In en, this message translates to:
  /// **'Price Dropped'**
  String get wishlistFilterPriceDropped;

  /// No description provided for @wishlistFilterInCart.
  ///
  /// In en, this message translates to:
  /// **'In Cart'**
  String get wishlistFilterInCart;

  /// No description provided for @wishlistViewPriceDrops.
  ///
  /// In en, this message translates to:
  /// **'View Price Drops'**
  String get wishlistViewPriceDrops;

  /// No description provided for @wishlistPriceDropBadge.
  ///
  /// In en, this message translates to:
  /// **'Price Drop'**
  String get wishlistPriceDropBadge;

  /// No description provided for @wishlistOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get wishlistOutOfStock;

  /// No description provided for @wishlistInCartBadge.
  ///
  /// In en, this message translates to:
  /// **'✓ In Cart'**
  String get wishlistInCartBadge;

  /// No description provided for @wishlistRemove.
  ///
  /// In en, this message translates to:
  /// **'♡ Remove'**
  String get wishlistRemove;

  /// No description provided for @wishlistAddToCart.
  ///
  /// In en, this message translates to:
  /// **'🛒 Add to Cart'**
  String get wishlistAddToCart;

  /// No description provided for @wishlistInCartCta.
  ///
  /// In en, this message translates to:
  /// **'✓ In Cart'**
  String get wishlistInCartCta;

  /// No description provided for @wishlistSwipeAddCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get wishlistSwipeAddCart;

  /// No description provided for @wishlistMoveAllToCart.
  ///
  /// In en, this message translates to:
  /// **'Move All to Cart'**
  String get wishlistMoveAllToCart;

  /// No description provided for @wishlistShareWishlist.
  ///
  /// In en, this message translates to:
  /// **'Share Wishlist'**
  String get wishlistShareWishlist;

  /// No description provided for @wishlistViewCart.
  ///
  /// In en, this message translates to:
  /// **'View Cart'**
  String get wishlistViewCart;

  /// No description provided for @wishlistRemoveSelected.
  ///
  /// In en, this message translates to:
  /// **'Remove Selected'**
  String get wishlistRemoveSelected;

  /// No description provided for @wishlistSavedSnack.
  ///
  /// In en, this message translates to:
  /// **'Saved to Wishlist ❤️'**
  String get wishlistSavedSnack;

  /// No description provided for @wishlistView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get wishlistView;

  /// No description provided for @wishlistRemovedSnack.
  ///
  /// In en, this message translates to:
  /// **'Removed from Wishlist'**
  String get wishlistRemovedSnack;

  /// No description provided for @wishlistShowAllItems.
  ///
  /// In en, this message translates to:
  /// **'Show All Items'**
  String get wishlistShowAllItems;

  /// No description provided for @wishlistReviewsWord.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get wishlistReviewsWord;

  /// No description provided for @wishlistGridContentDesc.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get wishlistGridContentDesc;

  /// No description provided for @wishlistListContentDesc.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get wishlistListContentDesc;

  /// No description provided for @wishlistNoAvailableItems.
  ///
  /// In en, this message translates to:
  /// **'No available items'**
  String get wishlistNoAvailableItems;

  /// No description provided for @wishlistNoPriceDroppedItems.
  ///
  /// In en, this message translates to:
  /// **'No price dropped items'**
  String get wishlistNoPriceDroppedItems;

  /// No description provided for @wishlistNoInCartItems.
  ///
  /// In en, this message translates to:
  /// **'No in cart items'**
  String get wishlistNoInCartItems;

  /// No description provided for @wishlistSingleAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get wishlistSingleAddedToCart;

  /// No description provided for @wishlistSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get wishlistSelectAll;

  /// No description provided for @wishlistDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get wishlistDeselectAll;

  /// No description provided for @cartForBuyersTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart is for Buyers'**
  String get cartForBuyersTitle;

  /// No description provided for @cartExploreAsBuyer.
  ///
  /// In en, this message translates to:
  /// **'Explore as Buyer'**
  String get cartExploreAsBuyer;

  /// No description provided for @cartClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear your entire cart?'**
  String get cartClearTitle;

  /// No description provided for @cartClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get cartClearConfirm;

  /// No description provided for @cartSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get cartSelectAll;

  /// No description provided for @cartTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cartTotalLabel;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmptyTitle;

  /// No description provided for @cartStartShopping.
  ///
  /// In en, this message translates to:
  /// **'Start Shopping'**
  String get cartStartShopping;

  /// No description provided for @cartOrWishlist.
  ///
  /// In en, this message translates to:
  /// **'Or check your Wishlist'**
  String get cartOrWishlist;

  /// No description provided for @cartWishlistArrow.
  ///
  /// In en, this message translates to:
  /// **'Wishlist →'**
  String get cartWishlistArrow;

  /// No description provided for @cartRemove.
  ///
  /// In en, this message translates to:
  /// **'🗑 Remove'**
  String get cartRemove;

  /// No description provided for @cartSaveForLater.
  ///
  /// In en, this message translates to:
  /// **'♡ Save for Later'**
  String get cartSaveForLater;

  /// No description provided for @cartUnavailableBadge.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get cartUnavailableBadge;

  /// No description provided for @cartSwipeRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get cartSwipeRemove;

  /// No description provided for @cartUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get cartUndo;

  /// No description provided for @cartShippingFree.
  ///
  /// In en, this message translates to:
  /// **'🚚 Free Shipping'**
  String get cartShippingFree;

  /// No description provided for @cartPickupOnly.
  ///
  /// In en, this message translates to:
  /// **'🚫 Pickup Only'**
  String get cartPickupOnly;

  /// No description provided for @cartPromoHeading.
  ///
  /// In en, this message translates to:
  /// **'🏷️ Have a promo code?'**
  String get cartPromoHeading;

  /// No description provided for @cartCouponHint.
  ///
  /// In en, this message translates to:
  /// **'Enter coupon code…'**
  String get cartCouponHint;

  /// No description provided for @cartApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get cartApply;

  /// No description provided for @cartCouponRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get cartCouponRemove;

  /// No description provided for @cartCouponInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid coupon code'**
  String get cartCouponInvalid;

  /// No description provided for @cartCouponMinOrder.
  ///
  /// In en, this message translates to:
  /// **'Minimum order 5,000 DZD required'**
  String get cartCouponMinOrder;

  /// No description provided for @cartOrderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get cartOrderSummary;

  /// No description provided for @cartShippingLine.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get cartShippingLine;

  /// No description provided for @cartTotalLine.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cartTotalLine;

  /// No description provided for @cartCashOnDeliveryNote.
  ///
  /// In en, this message translates to:
  /// **'💳 Cash on Delivery available'**
  String get cartCashOnDeliveryNote;

  /// No description provided for @cartSecureCheckout.
  ///
  /// In en, this message translates to:
  /// **'🔒 Secure checkout guaranteed'**
  String get cartSecureCheckout;

  /// No description provided for @cartProceedCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get cartProceedCheckout;

  /// No description provided for @cartYouMayAlsoLike.
  ///
  /// In en, this message translates to:
  /// **'You May Also Like'**
  String get cartYouMayAlsoLike;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @checkoutContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get checkoutContinue;

  /// No description provided for @checkoutStepAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get checkoutStepAddress;

  /// No description provided for @checkoutStepPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get checkoutStepPayment;

  /// No description provided for @checkoutStepConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get checkoutStepConfirm;

  /// No description provided for @checkoutDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get checkoutDeliveryTitle;

  /// No description provided for @checkoutAddAddress.
  ///
  /// In en, this message translates to:
  /// **'+ Add New Address'**
  String get checkoutAddAddress;

  /// No description provided for @checkoutSaveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save Address'**
  String get checkoutSaveAddress;

  /// No description provided for @checkoutFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get checkoutFullName;

  /// No description provided for @checkoutPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get checkoutPhone;

  /// No description provided for @checkoutStreet.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get checkoutStreet;

  /// No description provided for @checkoutCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get checkoutCity;

  /// No description provided for @checkoutWilaya.
  ///
  /// In en, this message translates to:
  /// **'Wilaya'**
  String get checkoutWilaya;

  /// No description provided for @checkoutPostalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get checkoutPostalCode;

  /// No description provided for @checkoutSetDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get checkoutSetDefault;

  /// No description provided for @checkoutEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get checkoutEdit;

  /// No description provided for @checkoutPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get checkoutPaymentTitle;

  /// No description provided for @checkoutPayCodTitle.
  ///
  /// In en, this message translates to:
  /// **'💵 Cash on Delivery'**
  String get checkoutPayCodTitle;

  /// No description provided for @checkoutPayCodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pay when your order arrives'**
  String get checkoutPayCodSubtitle;

  /// No description provided for @checkoutPayCibTitle.
  ///
  /// In en, this message translates to:
  /// **'💳 CIB Card'**
  String get checkoutPayCibTitle;

  /// No description provided for @checkoutPayCibSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Debit/Credit card payment'**
  String get checkoutPayCibSubtitle;

  /// No description provided for @checkoutPayDahabiTitle.
  ///
  /// In en, this message translates to:
  /// **'🟡 Dahabicard'**
  String get checkoutPayDahabiTitle;

  /// No description provided for @checkoutPayDahabiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Egypt Post golden card'**
  String get checkoutPayDahabiSubtitle;

  /// No description provided for @checkoutPayBaridiTitle.
  ///
  /// In en, this message translates to:
  /// **'🟢 BaridiMob'**
  String get checkoutPayBaridiTitle;

  /// No description provided for @checkoutPayBaridiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Egypt Post mobile payment'**
  String get checkoutPayBaridiSubtitle;

  /// No description provided for @checkoutCardExpiry.
  ///
  /// In en, this message translates to:
  /// **'MM/YY'**
  String get checkoutCardExpiry;

  /// No description provided for @checkoutCardCvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get checkoutCardCvv;

  /// No description provided for @checkoutCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get checkoutCardNumber;

  /// No description provided for @checkoutDeliveryNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery note (optional)'**
  String get checkoutDeliveryNoteLabel;

  /// No description provided for @checkoutReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Your Order'**
  String get checkoutReviewTitle;

  /// No description provided for @checkoutEstimatedDelivery.
  ///
  /// In en, this message translates to:
  /// **'🚚 Estimated: 3–5 business days'**
  String get checkoutEstimatedDelivery;

  /// No description provided for @checkoutTermsBefore.
  ///
  /// In en, this message translates to:
  /// **'By placing this order you agree to our'**
  String get checkoutTermsBefore;

  /// No description provided for @checkoutTermsAnd.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get checkoutTermsAnd;

  /// No description provided for @checkoutReturnPolicy.
  ///
  /// In en, this message translates to:
  /// **'Return Policy'**
  String get checkoutReturnPolicy;

  /// No description provided for @checkoutPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'🛒 Place Order'**
  String get checkoutPlaceOrder;

  /// No description provided for @checkoutErrorNoAddress.
  ///
  /// In en, this message translates to:
  /// **'Please select or add an address'**
  String get checkoutErrorNoAddress;

  /// No description provided for @checkoutErrorNoPayment.
  ///
  /// In en, this message translates to:
  /// **'Please select a payment method'**
  String get checkoutErrorNoPayment;

  /// No description provided for @checkoutErrorNoItems.
  ///
  /// In en, this message translates to:
  /// **'No items selected for checkout'**
  String get checkoutErrorNoItems;

  /// No description provided for @checkoutErrorCard.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid card number'**
  String get checkoutErrorCard;

  /// No description provided for @checkoutErrorExpiry.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid expiry date (MM/YY)'**
  String get checkoutErrorExpiry;

  /// No description provided for @checkoutErrorCvv.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid CVV (3–4 digits)'**
  String get checkoutErrorCvv;

  /// No description provided for @checkoutPaymentSecure.
  ///
  /// In en, this message translates to:
  /// **'Your payment info is encrypted'**
  String get checkoutPaymentSecure;

  /// No description provided for @checkoutErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not place order'**
  String get checkoutErrorGeneric;

  /// No description provided for @orderPlacedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Placed! 🎉'**
  String get orderPlacedTitle;

  /// No description provided for @orderTrackCta.
  ///
  /// In en, this message translates to:
  /// **'Track My Order'**
  String get orderTrackCta;

  /// No description provided for @orderContinueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get orderContinueShopping;

  /// No description provided for @couponDetailSave10.
  ///
  /// In en, this message translates to:
  /// **'10% discount applied!'**
  String get couponDetailSave10;

  /// No description provided for @couponDetailFree500.
  ///
  /// In en, this message translates to:
  /// **'500 DZD discount applied!'**
  String get couponDetailFree500;

  /// No description provided for @couponDetailWelcome.
  ///
  /// In en, this message translates to:
  /// **'15% discount applied!'**
  String get couponDetailWelcome;

  /// No description provided for @youMayAlsoLike.
  ///
  /// In en, this message translates to:
  /// **'You May Also Like'**
  String get youMayAlsoLike;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// No description provided for @productScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productScreenTitle;

  /// No description provided for @reviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsTitle;

  /// No description provided for @customerReviews.
  ///
  /// In en, this message translates to:
  /// **'Customer Reviews'**
  String get customerReviews;

  /// No description provided for @ratingsWord.
  ///
  /// In en, this message translates to:
  /// **'ratings'**
  String get ratingsWord;

  /// No description provided for @reviewsDotSeparator.
  ///
  /// In en, this message translates to:
  /// **' · '**
  String get reviewsDotSeparator;

  /// No description provided for @reviewsSuffix.
  ///
  /// In en, this message translates to:
  /// **' reviews'**
  String get reviewsSuffix;

  /// No description provided for @helpfulPrompt.
  ///
  /// In en, this message translates to:
  /// **'Helpful? 👍 '**
  String get helpfulPrompt;

  /// No description provided for @specifications.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get specifications;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @readLess.
  ///
  /// In en, this message translates to:
  /// **'Read less'**
  String get readLess;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeReview;

  /// No description provided for @editReview.
  ///
  /// In en, this message translates to:
  /// **'Edit Review'**
  String get editReview;

  /// No description provided for @deleteReview.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteReview;

  /// No description provided for @reviewRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get reviewRatingLabel;

  /// No description provided for @reviewCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts about this product'**
  String get reviewCommentHint;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitReview;

  /// No description provided for @signInToWriteReview.
  ///
  /// In en, this message translates to:
  /// **'Sign in to write a review'**
  String get signInToWriteReview;

  /// No description provided for @deleteReviewConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete review?'**
  String get deleteReviewConfirmTitle;

  /// No description provided for @deleteReviewConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get deleteReviewConfirmMessage;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @stockQuantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Stock quantity *'**
  String get stockQuantityRequired;

  /// No description provided for @chatSeller.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatSeller;

  /// No description provided for @chatSellerSoon.
  ///
  /// In en, this message translates to:
  /// **'Chat with seller — coming soon'**
  String get chatSellerSoon;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart!'**
  String get addedToCart;

  /// No description provided for @expressCheckoutSoon.
  ///
  /// In en, this message translates to:
  /// **'Express checkout — coming soon'**
  String get expressCheckoutSoon;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy now'**
  String get buyNow;

  /// No description provided for @visitStore.
  ///
  /// In en, this message translates to:
  /// **'Visit Store'**
  String get visitStore;

  /// No description provided for @verifiedSeller.
  ///
  /// In en, this message translates to:
  /// **'✅ Verified Seller'**
  String get verifiedSeller;

  /// No description provided for @sellerRatingMid.
  ///
  /// In en, this message translates to:
  /// **' Seller · '**
  String get sellerRatingMid;

  /// No description provided for @sellerSalesSuffix.
  ///
  /// In en, this message translates to:
  /// **' sales'**
  String get sellerSalesSuffix;

  /// No description provided for @onlyLeftPrefix.
  ///
  /// In en, this message translates to:
  /// **'Only '**
  String get onlyLeftPrefix;

  /// No description provided for @onlyLeftSuffix.
  ///
  /// In en, this message translates to:
  /// **' left!'**
  String get onlyLeftSuffix;

  /// No description provided for @listingTotalListings.
  ///
  /// In en, this message translates to:
  /// **'Total Listings'**
  String get listingTotalListings;

  /// No description provided for @listingSoldStat.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get listingSoldStat;

  /// No description provided for @listingViews.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get listingViews;

  /// No description provided for @listingSaves.
  ///
  /// In en, this message translates to:
  /// **'Saves'**
  String get listingSaves;

  /// No description provided for @listingInquiries.
  ///
  /// In en, this message translates to:
  /// **'Inquiries'**
  String get listingInquiries;

  /// No description provided for @editListing.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editListing;

  /// No description provided for @editListingMenu.
  ///
  /// In en, this message translates to:
  /// **'Edit Listing'**
  String get editListingMenu;

  /// No description provided for @viewStatsMenu.
  ///
  /// In en, this message translates to:
  /// **'View Stats'**
  String get viewStatsMenu;

  /// No description provided for @listingStatsHeading.
  ///
  /// In en, this message translates to:
  /// **'Listing stats'**
  String get listingStatsHeading;

  /// No description provided for @subcategoryPickerPrefix.
  ///
  /// In en, this message translates to:
  /// **'Subcategory — '**
  String get subcategoryPickerPrefix;

  /// No description provided for @pauseListing.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseListing;

  /// No description provided for @resumeListing.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeListing;

  /// No description provided for @listingStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get listingStats;

  /// No description provided for @deleteListing.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteListing;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @sold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get sold;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @emptyInbox.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyInbox;

  /// No description provided for @incomingOrders.
  ///
  /// In en, this message translates to:
  /// **'Incoming Orders'**
  String get incomingOrders;

  /// No description provided for @vendorSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by order ID or buyer name'**
  String get vendorSearchHint;

  /// No description provided for @vendorConfirmAllPending.
  ///
  /// In en, this message translates to:
  /// **'Confirm All Pending'**
  String get vendorConfirmAllPending;

  /// No description provided for @vendorViewAnalytics.
  ///
  /// In en, this message translates to:
  /// **'View Analytics'**
  String get vendorViewAnalytics;

  /// No description provided for @vendorStatPendingOrders.
  ///
  /// In en, this message translates to:
  /// **'Pending Orders'**
  String get vendorStatPendingOrders;

  /// No description provided for @vendorStatActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'Active Orders'**
  String get vendorStatActiveOrders;

  /// No description provided for @vendorStatTotalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get vendorStatTotalOrders;

  /// No description provided for @vendorStatRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get vendorStatRevenue;

  /// No description provided for @vendorConfirmAllPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm all pending orders?'**
  String get vendorConfirmAllPendingTitle;

  /// No description provided for @vendorSortNewestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get vendorSortNewestFirst;

  /// No description provided for @vendorSortOldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get vendorSortOldestFirst;

  /// No description provided for @vendorSortHighestValue.
  ///
  /// In en, this message translates to:
  /// **'Highest Value'**
  String get vendorSortHighestValue;

  /// No description provided for @vendorSortNeedsAction.
  ///
  /// In en, this message translates to:
  /// **'Needs Action'**
  String get vendorSortNeedsAction;

  /// No description provided for @vendorSortBuyerName.
  ///
  /// In en, this message translates to:
  /// **'By Buyer Name A–Z'**
  String get vendorSortBuyerName;

  /// No description provided for @vendorNewOrder.
  ///
  /// In en, this message translates to:
  /// **'NEW ORDER'**
  String get vendorNewOrder;

  /// No description provided for @vendorRejectOrder.
  ///
  /// In en, this message translates to:
  /// **'Reject Order'**
  String get vendorRejectOrder;

  /// No description provided for @vendorConfirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get vendorConfirmOrder;

  /// No description provided for @vendorConfirmOrderShort.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get vendorConfirmOrderShort;

  /// No description provided for @vendorMarkProcessing.
  ///
  /// In en, this message translates to:
  /// **'Mark as Processing'**
  String get vendorMarkProcessing;

  /// No description provided for @vendorMarkShipped.
  ///
  /// In en, this message translates to:
  /// **'Mark as Shipped'**
  String get vendorMarkShipped;

  /// No description provided for @vendorOrdersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get vendorOrdersEmptyTitle;

  /// No description provided for @vendorNoStatusOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders for this status'**
  String get vendorNoStatusOrders;

  /// No description provided for @vendorNoStatusOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try another filter or show all orders'**
  String get vendorNoStatusOrdersSubtitle;

  /// No description provided for @vendorShippingInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipping Information'**
  String get vendorShippingInfoTitle;

  /// No description provided for @vendorViewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View on Map'**
  String get vendorViewOnMap;

  /// No description provided for @vendorCollectOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Collect on delivery'**
  String get vendorCollectOnDelivery;

  /// No description provided for @vendorRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject this order?'**
  String get vendorRejectTitle;

  /// No description provided for @vendorConfirmRejection.
  ///
  /// In en, this message translates to:
  /// **'Confirm Rejection'**
  String get vendorConfirmRejection;

  /// No description provided for @vendorConfirmShipment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Shipment'**
  String get vendorConfirmShipment;

  /// No description provided for @vendorExportOrders.
  ///
  /// In en, this message translates to:
  /// **'Export Orders'**
  String get vendorExportOrders;

  /// No description provided for @vendorOrderSettings.
  ///
  /// In en, this message translates to:
  /// **'Order Settings'**
  String get vendorOrderSettings;

  /// No description provided for @vendorPrintOrder.
  ///
  /// In en, this message translates to:
  /// **'Print Order'**
  String get vendorPrintOrder;

  /// No description provided for @vendorReportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get vendorReportIssue;

  /// No description provided for @vendorReasonItemUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Item no longer available'**
  String get vendorReasonItemUnavailable;

  /// No description provided for @vendorReasonOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get vendorReasonOutOfStock;

  /// No description provided for @vendorReasonCannotDeliver.
  ///
  /// In en, this message translates to:
  /// **'Cannot deliver to buyer location'**
  String get vendorReasonCannotDeliver;

  /// No description provided for @vendorReasonSuspicious.
  ///
  /// In en, this message translates to:
  /// **'Suspicious order'**
  String get vendorReasonSuspicious;

  /// No description provided for @vendorReasonIncorrectPricing.
  ///
  /// In en, this message translates to:
  /// **'Incorrect pricing'**
  String get vendorReasonIncorrectPricing;

  /// No description provided for @vendorReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get vendorReasonOther;

  /// No description provided for @vendorTypeReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Type reason'**
  String get vendorTypeReasonHint;

  /// No description provided for @vendorTrackingHint.
  ///
  /// In en, this message translates to:
  /// **'XS-TRACK-2024-001'**
  String get vendorTrackingHint;

  /// No description provided for @vendorShippingNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Package handed to courier, estimated 3–5 days'**
  String get vendorShippingNoteHint;

  /// No description provided for @vendorOrderRejectedSnack.
  ///
  /// In en, this message translates to:
  /// **'Order rejected. Buyer notified.'**
  String get vendorOrderRejectedSnack;

  /// No description provided for @vendorOrderConfirmedSnack.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed'**
  String get vendorOrderConfirmedSnack;

  /// No description provided for @vendorOrderProcessingSnack.
  ///
  /// In en, this message translates to:
  /// **'Order marked as processing'**
  String get vendorOrderProcessingSnack;

  /// No description provided for @vendorOrderShippedSnack.
  ///
  /// In en, this message translates to:
  /// **'Order marked as shipped!'**
  String get vendorOrderShippedSnack;

  /// No description provided for @vendorStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Awaiting your confirmation'**
  String get vendorStatusPending;

  /// No description provided for @vendorStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'You confirmed this order'**
  String get vendorStatusConfirmed;

  /// No description provided for @vendorStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Preparing for shipment'**
  String get vendorStatusProcessing;

  /// No description provided for @vendorStatusShipped.
  ///
  /// In en, this message translates to:
  /// **'Order is on the way'**
  String get vendorStatusShipped;

  /// No description provided for @vendorStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Order delivered successfully'**
  String get vendorStatusDelivered;

  /// No description provided for @vendorStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'This order was cancelled'**
  String get vendorStatusCancelled;

  /// No description provided for @vendorStatusRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get vendorStatusRefunded;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didntReceiveCode;

  /// No description provided for @mensFashion.
  ///
  /// In en, this message translates to:
  /// **'Men\'s Fashion'**
  String get mensFashion;

  /// No description provided for @womensFashion.
  ///
  /// In en, this message translates to:
  /// **'Women\'s Fashion'**
  String get womensFashion;

  /// No description provided for @notificationsEmptyAllTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up! 🎉'**
  String get notificationsEmptyAllTitle;

  /// No description provided for @notificationsUnreadBannerLine.
  ///
  /// In en, this message translates to:
  /// **'🔔 You have {n} unread notifications'**
  String notificationsUnreadBannerLine(int n);

  /// No description provided for @notificationsEmptyFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'No {filter} notifications'**
  String notificationsEmptyFilterTitle(String filter);

  /// No description provided for @notificationsEmptyFilterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your {scope} notifications will appear here'**
  String notificationsEmptyFilterSubtitle(String scope);

  /// No description provided for @notificationsDeletedSnack.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" removed'**
  String notificationsDeletedSnack(String title);

  /// No description provided for @notificationsTimeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{m}m ago'**
  String notificationsTimeMinutesAgo(int m);

  /// No description provided for @notificationsTimeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{h}h ago'**
  String notificationsTimeHoursAgo(int h);

  /// No description provided for @applyFiltersCount.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters ({n})'**
  String applyFiltersCount(int n);

  /// No description provided for @ordersCountLine.
  ///
  /// In en, this message translates to:
  /// **'{n} orders'**
  String ordersCountLine(int n);

  /// No description provided for @ordersMoreItems.
  ///
  /// In en, this message translates to:
  /// **'+ {n} more items'**
  String ordersMoreItems(int n);

  /// No description provided for @ordersItemsSectionCount.
  ///
  /// In en, this message translates to:
  /// **'Items Ordered ({n})'**
  String ordersItemsSectionCount(int n);

  /// No description provided for @wishlistAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'My Wishlist ({n})'**
  String wishlistAppBarTitle(int n);

  /// No description provided for @wishlistSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{n} selected'**
  String wishlistSelectedCount(int n);

  /// No description provided for @wishlistPriceDropBanner.
  ///
  /// In en, this message translates to:
  /// **'🎉 Price drop on {n} items in your wishlist!'**
  String wishlistPriceDropBanner(int n);

  /// No description provided for @wishlistPriceDropPercent.
  ///
  /// In en, this message translates to:
  /// **'↓ {p}% Price Drop'**
  String wishlistPriceDropPercent(int p);

  /// No description provided for @wishlistMoveAllSummary.
  ///
  /// In en, this message translates to:
  /// **'{n} items added to cart'**
  String wishlistMoveAllSummary(int n);

  /// No description provided for @wishlistShareText.
  ///
  /// In en, this message translates to:
  /// **'Check out my wishlist on xStore! 🛍️\n{link}'**
  String wishlistShareText(String link);

  /// No description provided for @wishlistItemsAvailableLine.
  ///
  /// In en, this message translates to:
  /// **'{total} items · {avail} available'**
  String wishlistItemsAvailableLine(int total, int avail);

  /// No description provided for @wishlistAddToCartSelected.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart ({n})'**
  String wishlistAddToCartSelected(int n);

  /// No description provided for @wishlistRemoveSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'Remove Selected ({n})'**
  String wishlistRemoveSelectedCount(int n);

  /// No description provided for @wishlistFilterEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No {filterName} items'**
  String wishlistFilterEmptyTitle(String filterName);

  /// No description provided for @wishlistAddedToCartCount.
  ///
  /// In en, this message translates to:
  /// **'{n} items added to cart'**
  String wishlistAddedToCartCount(int n);

  /// No description provided for @cartAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'My Cart ({n} items)'**
  String cartAppBarTitle(int n);

  /// No description provided for @cartClearBody.
  ///
  /// In en, this message translates to:
  /// **'This will remove all {n} items from your cart.'**
  String cartClearBody(int n);

  /// No description provided for @cartSelectAllCount.
  ///
  /// In en, this message translates to:
  /// **'Select All ({n} items)'**
  String cartSelectAllCount(int n);

  /// No description provided for @cartRemovedSnack.
  ///
  /// In en, this message translates to:
  /// **'{name} removed from cart'**
  String cartRemovedSnack(String name);

  /// No description provided for @cartShippingPaid.
  ///
  /// In en, this message translates to:
  /// **'🚚 +{amount} DZD shipping'**
  String cartShippingPaid(int amount);

  /// No description provided for @cartCouponApplied.
  ///
  /// In en, this message translates to:
  /// **'✅ \"{code}\" — {detail}'**
  String cartCouponApplied(String code, String detail);

  /// No description provided for @cartSubtotalLine.
  ///
  /// In en, this message translates to:
  /// **'Subtotal ({n} items)'**
  String cartSubtotalLine(int n);

  /// No description provided for @cartCouponLine.
  ///
  /// In en, this message translates to:
  /// **'Coupon ({code})'**
  String cartCouponLine(String code);

  /// No description provided for @cartProceedCheckoutTotal.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout ({total})'**
  String cartProceedCheckoutTotal(String total);

  /// No description provided for @cartCheckoutItems.
  ///
  /// In en, this message translates to:
  /// **'Checkout ({n} items)'**
  String cartCheckoutItems(int n);

  /// No description provided for @checkoutItemsFromSellers.
  ///
  /// In en, this message translates to:
  /// **'{items} items from {sellers} sellers'**
  String checkoutItemsFromSellers(int items, int sellers);

  /// No description provided for @checkoutPlaceOrderTotal.
  ///
  /// In en, this message translates to:
  /// **'🛒 Place Order · {total}'**
  String checkoutPlaceOrderTotal(String total);

  /// No description provided for @orderPlacedNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderPlacedNumber(String id);

  /// No description provided for @vendorOrdersConfirmed.
  ///
  /// In en, this message translates to:
  /// **'{n} orders confirmed successfully'**
  String vendorOrdersConfirmed(int n);

  /// No description provided for @vendorLowStockHint.
  ///
  /// In en, this message translates to:
  /// **'{qty} units remaining after this order'**
  String vendorLowStockHint(int qty);

  /// No description provided for @enterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumber;

  /// No description provided for @sendOtpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a verification code to your Egyptian number'**
  String get sendOtpSubtitle;

  /// No description provided for @signInToContinueShopping.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue shopping'**
  String get signInToContinueShopping;

  /// No description provided for @enterEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@email.com'**
  String get enterEmailHint;

  /// No description provided for @validEmailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Valid email or 10+ digit phone'**
  String get validEmailOrPhone;

  /// No description provided for @passwordMask.
  ///
  /// In en, this message translates to:
  /// **'********'**
  String get passwordMask;

  /// No description provided for @minSixChars.
  ///
  /// In en, this message translates to:
  /// **'Min 6 characters'**
  String get minSixChars;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @continueWithPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Continue with Phone Number'**
  String get continueWithPhoneNumber;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @createOneArrow.
  ///
  /// In en, this message translates to:
  /// **'Create one →'**
  String get createOneArrow;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Discover Amazing Deals'**
  String get onboardingTitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Start Selling Today'**
  String get onboardingTitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Safe & Trusted'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Shop from thousands of vendors across Egypt and beyond'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'List your products in minutes and reach thousands of buyers'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Secure payments, buyer protection, and verified sellers'**
  String get onboardingSubtitle3;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @leaveRegistrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave registration?'**
  String get leaveRegistrationTitle;

  /// No description provided for @leaveRegistrationBody.
  ///
  /// In en, this message translates to:
  /// **'Your progress will be lost.'**
  String get leaveRegistrationBody;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @stepRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get stepRole;

  /// No description provided for @stepInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get stepInfo;

  /// No description provided for @stepSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get stepSecurity;

  /// No description provided for @stepStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get stepStore;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @createMyStore.
  ///
  /// In en, this message translates to:
  /// **'Create My Store'**
  String get createMyStore;

  /// No description provided for @joinAs.
  ///
  /// In en, this message translates to:
  /// **'Join xStore as...'**
  String get joinAs;

  /// No description provided for @chooseHowUse.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to use xStore. You can always add the other role later.'**
  String get chooseHowUse;

  /// No description provided for @iAmBuyer.
  ///
  /// In en, this message translates to:
  /// **'I\'m a Buyer'**
  String get iAmBuyer;

  /// No description provided for @buyerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover and buy products from verified sellers'**
  String get buyerSubtitle;

  /// No description provided for @buyerFeature1.
  ///
  /// In en, this message translates to:
  /// **'Browse thousands of products'**
  String get buyerFeature1;

  /// No description provided for @buyerFeature2.
  ///
  /// In en, this message translates to:
  /// **'Secure checkout & payments'**
  String get buyerFeature2;

  /// No description provided for @buyerFeature3.
  ///
  /// In en, this message translates to:
  /// **'Track your orders in real time'**
  String get buyerFeature3;

  /// No description provided for @buyerFeature4.
  ///
  /// In en, this message translates to:
  /// **'Save favorites to wishlist'**
  String get buyerFeature4;

  /// No description provided for @iAmSeller.
  ///
  /// In en, this message translates to:
  /// **'I\'m a Seller'**
  String get iAmSeller;

  /// No description provided for @sellerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'List your products and start earning today'**
  String get sellerSubtitle;

  /// No description provided for @sellerFeature1.
  ///
  /// In en, this message translates to:
  /// **'List unlimited products'**
  String get sellerFeature1;

  /// No description provided for @sellerFeature2.
  ///
  /// In en, this message translates to:
  /// **'Manage orders & inventory'**
  String get sellerFeature2;

  /// No description provided for @sellerFeature3.
  ///
  /// In en, this message translates to:
  /// **'Analytics & sales insights'**
  String get sellerFeature3;

  /// No description provided for @sellerFeature4.
  ///
  /// In en, this message translates to:
  /// **'Direct chat with buyers'**
  String get sellerFeature4;

  /// No description provided for @dateOfBirthOptional.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth (optional)'**
  String get dateOfBirthOptional;

  /// No description provided for @tellUsAboutYou.
  ///
  /// In en, this message translates to:
  /// **'Tell us about you'**
  String get tellUsAboutYou;

  /// No description provided for @infoOnProfile.
  ///
  /// In en, this message translates to:
  /// **'This information will be on your profile'**
  String get infoOnProfile;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full Name *'**
  String get fullNameRequired;

  /// No description provided for @fullNameArRequired.
  ///
  /// In en, this message translates to:
  /// **'Full Name (Arabic) *'**
  String get fullNameArRequired;

  /// No description provided for @storeNameArRequired.
  ///
  /// In en, this message translates to:
  /// **'Store Name (Arabic) *'**
  String get storeNameArRequired;

  /// No description provided for @storeDescriptionArRequired.
  ///
  /// In en, this message translates to:
  /// **'Store Description (Arabic) *'**
  String get storeDescriptionArRequired;

  /// No description provided for @emailAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Email Address *'**
  String get emailAddressRequired;

  /// No description provided for @locationCityRequired.
  ///
  /// In en, this message translates to:
  /// **'Location / City *'**
  String get locationCityRequired;

  /// No description provided for @locationHintAlgiers.
  ///
  /// In en, this message translates to:
  /// **'e.g. Algiers'**
  String get locationHintAlgiers;

  /// No description provided for @secureYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Secure your account'**
  String get secureYourAccount;

  /// No description provided for @strongPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a strong password to protect your account'**
  String get strongPasswordHint;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password *'**
  String get passwordRequired;

  /// No description provided for @newPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'New Password *'**
  String get newPasswordRequired;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password *'**
  String get confirmPasswordRequired;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordOtpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to {email} and choose a new password'**
  String resetPasswordOtpSentTo(String email);

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset. Please sign in with your new password.'**
  String get passwordResetSuccess;

  /// No description provided for @agreeTo.
  ///
  /// In en, this message translates to:
  /// **'I agree to the'**
  String get agreeTo;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @andWord.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get andWord;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @setUpYourStore.
  ///
  /// In en, this message translates to:
  /// **'Set up your store'**
  String get setUpYourStore;

  /// No description provided for @tellBuyersStore.
  ///
  /// In en, this message translates to:
  /// **'Tell buyers about your store'**
  String get tellBuyersStore;

  /// No description provided for @storeNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Store Name *'**
  String get storeNameRequired;

  /// No description provided for @storeNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Ahmed\'s Electronics'**
  String get storeNameHint;

  /// No description provided for @storeCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Store Category *'**
  String get storeCategoryRequired;

  /// No description provided for @storeSellHint.
  ///
  /// In en, this message translates to:
  /// **'What do you mainly sell?'**
  String get storeSellHint;

  /// No description provided for @storeDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Store Description *'**
  String get storeDescriptionRequired;

  /// No description provided for @storeDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your store and what makes it unique...'**
  String get storeDescriptionHint;

  /// No description provided for @storeLogoOptional.
  ///
  /// In en, this message translates to:
  /// **'Store Logo (optional)'**
  String get storeLogoOptional;

  /// No description provided for @cityRequired.
  ///
  /// In en, this message translates to:
  /// **'City *'**
  String get cityRequired;

  /// No description provided for @wilayaRequired.
  ///
  /// In en, this message translates to:
  /// **'Wilaya *'**
  String get wilayaRequired;

  /// No description provided for @sellerFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get sellerFallbackName;

  /// No description provided for @storeReady.
  ///
  /// In en, this message translates to:
  /// **'Your store is ready. Start listing!'**
  String get storeReady;

  /// No description provided for @goToMyStore.
  ///
  /// In en, this message translates to:
  /// **'Go to My Store'**
  String get goToMyStore;

  /// No description provided for @languageToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageToggleTitle;

  /// No description provided for @vendorOrdersEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'When buyers place orders on your listings, they will appear here'**
  String get vendorOrdersEmptySubtitle;

  /// No description provided for @discoverProducts.
  ///
  /// In en, this message translates to:
  /// **'Discover products'**
  String get discoverProducts;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(int current, int total);

  /// No description provided for @vendorWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to xStore, {name}! 🎉'**
  String vendorWelcome(String name);

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @emailUpdates.
  ///
  /// In en, this message translates to:
  /// **'Email Updates'**
  String get emailUpdates;

  /// No description provided for @wishlistEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save items you love by tapping the heart icon on any product'**
  String get wishlistEmptySubtitle;

  /// No description provided for @shareXStoreMessage.
  ///
  /// In en, this message translates to:
  /// **'Shop and sell on xStore — Egypt\'s modern marketplace.'**
  String get shareXStoreMessage;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartTitle;

  /// No description provided for @cartEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Looks like you haven\'t added anything to your cart yet'**
  String get cartEmptySubtitle;

  /// No description provided for @cartUnavailableHint.
  ///
  /// In en, this message translates to:
  /// **'This item is no longer available'**
  String get cartUnavailableHint;

  /// No description provided for @wishlistPriceDropBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prices dropped since you saved them'**
  String get wishlistPriceDropBannerSubtitle;

  /// No description provided for @wishlistForBuyersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a consumer account to save and track your favorite products'**
  String get wishlistForBuyersSubtitle;

  /// No description provided for @storeHours.
  ///
  /// In en, this message translates to:
  /// **'Store Hours'**
  String get storeHours;

  /// No description provided for @storeOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Open Now'**
  String get storeOpenNow;

  /// No description provided for @storeClosedNow.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get storeClosedNow;

  /// No description provided for @storeStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Your store is currently OPEN'**
  String get storeStatusOpen;

  /// No description provided for @storeStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Your store is currently CLOSED'**
  String get storeStatusClosed;

  /// No description provided for @storeOpenDesc.
  ///
  /// In en, this message translates to:
  /// **'Customers can place orders now'**
  String get storeOpenDesc;

  /// No description provided for @storeClosedDesc.
  ///
  /// In en, this message translates to:
  /// **'Customers cannot place orders now'**
  String get storeClosedDesc;

  /// No description provided for @closeStoreNow.
  ///
  /// In en, this message translates to:
  /// **'Close Store Now'**
  String get closeStoreNow;

  /// No description provided for @openStoreNow.
  ///
  /// In en, this message translates to:
  /// **'Open Store Now'**
  String get openStoreNow;

  /// No description provided for @closedMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a message for customers (optional)'**
  String get closedMessage;

  /// No description provided for @closedMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Closed message'**
  String get closedMessageTitle;

  /// No description provided for @closedMessageHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Back in 1 hour, Closed for holiday'**
  String get closedMessageHint;

  /// No description provided for @weeklySchedule.
  ///
  /// In en, this message translates to:
  /// **'Weekly Schedule'**
  String get weeklySchedule;

  /// No description provided for @weeklyScheduleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set your working hours for each day'**
  String get weeklyScheduleSubtitle;

  /// No description provided for @copyHoursToAll.
  ///
  /// In en, this message translates to:
  /// **'Copy hours to all days'**
  String get copyHoursToAll;

  /// No description provided for @quickPresets.
  ///
  /// In en, this message translates to:
  /// **'Quick Presets'**
  String get quickPresets;

  /// No description provided for @quickPresetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Apply a schedule template instantly'**
  String get quickPresetsSubtitle;

  /// No description provided for @presetStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard (9AM–6PM)'**
  String get presetStandard;

  /// No description provided for @presetExtended.
  ///
  /// In en, this message translates to:
  /// **'Extended (9AM–11PM)'**
  String get presetExtended;

  /// No description provided for @presetMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning Only (8AM–2PM)'**
  String get presetMorning;

  /// No description provided for @presetFullWeek.
  ///
  /// In en, this message translates to:
  /// **'Full Week'**
  String get presetFullWeek;

  /// No description provided for @presetWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays Only (Sat–Thu)'**
  String get presetWeekdays;

  /// No description provided for @presetWithoutFriday.
  ///
  /// In en, this message translates to:
  /// **'Without Friday'**
  String get presetWithoutFriday;

  /// No description provided for @saveWorkingHours.
  ///
  /// In en, this message translates to:
  /// **'Save Working Hours'**
  String get saveWorkingHours;

  /// No description provided for @workingHoursSaved.
  ///
  /// In en, this message translates to:
  /// **'Working hours saved! ✅'**
  String get workingHoursSaved;

  /// No description provided for @storeNowOpen.
  ///
  /// In en, this message translates to:
  /// **'Store is now Open 🟢'**
  String get storeNowOpen;

  /// No description provided for @storeNowClosed.
  ///
  /// In en, this message translates to:
  /// **'Store is now Closed 🔴'**
  String get storeNowClosed;

  /// No description provided for @open24Hours.
  ///
  /// In en, this message translates to:
  /// **'Open 24 Hours'**
  String get open24Hours;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @copyFrom.
  ///
  /// In en, this message translates to:
  /// **'Copy from:'**
  String get copyFrom;

  /// No description provided for @copyingFrom.
  ///
  /// In en, this message translates to:
  /// **'Copying from:'**
  String get copyingFrom;

  /// No description provided for @applyToSelectedDays.
  ///
  /// In en, this message translates to:
  /// **'Apply to Selected Days'**
  String get applyToSelectedDays;

  /// No description provided for @selectAllDays.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAllDays;

  /// No description provided for @deselectAllDays.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAllDays;

  /// No description provided for @openLabel.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openLabel;

  /// No description provided for @closedLabel.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closedLabel;

  /// No description provided for @opensAt.
  ///
  /// In en, this message translates to:
  /// **'Opens at {time}'**
  String opensAt(String time);

  /// No description provided for @closesAt.
  ///
  /// In en, this message translates to:
  /// **'Closes at {time}'**
  String closesAt(String time);

  /// No description provided for @opensOn.
  ///
  /// In en, this message translates to:
  /// **'Opens {day} at {time}'**
  String opensOn(String day, String time);

  /// No description provided for @storeHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Store Hours'**
  String get storeHoursTitle;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySunday;

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dayFriday;

  /// No description provided for @dayShortSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get dayShortSat;

  /// No description provided for @dayShortSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get dayShortSun;

  /// No description provided for @dayShortMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayShortMon;

  /// No description provided for @dayShortTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayShortTue;

  /// No description provided for @dayShortWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayShortWed;

  /// No description provided for @dayShortThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayShortThu;

  /// No description provided for @dayShortFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayShortFri;

  /// No description provided for @invalidHoursError.
  ///
  /// In en, this message translates to:
  /// **'Closing time must be after opening time'**
  String get invalidHoursError;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard Changes'**
  String get discardChanges;

  /// No description provided for @discardChangesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Discard unsaved changes?'**
  String get discardChangesConfirm;

  /// No description provided for @applyPresetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Apply {preset} hours to all days?'**
  String applyPresetConfirm(String preset);

  /// No description provided for @storeClosedWarning.
  ///
  /// In en, this message translates to:
  /// **'This store is currently closed. You can still order — seller will respond when they reopen.'**
  String get storeClosedWarning;

  /// No description provided for @storeLocation.
  ///
  /// In en, this message translates to:
  /// **'Store Location'**
  String get storeLocation;

  /// No description provided for @storeLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help buyers find your store'**
  String get storeLocationSubtitle;

  /// No description provided for @detectMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Detect My Current Location'**
  String get detectMyLocation;

  /// No description provided for @detectingLocation.
  ///
  /// In en, this message translates to:
  /// **'Detecting location...'**
  String get detectingLocation;

  /// No description provided for @orFillManually.
  ///
  /// In en, this message translates to:
  /// **'or fill manually'**
  String get orFillManually;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @latitudeHint.
  ///
  /// In en, this message translates to:
  /// **'30.044400'**
  String get latitudeHint;

  /// No description provided for @longitudeHint.
  ///
  /// In en, this message translates to:
  /// **'31.235700'**
  String get longitudeHint;

  /// No description provided for @governorate.
  ///
  /// In en, this message translates to:
  /// **'Governorate'**
  String get governorate;

  /// No description provided for @governorateHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Cairo, Giza, Alexandria'**
  String get governorateHint;

  /// No description provided for @townCity.
  ///
  /// In en, this message translates to:
  /// **'Town / City'**
  String get townCity;

  /// No description provided for @townCityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Nasr City, Dokki, Sidi Gaber'**
  String get townCityHint;

  /// No description provided for @detailAddress.
  ///
  /// In en, this message translates to:
  /// **'Detailed Address'**
  String get detailAddress;

  /// No description provided for @detailAddressHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 12 Tahrir St, Floor 3, near City Stars'**
  String get detailAddressHint;

  /// No description provided for @locationDetected.
  ///
  /// In en, this message translates to:
  /// **'📍 Location detected!'**
  String get locationDetected;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Enable them in Settings.'**
  String get locationServiceDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied. Please allow location access.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionPermanent.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied. Open app settings to enable.'**
  String get locationPermissionPermanent;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @openAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Open App Settings'**
  String get openAppSettings;

  /// No description provided for @invalidLatitude.
  ///
  /// In en, this message translates to:
  /// **'Invalid latitude value'**
  String get invalidLatitude;

  /// No description provided for @invalidLongitude.
  ///
  /// In en, this message translates to:
  /// **'Invalid longitude value'**
  String get invalidLongitude;

  /// No description provided for @validationEmailOrPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Email or phone is required'**
  String get validationEmailOrPhoneRequired;

  /// No description provided for @validationLoginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get validationLoginPasswordRequired;

  /// No description provided for @validationRegisterRoleRequired.
  ///
  /// In en, this message translates to:
  /// **'Select how you want to use xStore'**
  String get validationRegisterRoleRequired;

  /// No description provided for @validationFullNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name (letters only, min 3 chars)'**
  String get validationFullNameInvalid;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get validationEmailInvalid;

  /// No description provided for @validationRegisterPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get validationRegisterPhoneInvalid;

  /// No description provided for @validationCityRequired.
  ///
  /// In en, this message translates to:
  /// **'City is required'**
  String get validationCityRequired;

  /// No description provided for @validationAgeMinimum18.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 18 years old'**
  String get validationAgeMinimum18;

  /// No description provided for @validationPasswordMinEight.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get validationPasswordMinEight;

  /// No description provided for @validationPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordsMismatch;

  /// No description provided for @validationTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms to continue'**
  String get validationTermsRequired;

  /// No description provided for @validationStoreNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Store name is required'**
  String get validationStoreNameRequired;

  /// No description provided for @validationStoreCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick a category'**
  String get validationStoreCategoryRequired;

  /// No description provided for @validationStoreDescriptionShort.
  ///
  /// In en, this message translates to:
  /// **'Describe your store'**
  String get validationStoreDescriptionShort;

  /// No description provided for @validationStoreDescriptionMax.
  ///
  /// In en, this message translates to:
  /// **'Max 300 characters'**
  String get validationStoreDescriptionMax;

  /// No description provided for @validationStoreCityWilayaRequired.
  ///
  /// In en, this message translates to:
  /// **'City and wilaya are required'**
  String get validationStoreCityWilayaRequired;

  /// No description provided for @validationFullNameArRequired.
  ///
  /// In en, this message translates to:
  /// **'Arabic full name is required'**
  String get validationFullNameArRequired;

  /// No description provided for @validationStoreNameArRequired.
  ///
  /// In en, this message translates to:
  /// **'Arabic store name is required'**
  String get validationStoreNameArRequired;

  /// No description provided for @validationStoreDescriptionArShort.
  ///
  /// In en, this message translates to:
  /// **'Describe your store in Arabic'**
  String get validationStoreDescriptionArShort;

  /// No description provided for @listingValidationPhotosRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one photo'**
  String get listingValidationPhotosRequired;

  /// No description provided for @listingValidationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Product name is required'**
  String get listingValidationNameRequired;

  /// No description provided for @listingValidationNameMax.
  ///
  /// In en, this message translates to:
  /// **'Max 100 characters'**
  String get listingValidationNameMax;

  /// No description provided for @listingValidationPriceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price'**
  String get listingValidationPriceInvalid;

  /// No description provided for @listingValidationDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get listingValidationDescriptionRequired;

  /// No description provided for @listingValidationDescriptionMax.
  ///
  /// In en, this message translates to:
  /// **'Max 1000 characters'**
  String get listingValidationDescriptionMax;

  /// No description provided for @listingValidationCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get listingValidationCategoryRequired;

  /// No description provided for @listingValidationSubcategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a subcategory'**
  String get listingValidationSubcategoryRequired;

  /// No description provided for @listingValidationConditionRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a condition'**
  String get listingValidationConditionRequired;

  /// No description provided for @listingValidationQuantityMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum quantity is 1'**
  String get listingValidationQuantityMin;

  /// No description provided for @listingValidationLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location is required'**
  String get listingValidationLocationRequired;

  /// No description provided for @listingValidationShippingCost.
  ///
  /// In en, this message translates to:
  /// **'Enter shipping cost'**
  String get listingValidationShippingCost;

  /// No description provided for @listingValidationFixFields.
  ///
  /// In en, this message translates to:
  /// **'Please fix the highlighted fields'**
  String get listingValidationFixFields;

  /// No description provided for @egypt.
  ///
  /// In en, this message translates to:
  /// **'Egypt'**
  String get egypt;

  /// No description provided for @locationServicesOff.
  ///
  /// In en, this message translates to:
  /// **'Location services are off'**
  String get locationServicesOff;

  /// No description provided for @enableLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Enable them in Settings?'**
  String get enableLocationServices;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
