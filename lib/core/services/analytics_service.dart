import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  // Track screen views
  static Future<void> setCurrentScreen(String screenName) async {
    await analytics.setCurrentScreen(
      screenName: screenName,
      screenClassOverride: screenName,
    );
  }

  // VPN Connection Events
  static Future<void> logVpnConnect({
    required String serverLocation,
    required String protocol,
    required String connectionType,
  }) async {
    await analytics.logEvent(
      name: 'vpn_connect',
      parameters: {
        'server_location': serverLocation,
        'protocol': protocol,
        'connection_type': connectionType,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logVpnDisconnect({
    required String serverLocation,
    required String protocol,
    required String connectionType,
    required int durationInSeconds,
  }) async {
    await analytics.logEvent(
      name: 'vpn_disconnect',
      parameters: {
        'server_id': serverLocation,
        'endpoint': protocol,
        'connection_type': connectionType,
        'duration_seconds': durationInSeconds,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Server Selection
  static Future<void> logServerSelection({
    required String serverLocation,
    required String serverName,
    required String reason,
  }) async {
    await analytics.logEvent(
      name: 'server_selection',
      parameters: {
        'server_location': serverLocation,
        'server_name': serverName,
        'selection_reason': reason,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Onboarding Completion
  static Future<void> logOnboardingComplete({
    required int totalScreens,
    required int timeSpentSeconds,
    required bool skipped,
  }) async {
    await analytics.logEvent(
      name: 'onboarding_complete',
      parameters: {
        'total_screens': totalScreens,
        'time_spent_seconds': timeSpentSeconds,
        'skipped': skipped,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Subscription Events
  static Future<void> logSubscriptionPurchase({
    required String planType,
    required double amount,
    required String currency,
    required bool success,
  }) async {
    await analytics.logEvent(
      name: 'subscription_purchase',
      parameters: {
        'plan_type': planType,
        'amount': amount,
        'currency': currency,
        'success': success,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logSubscriptionRenewal({
    required String planType,
    required double amount,
    required String currency,
    required bool success,
  }) async {
    await analytics.logEvent(
      name: 'subscription_renewal',
      parameters: {
        'plan_type': planType,
        'amount': amount,
        'currency': currency,
        'success': success,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // App Crashes
  static Future<void> logAppCrash({
    required String error,
    required String stackTrace,
    required String screenName,
  }) async {
    await analytics.logEvent(
      name: 'app_crash',
      parameters: {
        'error': error,
        'stack_trace': stackTrace,
        'screen_name': screenName,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Feature Usage
  static Future<void> logFeatureUsage({
    required String featureName,
    required String action,
    Map<String, dynamic>? additionalParams,
  }) async {
    final parameters = {
      'feature_name': featureName,
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    if (additionalParams != null) {
      // Convert all values to strings
      additionalParams.forEach((key, value) {
        parameters[key] = value.toString();
      });
    }

    await analytics.logEvent(
      name: 'feature_usage',
      parameters: parameters,
    );
  }

  // User Properties
  static Future<void> setUserProperties({
    required String subscriptionStatus,
    required String connectionType,
    required String deviceType,
  }) async {
    await analytics.setUserProperty(
      name: 'subscription_status',
      value: subscriptionStatus,
    );
    await analytics.setUserProperty(
      name: 'connection_type',
      value: connectionType,
    );
    await analytics.setUserProperty(
      name: 'device_type',
      value: deviceType,
    );
  }
} 