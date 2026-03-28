abstract final class ApiEndpoints {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';

  static const String banners = '/home/banners';
  static const String hotDeals = '/home/hot-deals';
  static const String categories = '/home/categories';

  static const String listings = '/listings';
  static const String myListings = '/listings/mine';

  static const String users = '/users';
}
