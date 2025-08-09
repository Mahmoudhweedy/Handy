import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../features/products/presentation/pages/product_details_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/orders/presentation/pages/order_details_page.dart';
import '../../features/bookings/presentation/pages/bookings_page.dart';
import '../../features/bookings/presentation/pages/booking_details_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/main_wrapper.dart';
import '../../presentation/pages/splash_page.dart';
import '../../presentation/pages/onboarding_page.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/';
  static const String products = '/products';
  static const String productDetails = '/products/:id';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String orderDetails = '/orders/:id';
  static const String bookings = '/bookings';
  static const String bookingDetails = '/bookings/:id';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static GoRouter createRouter({
    required bool isAuthenticated,
    required bool isFirstTime,
  }) {
    return GoRouter(
      initialLocation: isFirstTime ? onboarding : (isAuthenticated ? home : login),
      debugLogDiagnostics: true,
      routes: [
        // Splash Screen
        GoRoute(
          path: splash,
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),

        // Onboarding
        GoRoute(
          path: onboarding,
          name: 'onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),

        // Authentication Routes
        GoRoute(
          path: login,
          name: 'login',
          builder: (context, state) => const LoginPage(),
          routes: [
            GoRoute(
              path: 'register',
              name: 'register',
              builder: (context, state) => const RegisterPage(),
            ),
            GoRoute(
              path: 'forgot-password',
              name: 'forgot-password',
              builder: (context, state) => const ForgotPasswordPage(),
            ),
          ],
        ),

        // Main App Routes (requires authentication)
        ShellRoute(
          builder: (context, state, child) {
            return MainWrapper(child: child);
          },
          routes: [
            // Home
            GoRoute(
              path: home,
              name: 'home',
              builder: (context, state) => const HomePage(),
            ),

            // Products
            GoRoute(
              path: products,
              name: 'products',
              builder: (context, state) {
                final category = state.uri.queryParameters['category'];
                final query = state.uri.queryParameters['query'];
                return ProductsPage(
                  initialCategory: category,
                  initialQuery: query,
                );
              },
              routes: [
                GoRoute(
                  path: ':id',
                  name: 'product-details',
                  builder: (context, state) {
                    final productId = state.pathParameters['id']!;
                    return ProductDetailsPage(productId: productId);
                  },
                ),
              ],
            ),

            // Cart
            GoRoute(
              path: cart,
              name: 'cart',
              builder: (context, state) => const CartPage(),
            ),

            // Orders
            GoRoute(
              path: orders,
              name: 'orders',
              builder: (context, state) => const OrdersPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  name: 'order-details',
                  builder: (context, state) {
                    final orderId = state.pathParameters['id']!;
                    return OrderDetailsPage(orderId: orderId);
                  },
                ),
              ],
            ),

            // Bookings
            GoRoute(
              path: bookings,
              name: 'bookings',
              builder: (context, state) => const BookingsPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  name: 'booking-details',
                  builder: (context, state) {
                    final bookingId = state.pathParameters['id']!;
                    return BookingDetailsPage(bookingId: bookingId);
                  },
                ),
              ],
            ),

            // Profile
            GoRoute(
              path: profile,
              name: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),

            // Settings
            GoRoute(
              path: settings,
              name: 'settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final location = state.matchedLocation;

        // Skip redirect for splash screen
        if (location == splash) {
          return null;
        }

        // First time users go to onboarding
        if (isFirstTime && location != onboarding) {
          return onboarding;
        }

        // Non-first time users skip onboarding
        if (!isFirstTime && location == onboarding) {
          return isAuthenticated ? home : login;
        }

        // Authenticated users shouldn't see auth pages
        if (isAuthenticated && _isAuthRoute(location)) {
          return home;
        }

        // Non-authenticated users should only see auth pages or public pages
        if (!isAuthenticated && !_isAuthRoute(location) && !_isPublicRoute(location)) {
          return login;
        }

        return null;
      },
      errorBuilder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Page not found',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  state.error?.toString() ?? 'The requested page could not be found.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go(home),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static bool _isAuthRoute(String location) {
    return location.startsWith('/login') ||
        location.startsWith('/register') ||
        location.startsWith('/forgot-password');
  }

  static bool _isPublicRoute(String location) {
    return location == splash ||
        location == onboarding ||
        _isAuthRoute(location);
  }

  // Navigation helpers
  static void goToLogin(BuildContext context) {
    context.go(login);
  }

  static void goToRegister(BuildContext context) {
    context.go('$login/register');
  }

  static void goToForgotPassword(BuildContext context) {
    context.go('$login/forgot-password');
  }

  static void goToHome(BuildContext context) {
    context.go(home);
  }

  static void goToProducts(BuildContext context, {String? category, String? query}) {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;
    if (query != null) queryParams['query'] = query;
    
    final uri = Uri(path: products, queryParameters: queryParams.isNotEmpty ? queryParams : null);
    context.go(uri.toString());
  }

  static void goToProductDetails(BuildContext context, String productId) {
    context.go('/products/$productId');
  }

  static void goToCart(BuildContext context) {
    context.go(cart);
  }

  static void goToOrders(BuildContext context) {
    context.go(orders);
  }

  static void goToOrderDetails(BuildContext context, String orderId) {
    context.go('/orders/$orderId');
  }

  static void goToBookings(BuildContext context) {
    context.go(bookings);
  }

  static void goToBookingDetails(BuildContext context, String bookingId) {
    context.go('/bookings/$bookingId');
  }

  static void goToProfile(BuildContext context) {
    context.go(profile);
  }

  static void goToSettings(BuildContext context) {
    context.go(settings);
  }

  // Pop helpers
  static void pop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(home);
    }
  }

  static void popToHome(BuildContext context) {
    context.go(home);
  }
}
