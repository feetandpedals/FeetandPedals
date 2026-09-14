import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/checkout/payment_screen.dart';
import '../../features/checkout/payment_result_screen.dart';
import '../../features/checkout/registration_screen.dart';
import '../../features/events/event_detail_screen.dart';
import '../../features/events/events_list_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/main_shell.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/settings_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/tickets/my_tickets_screen.dart';
import '../../features/tickets/ticket_detail_screen.dart';
import '../../state/auth_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loggingIn = ['/login', '/signup', '/forgot-password'].contains(state.matchedLocation);
      final onSplash = state.matchedLocation == '/splash';

      if (auth.status == AuthStatus.unknown) {
        return onSplash ? null : '/splash';
      }
      if (auth.status == AuthStatus.unauthenticated) {
        return loggingIn ? null : '/login';
      }
      // authenticated
      if (loggingIn || onSplash) return '/home';
      return null;
    },
    refreshListenable: _AuthRefreshNotifier(ref),
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/events', builder: (context, state) => const EventsListScreen()),
          GoRoute(path: '/tickets', builder: (context, state) => const MyTicketsScreen()),
          GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/events/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => EventDetailScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/events/:id/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => RegistrationScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/checkout/payment',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: '/checkout/result',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PaymentResultScreen(),
      ),
      GoRoute(
        path: '/tickets/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => TicketDetailScreen(purchaseId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/profile/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

/// Bridges Riverpod's [authControllerProvider] changes into something
/// go_router's `refreshListenable` understands, so login/logout re-runs
/// [GoRouter.redirect] immediately.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(this._ref) {
    _ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}
