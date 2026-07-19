import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_strings.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/courier_login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/social_role_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/guest_mode_provider.dart';
import '../../features/auth/presentation/providers/phone_auth_provider.dart';
import '../../features/auth/presentation/providers/social_auth_provider.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/cart/presentation/screens/checkout_screen.dart';
import '../../features/delivery/presentation/screens/courier_cash_screen.dart';
import '../../features/delivery/presentation/screens/courier_deliveries_screen.dart';
import '../../features/delivery/presentation/screens/my_package_requests_screen.dart';
import '../../features/delivery/presentation/screens/send_package_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/listing/presentation/screens/add_listing_screen.dart';
import '../../features/listing/presentation/screens/my_listings_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/orders/presentation/screens/vendor_order_detail_screen.dart';
import '../../features/orders/presentation/screens/vendor_orders_screen.dart';
import '../../features/product/presentation/screens/product_detail_screen.dart';
import '../../features/product/presentation/screens/product_reviews_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/notifications/presentation/screens/notification_settings_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/vendor_store_screen.dart';
import '../../features/store/presentation/screens/store_hours_screen.dart';
import '../../shared/screens/coming_soon_screen.dart';
import '../../shared/screens/trust_info_screens.dart';
import '../../features/wishlist/presentation/screens/wishlist_screen.dart';
import '../../shared/widgets/xstore_bottom_nav.dart';
import '../animations/page_transitions.dart';
import 'app_routes.dart';
import 'router_notifier.dart';

part 'app_router.g.dart';

