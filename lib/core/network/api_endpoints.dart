import '../config/env.dart';

/// REST endpoint paths on the existing Laravel / Eventiq backend.
///
/// These mirror the contract already implemented by the Eventiq Flutter
/// reference app (`AppStrings`) that Feet and Pedals' backend team supplied,
/// so the mobile app can be pointed at the real API with no path changes —
/// only [Env.apiBaseUrl] needs to be set once the Feet and Pedals API host
/// is known. If the backend team adds/renames endpoints for MVP1-specific
/// needs (e.g. add-ons, waivers), update the matching constant here only;
/// no other file references raw paths.
abstract class ApiEndpoints {
  static String get _v1 => '${Env.apiBaseUrl}/api';

  // Auth
  static String get login => '$_v1/login';
  static String get register => '$_v1/registration';
  static String get emailVerification => '$_v1/email-verification';
  static String get accountActivation => '$_v1/account-activation';
  static String get resetPassword => '$_v1/reset-password';
  static String get forgotPassword => '$_v1/forgot-password';
  static String get logout => '$_v1/logout';
  static String get me => '$_v1/user';
  static String get socialLogin => '$_v1/social-login';

  // Events
  static String get events => '$_v1/events';
  static String get eventFavorite => '$_v1/event-favorite';
  static String get eventDetails => '$_v1/event/details';
  static String get categories => '$_v1/categories';
  static String get filterOptions => '$_v1/filter-options';
  static String get myFavoriteEvents => '$_v1/my-favorite-events';

  // Registration / tickets on an event
  static String get eventTickets => '$_v1/event-tickets';
  static String get bookTicket => '$_v1/event-ticket/purchase';

  // Checkout / payment
  static String get gateways => '$_v1/gateways';
  static String get checkout => '$_v1/checkout-confirmation';
  static String get couponDiscount => '$_v1/coupon-discount';

  // My tickets / registrations
  static String get myTickets => '$_v1/my-tickets';
  static String get myTicketDetails => '$_v1/ticket-details';
  static String get myEvents => '$_v1/my-events';

  // Account
  static String get updateProfile => '$_v1/update-profile';
  static String get updatePassword => '$_v1/change-password';
  static String get settings => '$_v1/settings';

  // Notifications
  static String get notifications => '$_v1/notifications';
  static String get markNotificationRead => '$_v1/notifications/read';
}
