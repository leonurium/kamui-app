import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:kamui_app/core/utils/logger.dart';

class AnalyticsService {
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  static String _getDeviceType() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  // Track screen views
  static Future<void> setCurrentScreen(String screenName) async {
    try {
      await analytics.logScreenView(
        screenName: screenName,
        screenClass: screenName
      );
    } catch (e) {
      // Silently fail for analytics errors
      Logger.error('Analytics error: $e');
    }
  }

  // VPN Connection Events
  static Future<void> logVpnConnect({
    required String serverLocation,
    required String protocol,
    required String connectionType,
  }) async {
    try {
      await analytics.logEvent(
        name: 'vpn_connect',
        parameters: {
          'server_location': serverLocation,
          'protocol': protocol,
          'connection_type': connectionType,
          'device_type': _getDeviceType(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      Logger.error('Analytics error: $e');
    }
  }

  static Future<void> logVpnDisconnect({
    required String serverLocation,
    required String protocol,
    required String connectionType,
    required int durationInSeconds,
  }) async {
    try {
      await analytics.logEvent(
        name: 'vpn_disconnect',
        parameters: {
          'server_id': serverLocation,
          'endpoint': protocol,
          'connection_type': connectionType,
          'duration_seconds': durationInSeconds,
          'device_type': _getDeviceType(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      Logger.error('Analytics error: $e');
    }
  }

  // Server Selection
  static Future<void> logServerSelection({
    required String serverLocation,
    required String serverName,
    required String reason,
  }) async {
    try {
      await analytics.logEvent(
        name: 'server_selection',
        parameters: {
          'server_location': serverLocation,
          'server_name': serverName,
          'selection_reason': reason,
          'device_type': _getDeviceType(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      Logger.error('Analytics error: $e');
    }
  }

  // Onboarding Completion
  static Future<void> logOnboardingComplete({
    required int totalScreens,
    required int timeSpentSeconds,
    required bool skipped,
  }) async {
    try {
      await analytics.logEvent(
        name: 'onboarding_complete',
        parameters: {
          'total_screens': totalScreens,
          'time_spent_seconds': timeSpentSeconds,
          'skipped': skipped,
          'device_type': _getDeviceType(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      Logger.error('Analytics error: $e');
    }
  }

  // Subscription Events
  static Future<void> logSubscriptionPurchase({
    required String planType,
    required double amount,
    required String currency,
    required bool success,
  }) async {
    try {
      await analytics.logEvent(
        name: 'subscription_purchase',
        parameters: {
          'plan_type': planType,
          'amount': amount,
          'currency': currency,
          'success': success,
          'device_type': _getDeviceType(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      Logger.error('Analytics error: $e');
    }
  }

  static Future<void> logSubscriptionRenewal({
    required String planType,
    required double amount,
    required String currency,
    required bool success,
  }) async {
    try {
      await analytics.logEvent(
        name: 'subscription_renewal',
        parameters: {
          'plan_type': planType,
          'amount': amount,
          'currency': currency,
          'success': success,
          'device_type': _getDeviceType(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      Logger.error('Analytics error: $e');
    }
  }

  // App Crashes
  static Future<void> logAppCrash({
    required String error,
    required String stackTrace,
    required String screenName,
  }) async {
    try {
      await analytics.logEvent(
        name: 'app_crash',
        parameters: {
          'error': error,
          'stack_trace': stackTrace,
          'screen_name': screenName,
          'device_type': _getDeviceType(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      Logger.error('Analytics error: $e');
    }
  }

  // Feature Usage
  static Future<void> logFeatureUsage({
    required String featureName,
    required String action,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      final parameters = {
        'feature_name': featureName,
        'action': action,
        'device_type': _getDeviceType(),
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
    } catch (e) {
      Logger.error('Analytics error: $e');
    }
  }

  // User Properties
  static Future<void> setUserProperties({
    required String subscriptionStatus,
    required String connectionType,
    required String deviceType,
  }) async {
    try {
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
    } catch (e) {
      Logger.error('Analytics error: $e');
    }
  }
} 