List<StatefulShellBranch> _consumerShellBranches() => [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => fadeScaleTransition(
              context,
              state,
              const HomeScreen(),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.explore,
            pageBuilder: (context, state) => fadeScaleTransition(
              context,
              state,
              const ExploreScreen(),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.wishlist,
            pageBuilder: (context, state) => fadeScaleTransition(
              context,
              state,
              const WishlistScreen(),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.orders,
            pageBuilder: (context, state) => fadeScaleTransition(
              context,
              state,
              const OrdersScreen(),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => fadeScaleTransition(
              context,
              state,
              const ProfileScreen(),
            ),
          ),
        ],
      ),
    ];

List<StatefulShellBranch> _vendorShellBranches() => [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => fadeScaleTransition(
              context,
              state,
              const HomeScreen(),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.explore,
            pageBuilder: (context, state) => fadeScaleTransition(
              context,
              state,
              const ExploreScreen(),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.listingAdd,
            pageBuilder: (context, state) => fadeScaleTransition(
              context,
              state,
              const AddListingScreen(),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.vendorOrders,
            pageBuilder: (context, state) => fadeScaleTransition(
              context,
              state,
              const VendorOrdersScreen(),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => fadeScaleTransition(
              context,
              state,
              const ProfileScreen(),
            ),
          ),
        ],
      ),
    ];

List<StatefulShellBranch> _courierShellBranches() => [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.deliveries,
            pageBuilder: (context, state) => fadeScaleTransition(
              context,
              state,
              const CourierDeliveriesScreen(),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.courierCash,
            pageBuilder: (context, state) => fadeScaleTransition(
              context,
              state,
              const CourierCashScreen(),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => fadeScaleTransition(
              context,
              state,
              const ProfileScreen(),
            ),
          ),
        ],
      ),
    ];

@Riverpod(keepAlive: true)
GoRouter goRouter(GoRouterRef ref) {
  final refresh = ref.watch(routerNotifierProvider);
  // Only rebuild the route tree when the role's tab set changes — not on every
  // auth refresh, or login would recreate GoRouter and reset to [initialLocation].
  final role = ref.watch(
    authProvider.select((auth) => auth.valueOrNull?.role ?? UserRole.consumer),
  );
  final shellBranches = switch (role) {
    UserRole.vendor => _vendorShellBranches(),
    UserRole.courier => _courierShellBranches(),
    UserRole.consumer => _consumerShellBranches(),
  };

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) => computeXStoreAuthRedirect(
      auth: ref.read(authProvider),
      needsRoleSelection: ref.read(socialAuthProvider).needsRoleSelection,
      matchedLocation: state.matchedLocation,
      holdRegisterForVendorSuccess:
          ref.read(registerNotifierProvider).showVendorSuccessOverlay,
      isGuest: ref.read(guestModeProvider),
    ),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => fadeScaleTransition(
          context,
          state,
          const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => fadeScaleTransition(
          context,
          state,
          const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.courierLogin,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const CourierLoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.socialRoleSelect,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const SocialRoleScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          ResetPasswordScreen(email: state.extra as String? ?? ''),
        ),
      ),
      GoRoute(
        path: AppRoutes.otp,
        pageBuilder: (context, state) => slideUpTransition(
          context,
          state,
          const OtpScreen(),
        ),
        redirect: (context, state) {
          final phoneState = ref.read(phoneAuthProvider);
          if (phoneState.verificationId == null) return AppRoutes.login;
          return null;
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: XstoreBottomNav(shell: navigationShell),
          );
        },
        branches: shellBranches,
      ),
      GoRoute(
        path: AppRoutes.cart,
        pageBuilder: (context, state) => slideUpTransition(
          context,
          state,
          const CartScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        pageBuilder: (context, state) => slideUpTransition(
          context,
          state,
          const CheckoutScreen(),
        ),
      ),
      // Consumer package delivery — plain stack routes (not shell tabs),
      // so `context.push` from profile/my-packages is safe.
      GoRoute(
        path: AppRoutes.sendPackage,
        pageBuilder: (context, state) => slideUpTransition(
          context,
          state,
          const SendPackageScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.myPackages,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const MyPackageRequestsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.listingMy,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const MyListingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.incomingOrders,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const OrdersScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.vendorOrders}/:orderId',
        pageBuilder: (context, state) => slideUpTransition(
          context,
          state,
          VendorOrderDetailScreen(
            orderId: state.pathParameters['orderId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.orderDetail}/:orderId',
        pageBuilder: (context, state) {
          final id = state.pathParameters['orderId'] ?? '';
          return slideUpTransition(
            context,
            state,
            OrderDetailScreen(orderId: id),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.product}/:id/reviews',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return slideRightTransition(
            context,
            state,
            ProductReviewsScreen(listingId: id),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.sellerProfile}/:sellerId',
        pageBuilder: (context, state) {
          final id = state.pathParameters['sellerId'] ?? '';
          return slideRightTransition(
            context,
            state,
            VendorStoreScreen(sellerId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.profileEdit,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const EditProfileScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const ComingSoonScreen(title: AppStrings.settings),
        ),
      ),
      GoRoute(
        path: AppRoutes.analytics,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const ComingSoonScreen(title: AppStrings.menuAnalytics),
        ),
      ),
      GoRoute(
        path: AppRoutes.myOrdersPlaceholder,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const ComingSoonScreen(title: AppStrings.menuMyOrders),
        ),
      ),
      GoRoute(
        path: AppRoutes.earnings,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const ComingSoonScreen(title: AppStrings.menuEarnings),
        ),
      ),
      GoRoute(
        path: AppRoutes.recentlyViewed,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const ComingSoonScreen(title: AppStrings.menuRecentlyViewed),
        ),
      ),
      GoRoute(
        path: AppRoutes.myReviews,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const ComingSoonScreen(title: AppStrings.menuMyReviews),
        ),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const ComingSoonScreen(title: AppStrings.menuChangePassword),
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.notificationSettings,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const NotificationSettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/chat/:threadId',
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const ComingSoonScreen(title: AppStrings.chatSeller),
        ),
      ),
      GoRoute(
        path: AppRoutes.paymentMethods,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const PaymentMethodsInfoScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.addresses,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const AddressesInfoScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.storeHours,
        pageBuilder: (context, state) => slideUpTransition(
          context,
          state,
          const StoreHoursScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.help,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const HelpCenterInfoScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.terms,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const TermsInfoScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        pageBuilder: (context, state) => slideRightTransition(
          context,
          state,
          const PrivacyInfoScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.product}/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return slideUpTransition(
            context,
            state,
            ProductDetailScreen(productId: id),
          );
        },
      ),
    ],
  );
}
