import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/listing/presentation/screens/add_listing_screen.dart';
import '../../features/listing/presentation/screens/my_listings_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/product/presentation/screens/product_detail_screen.dart';
import '../../features/product/presentation/screens/product_reviews_screen.dart';
import '../../features/product/presentation/screens/seller_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../shared/widgets/xstore_bottom_nav.dart';
import 'app_routes.dart';
import 'router_notifier.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter goRouter(GoRouterRef ref) {
  final refresh = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: refresh,
    redirect: (context, state) => xStoreGoRouterRedirect(ref, state),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: XstoreBottomNav(shell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.explore,
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cart,
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.orders,
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.product}/:id/reviews',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ProductReviewsScreen(listingId: id);
        },
      ),
      GoRoute(
        path: '${AppRoutes.sellerProfile}/:sellerId',
        builder: (context, state) {
          final id = state.pathParameters['sellerId'] ?? '';
          return SellerProfileScreen(sellerId: id);
        },
      ),
      GoRoute(
        path: '${AppRoutes.product}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.listingAdd,
        builder: (context, state) => const AddListingScreen(),
      ),
      GoRoute(
        path: AppRoutes.listingMy,
        builder: (context, state) => const MyListingsScreen(),
      ),
    ],
  );
}
