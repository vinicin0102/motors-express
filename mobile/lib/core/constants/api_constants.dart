class ApiConstants {
  static const String baseUrl = 'http://localhost:3000/api';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';

  // Users
  static const String profile = '/users/me';

  // Vehicles
  static const String vehicles = '/vehicles';

  // Rides
  static const String analyzeRide = '/rides/analyze';
  static const String rideHistory = '/rides/history';
  static const String todaySummary = '/rides/today';

  // Goals
  static const String goals = '/goals';
  static const String goalSummary = '/goals/summary';

  // Subscriptions
  static const String plans = '/subscriptions/plans';
  static const String currentSub = '/subscriptions/current';
  static const String startTrial = '/subscriptions/trial';
  static const String upgrade = '/subscriptions/upgrade';
  static const String cancelSub = '/subscriptions/cancel';

  // Analytics
  static const String dashboard = '/analytics/dashboard';
  static const String insights = '/analytics/insights';
  static const String bestTimes = '/analytics/best-times';

  // Notifications
  static const String notifications = '/notifications';

  // Coupons
  static const String validateCoupon = '/coupons/validate';
  static const String applyCoupon = '/coupons/apply';
}
