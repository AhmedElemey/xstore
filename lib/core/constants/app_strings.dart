/// Non-localized strings still referenced from code. UI copy lives in the
/// ARB files (`context.l10n`); do not add new user-facing text here.
abstract final class AppStrings {
  // Explore — backend category query values, not display text.
  static const categoryQueryMens = 'mens_fashion';
  static const categoryQueryWomens = 'womens_fashion';

  // Notifications grouping / relative time.
  static const notificationsGroupToday = 'TODAY';
  static const notificationsGroupYesterday = 'YESTERDAY';
  static const notificationsGroupThisWeek = 'THIS WEEK';
  static const notificationsGroupEarlier = 'EARLIER';
  static const notificationsTimeJustNow = 'Just now';
  static String notificationsTimeMinutesAgo(int m) => '${m}m ago';
  static String notificationsTimeHoursAgo(int h) => '${h}h ago';
  static const notificationsTimeYesterday = 'Yesterday';

  // Orders
  static const ordersCurrentLocationMock = 'In transit — Algiers hub';
}
